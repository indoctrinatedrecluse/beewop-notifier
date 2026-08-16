defmodule Myapp.Notifications do
  @moduledoc false

  import Ecto.Query

  alias Myapp.Notifications.{Discord, GitHubEvent, Notification}
  alias Myapp.Repo

  @topic "notifications"

  def subscribe, do: Phoenix.PubSub.subscribe(Myapp.PubSub, @topic)

  def list_notifications(limit \\ 20) do
    Notification
    |> order_by([notification], desc: notification.inserted_at)
    |> limit(^limit)
    |> Repo.all()
  end

  def ingest_github(payload, event_name, delivery_id) do
    with {:notify, attrs} <- GitHubEvent.to_notification(event_name, payload) do
      attrs = Map.merge(attrs, %{delivery_id: delivery_id, payload: payload, status: "pending"})

      case Repo.insert(Notification.changeset(%Notification{}, attrs)) do
        {:ok, notification} ->
          broadcast({:notification_created, notification})
          deliver_later(notification)
          {:ok, notification}

        {:error, changeset} ->
          if Keyword.has_key?(changeset.errors, :delivery_id) do
            {:duplicate, Repo.get_by!(Notification, delivery_id: delivery_id)}
          else
            {:error, changeset}
          end
      end
    else
      :ignore -> :ignored
    end
  end

  defp deliver(notification) do
    {status, error} =
      case Discord.deliver(notification) do
        :ok -> {"delivered", nil}
        {:error, message} -> {"failed", message}
      end

    {:ok, notification} =
      notification
      |> Notification.changeset(%{status: status, delivery_error: error})
      |> Repo.update()

    broadcast({:notification_updated, notification})
  end

  defp deliver_later(notification) do
    if Application.get_env(:myapp, :deliver_notifications, true) do
      Task.Supervisor.start_child(Myapp.TaskSupervisor, fn -> deliver(notification) end)
    end
  end

  defp broadcast(message), do: Phoenix.PubSub.broadcast(Myapp.PubSub, @topic, message)
end

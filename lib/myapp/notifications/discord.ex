defmodule Myapp.Notifications.Discord do
  @moduledoc false

  alias Myapp.Notifications.Notification

  def deliver(%Notification{} = notification) do
    with url when is_binary(url) and url != "" <-
           Application.get_env(:myapp, :discord_webhook_url),
         {:ok, response} <- Req.post(url, json: payload(notification)),
         true <- response.status in 200..299 do
      :ok
    else
      nil -> {:error, "DISCORD_WEBHOOK_URL is not configured"}
      "" -> {:error, "DISCORD_WEBHOOK_URL is not configured"}
      {:ok, response} -> {:error, "Discord returned HTTP #{response.status}"}
      {:error, reason} -> {:error, Exception.message(reason)}
      false -> {:error, "Discord did not accept the notification"}
    end
  end

  defp payload(notification) do
    %{
      username: "Beewop",
      embeds: [
        %{
          title: notification.title,
          url: notification.url,
          color: color(notification.event_type),
          fields: [%{name: "Repository", value: notification.repository, inline: true}],
          footer: %{text: "GitHub → Beewop"}
        }
      ]
    }
  end

  defp color("workflow_failure"), do: 15_322_226
  defp color(_), do: 5_797_878
end

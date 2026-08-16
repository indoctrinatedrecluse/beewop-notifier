defmodule MyappWeb.DashboardLive do
  use MyappWeb, :live_view

  alias Myapp.Notifications

  @impl true
  def mount(_params, _session, socket) do
    notifications = Notifications.list_notifications()

    if connected?(socket), do: Notifications.subscribe()

    {:ok,
     socket
     |> assign(:page_title, "Beewop")
     |> assign(:notifications_empty?, notifications == [])
     |> stream(:notifications, notifications)}
  end

  @impl true
  def handle_info({:notification_created, notification}, socket) do
    {:noreply,
     socket
     |> assign(:notifications_empty?, false)
     |> stream_insert(:notifications, notification, at: 0)}
  end

  def handle_info({:notification_updated, notification}, socket) do
    {:noreply, stream_insert(socket, :notifications, notification)}
  end

  defp status_class("delivered"), do: "bg-emerald-100 text-emerald-800 ring-emerald-600/20"
  defp status_class("failed"), do: "bg-rose-100 text-rose-800 ring-rose-600/20"
  defp status_class(_), do: "bg-amber-100 text-amber-800 ring-amber-600/20"

  defp status_label("delivered"), do: "Delivered"
  defp status_label("failed"), do: "Needs attention"
  defp status_label(_), do: "Sending"

  defp timestamp(notification),
    do: Calendar.strftime(notification.inserted_at, "%b %-d, %H:%M UTC")
end

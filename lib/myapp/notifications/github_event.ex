defmodule Myapp.Notifications.GitHubEvent do
  @moduledoc false

  def to_notification("workflow_run", %{
        "workflow_run" => %{"conclusion" => "failure"} = run,
        "repository" => repository
      }) do
    {:notify,
     %{
       event_type: "workflow_failure",
       repository: repository_name(repository),
       title: "Workflow failed: #{Map.get(run, "name", "Unknown workflow")}",
       url: Map.get(run, "html_url")
     }}
  end

  def to_notification("release", %{
        "action" => action,
        "release" => release,
        "repository" => repository
      })
      when action in ["created", "published"] do
    {:notify,
     %{
       event_type: "release_#{action}",
       repository: repository_name(repository),
       title:
         "New release: #{Map.get(release, "name") || Map.get(release, "tag_name", "Untitled release")}",
       url: Map.get(release, "html_url")
     }}
  end

  def to_notification(_, _), do: :ignore

  defp repository_name(%{"full_name" => name}), do: name
  defp repository_name(_), do: "Unknown repository"
end

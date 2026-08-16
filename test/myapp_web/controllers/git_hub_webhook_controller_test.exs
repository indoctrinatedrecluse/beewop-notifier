defmodule MyappWeb.GitHubWebhookControllerTest do
  use MyappWeb.ConnCase

  alias Myapp.Notifications

  setup do
    previous_secret = Application.get_env(:myapp, :github_webhook_secret)
    Application.put_env(:myapp, :github_webhook_secret, "webhook-secret")

    on_exit(fn -> Application.put_env(:myapp, :github_webhook_secret, previous_secret) end)
    :ok
  end

  test "stores a failed workflow run", %{conn: conn} do
    payload = %{
      "workflow_run" => %{
        "conclusion" => "failure",
        "name" => "Test suite",
        "html_url" => "https://github.com/acme/widget/actions/runs/1"
      },
      "repository" => %{"full_name" => "acme/widget"}
    }

    body = Jason.encode!(payload)

    conn =
      conn
      |> put_req_header("content-type", "application/json")
      |> put_req_header("x-hub-signature-256", signature_for(body))
      |> put_req_header("x-github-event", "workflow_run")
      |> put_req_header("x-github-delivery", "delivery-1")
      |> post(~p"/webhooks/github", body)

    assert conn.status == 202
    [notification] = Notifications.list_notifications()
    assert notification.repository == "acme/widget"
    assert notification.event_type == "workflow_failure"
    assert notification.status == "pending"
  end

  test "rejects a request with an invalid signature", %{conn: conn} do
    conn =
      conn
      |> put_req_header("content-type", "application/json")
      |> put_req_header("x-hub-signature-256", "sha256=invalid")
      |> post(~p"/webhooks/github", Jason.encode!(%{}))

    assert conn.status == 401
  end

  defp signature_for(body) do
    :crypto.mac(:hmac, :sha256, "webhook-secret", body)
    |> Base.encode16(case: :lower)
    |> then(&("sha256=" <> &1))
  end
end

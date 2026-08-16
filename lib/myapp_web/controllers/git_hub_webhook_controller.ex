defmodule MyappWeb.GitHubWebhookController do
  use MyappWeb, :controller

  alias Myapp.{GitHubSignature, Notifications}

  def create(conn, payload) do
    with [signature] <- get_req_header(conn, "x-hub-signature-256"),
         true <- GitHubSignature.valid?(signature, conn.assigns.raw_body),
         [event_name] <- get_req_header(conn, "x-github-event"),
         [delivery_id] <- get_req_header(conn, "x-github-delivery") do
      case Notifications.ingest_github(payload, event_name, delivery_id) do
        {:ok, _notification} -> send_resp(conn, :accepted, "")
        {:duplicate, _notification} -> send_resp(conn, :ok, "")
        :ignored -> send_resp(conn, :accepted, "")
        {:error, _changeset} -> send_resp(conn, :unprocessable_entity, "")
      end
    else
      false -> send_resp(conn, :unauthorized, "")
      _ -> send_resp(conn, :bad_request, "")
    end
  end
end

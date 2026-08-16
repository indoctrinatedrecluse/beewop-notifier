defmodule MyappWeb.Plugs.RawBodyReader do
  @moduledoc false

  import Plug.Conn

  def read_body(conn, opts), do: read_body(conn, opts, "")

  defp read_body(conn, opts, accumulated) do
    case Plug.Conn.read_body(conn, opts) do
      {:ok, body, conn} ->
        full_body = accumulated <> body
        {:ok, full_body, assign(conn, :raw_body, full_body)}

      {:more, body, conn} ->
        read_body(conn, opts, accumulated <> body)
    end
  end
end

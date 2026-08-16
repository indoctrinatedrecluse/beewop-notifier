defmodule Myapp.GitHubSignature do
  @moduledoc false

  def valid?(signature, body, secret \\ Application.get_env(:myapp, :github_webhook_secret))

  def valid?("sha256=" <> signature, body, secret)
      when is_binary(body) and is_binary(secret) and byte_size(secret) > 0 do
    expected = :crypto.mac(:hmac, :sha256, secret, body) |> Base.encode16(case: :lower)

    byte_size(signature) == byte_size(expected) and
      Plug.Crypto.secure_compare(signature, expected)
  end

  def valid?(_, _, _), do: false
end

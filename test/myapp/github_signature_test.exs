defmodule Myapp.GitHubSignatureTest do
  use ExUnit.Case, async: true

  alias Myapp.GitHubSignature

  test "accepts a valid GitHub SHA-256 signature" do
    body = "{\"action\":\"created\"}"
    secret = "webhook-secret"

    signature =
      :crypto.mac(:hmac, :sha256, secret, body)
      |> Base.encode16(case: :lower)
      |> then(&("sha256=" <> &1))

    assert GitHubSignature.valid?(signature, body, secret)
  end

  test "rejects an invalid signature" do
    refute GitHubSignature.valid?("sha256=not-a-signature", "{}", "webhook-secret")
  end
end

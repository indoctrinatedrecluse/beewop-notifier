defmodule Myapp.Notifications.Notification do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  schema "notifications" do
    field :delivery_id, :string
    field :event_type, :string
    field :repository, :string
    field :title, :string
    field :url, :string
    field :status, :string, default: "pending"
    field :delivery_error, :string
    field :payload, :map

    timestamps(type: :utc_datetime)
  end

  def changeset(notification, attrs) do
    notification
    |> cast(attrs, [
      :delivery_id,
      :event_type,
      :repository,
      :title,
      :url,
      :status,
      :delivery_error,
      :payload
    ])
    |> validate_required([:delivery_id, :event_type, :repository, :title, :status, :payload])
    |> validate_inclusion(:status, ["pending", "delivered", "failed"])
    |> unique_constraint(:delivery_id)
  end
end

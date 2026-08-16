defmodule Myapp.Repo.Migrations.CreateNotifications do
  use Ecto.Migration

  def change do
    create table(:notifications) do
      add :delivery_id, :string, null: false
      add :event_type, :string, null: false
      add :repository, :string, null: false
      add :title, :string, null: false
      add :url, :string
      add :status, :string, null: false, default: "pending"
      add :delivery_error, :text
      add :payload, :map, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:notifications, [:delivery_id])
    create index(:notifications, [:inserted_at])
  end
end

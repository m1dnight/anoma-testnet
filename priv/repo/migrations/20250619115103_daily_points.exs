defmodule Anoma.Repo.Migrations.DailyPoints do
  use Ecto.Migration

  def change do
    create table(:daily_points, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add :location, :string
      add :day, :date
      add :claimed, :boolean, default: false
      add :user_id, references(:users, on_delete: :delete_all, type: :uuid)

      timestamps(type: :utc_datetime)
    end

    create index(:daily_points, [:user_id])
  end
end

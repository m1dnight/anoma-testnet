defmodule Anoma.Repo.Migrations.CreateInvites do
  use Ecto.Migration

  def change do
    create table(:invites, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add :code, :string
      add :user_id, references(:users, on_delete: :nothing, type: :uuid)

      timestamps(type: :utc_datetime)
    end

    create index(:invites, [:user_id])
    create unique_index(:invites, [:code])
  end
end

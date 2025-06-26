defmodule Anoma.Repo.Migrations.CreateInvites do
  use Ecto.Migration

  def change do
    create table(:invites, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add :code, :string
      # references the person who can give out this invite
      add :owner_id, references(:users, on_delete: :nothing, type: :uuid)

      # references the person who is invited by this invite.
      add :invitee_id, references(:users, on_delete: :nothing, type: :uuid)

      timestamps(type: :utc_datetime)
    end

    create index(:invites, [:owner_id])
    create index(:invites, [:invitee_id])
    create unique_index(:invites, [:code])
  end
end

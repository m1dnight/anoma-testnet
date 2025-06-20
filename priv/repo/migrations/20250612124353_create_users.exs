defmodule Anoma.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add :email, :string
      add :confirmed_at, :utc_datetime
      add :points, :integer
      add :eth_address, :string

      timestamps(type: :utc_datetime)
    end
  end
end

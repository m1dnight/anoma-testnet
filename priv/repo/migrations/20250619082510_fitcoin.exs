defmodule Anoma.Repo.Migrations.Fitcoin do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :fitcoins, :integer, default: 0
    end
  end
end

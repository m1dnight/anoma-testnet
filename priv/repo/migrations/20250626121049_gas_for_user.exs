defmodule Anoma.Repo.Migrations.GasForUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :gas, :integer, default: 0
    end
  end
end

defmodule Anoma.Repo.Migrations.AddTwitterFieldsToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :twitter_id, :string
      add :twitter_username, :string
      add :twitter_name, :string
      add :twitter_avatar_url, :string
      add :twitter_bio, :string
      add :twitter_verified, :boolean, default: false
      add :twitter_public_metrics, :map
      add :auth_provider, :string
      add :auth_token, :string
    end

    create unique_index(:users, [:twitter_id])
    create unique_index(:users, [:twitter_username])
    create unique_index(:users, [:eth_address])
  end
end

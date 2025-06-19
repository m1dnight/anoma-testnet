defmodule Anoma.Accounts.User do
  use Ecto.Schema
  use TypedEctoSchema

  import Ecto.Changeset

  typed_schema "users" do
    @derive {Jason.Encoder, except: [:__meta__, :__struct__, :auth_token]}
    field :email, :string
    field :confirmed_at, :utc_datetime
    field :points, :integer, default: 0
    field :eth_address, :string

    # Fitcoin
    field :fitcoins, :integer, default: 0

    # Twitter fields (optional)
    field :twitter_id, :string
    field :twitter_username, :string
    field :twitter_name, :string
    field :twitter_avatar_url, :string
    field :twitter_bio, :string
    field :twitter_verified, :boolean, default: false
    field :twitter_public_metrics, :map
    field :auth_provider, :string
    field :auth_token, :string

    has_one :invite, Anoma.Accounts.Invite

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [
      :auth_provider,
      :auth_token,
      :confirmed_at,
      :email,
      :eth_address,
      :points,
      :twitter_avatar_url,
      :twitter_bio,
      :twitter_id,
      :twitter_name,
      :twitter_public_metrics,
      :twitter_username,
      :twitter_verified,
      :fitcoins
    ])
    |> validate_twitter_fields()
    |> unique_constraint(:twitter_id)
    |> unique_constraint(:twitter_username)
    |> unique_constraint(:eth_address)
  end

  # ----------------------------------------------------------------------------
  # Helpers

  defp validate_twitter_fields(changeset) do
    # If twitter_id is provided, require twitter_username as well
    case get_field(changeset, :twitter_id) do
      nil ->
        changeset

      _twitter_id ->
        changeset
        |> validate_required([:twitter_id, :twitter_username])
    end
  end
end

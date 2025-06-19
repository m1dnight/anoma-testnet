defmodule Anoma.Accounts.Invite do
  @moduledoc """
  Schema for an invite owned by a user.
  """
  use Ecto.Schema
  use TypedEctoSchema

  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  typed_schema "invites" do
    @derive {Jason.Encoder, except: [:__meta__, :__struct__, :user]}
    field :code, :string
    belongs_to :user, Anoma.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(invite, attrs) do
    invite
    |> cast(attrs, [:code])
    |> validate_required([:code])
    |> unique_constraint(:code)
  end
end

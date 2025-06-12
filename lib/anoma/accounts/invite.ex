defmodule Anoma.Accounts.Invite do
  use Ecto.Schema
  import Ecto.Changeset

  schema "invites" do
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

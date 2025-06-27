defmodule Anoma.Accounts.Coupon do
  @moduledoc """
  Schema for a daily coupon that a user can use in the daily lottery.
  """
  use Ecto.Schema
  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  typed_schema "coupons" do
    @derive {Jason.Encoder, except: [:__meta__, :__struct__, :owner, :owner_id,  :inserted_at, :updated_at]}
    # a coupon belongs to a user
    belongs_to :owner, Anoma.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(coupon, attrs) do
    coupon
    |> cast(attrs, [:owner_id])
    |> validate_required([:owner_id])
  end
end

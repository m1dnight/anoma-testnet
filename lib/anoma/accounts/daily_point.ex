defmodule Anoma.Accounts.DailyPoint do
  @moduledoc """
  Schema for a daily point that a user can claim.
  """
  use Ecto.Schema
  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  typed_schema "daily_points" do
    @derive {Jason.Encoder,
             except: [:__meta__, :__struct__, :user, :inserted_at, :updated_at, :user_id]}

    field :location, :string
    field :day, :date
    field :claimed, :boolean, default: false
    belongs_to :user, Anoma.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(daily_point, attrs) do
    daily_point
    |> cast(attrs, [:location, :day, :claimed, :user_id])
    |> validate_required([:location, :day, :user_id])
  end
end

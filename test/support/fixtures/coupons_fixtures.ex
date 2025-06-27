defmodule Anoma.Accounts.CouponsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Anoma.Accounts.Coupons` context.
  """
  alias Anoma.Accounts.Coupons

  @doc """
  Generate a coupon.
  """
  def coupon_fixture(attrs \\ %{}) do
    {:ok, coupon} =
      attrs
      |> Enum.into(%{})
      |> Coupons.create_coupon()

    coupon
  end
end

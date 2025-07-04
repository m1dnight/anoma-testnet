defmodule AnomaWeb.Api.CouponJSON do
  @doc """
  Render the daily coupons.
  """
  def coupons(%{coupons: coupons}) do
    %{coupons: for(coupon <- coupons, do: coupon(coupon))}
  end

  @doc """
  Returns success upon using a coupon
  """
  def use(%{coupon: _coupon}) do
    %{success: true}
  end

  @doc """
  Renders a single coupon.
  """
  def coupon(coupon) do
    coupon
  end
end

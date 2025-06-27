defmodule AnomaWeb.Api.CouponController do
  use AnomaWeb, :controller

  require Logger

  alias Anoma.Accounts.Coupons
  alias AnomaWeb.ApiSpec.Schemas.JsonError
  alias AnomaWeb.ApiSpec.Schemas.JsonSuccess
  alias OpenApiSpex.Schema

  action_fallback AnomaWeb.FallbackController

  use OpenApiSpex.ControllerSpecs
  tags ["Daily Coupons"]

  operation :list,
    security: [%{"authorization" => []}],
    summary: "List of available coupons",
    request_body: {},
    responses: %{
      200 =>
        {"success", "application/json",
         %Schema{
           type: :object,
           properties: %{
             coupons: %Schema{
               type: :array,
               items: %Schema{
                 type: :object,
                 properties: %{
                   id: %Schema{
                     type: :string,
                     description: "coupon id",
                     example: "846621ca-e843-426c-9ccd-09e1d57f8929"
                   }
                 }
               }
             }
           }
         }},
      400 => {"Generic error", "application/json", JsonError}
    }

  operation :use,
    security: [%{"authorization" => []}],
    summary: "Use a coupon",
    request_body: {},
    parameters: [
      id: [
        in: :path,
        description: "coupon id",
        type: :string,
        example: "9cb7c823-a2c3-4a3e-90c2-520125e084d2"
      ]
    ],
    responses: %{
      200 => {"Coupon used", "application/json", JsonSuccess},
      400 => {"Generic error", "application/json", JsonError}
    }

  @doc """
  Returns the list of coupons.
  """
  @spec list(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def list(conn, %{}) do
    user = conn.assigns.current_user
    coupons = Coupons.list_coupons(user)

    render(conn, :coupons, coupons: coupons)
  end

  @doc """
  Consumes a coupon
  """
  @spec use(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def use(conn, %{"id" => coupon_id}) do
    user = conn.assigns.current_user

    # make sure the coupon is owned by this user.
    coupon = Coupons.get_coupon!(coupon_id)

    # if this coupon is not owned by this user, can't consume it.
    if coupon.owner_id == user.id do
      {:ok, coupon} = Coupons.use_coupon(coupon)

      render(conn, :use, coupon: coupon)
    else
      {:error, :invalid_coupon}
    end
  end
end

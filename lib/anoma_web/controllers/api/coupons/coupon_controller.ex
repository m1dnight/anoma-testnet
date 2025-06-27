defmodule AnomaWeb.Api.CouponController do
  use AnomaWeb, :controller

  require Logger

  alias Anoma.Accounts.Coupons
  alias AnomaWeb.ApiSpec.Schemas.JsonError
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
  @spec list(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def list(conn, %{"id" => coupon_id}) do
    user = conn.assigns.current_user
    coupons = Coupons.list_coupons(user)

    render(conn, :coupons, coupons: coupons)
  end
end

defmodule AnomaWeb.Api.CouponController do
  use AnomaWeb, :controller

  require Logger

  alias Anoma.Accounts.Coupons
  alias AnomaWeb.ApiSpec.Schemas.JsonError
  alias OpenApiSpex.Schema

  action_fallback AnomaWeb.FallbackController

  use OpenApiSpex.ControllerSpecs
  tags ["daily coupons"]

  operation :list,
    security: [%{"authorization" => []}],
    summary: "Return the current fitcoin balance",
    parameters: [],
    responses: %{
      200 =>
        {"success", "application/json",
         %Schema{
           type: :object,
           properties: %{
             success: %Schema{type: :boolean, description: "success message", example: false},
             fitcoins: %Schema{type: :integer, description: "fitcoin balance", example: 123}
           }
         }},
      400 => {"Failed to authenticate", "application/json", JsonError}
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
end

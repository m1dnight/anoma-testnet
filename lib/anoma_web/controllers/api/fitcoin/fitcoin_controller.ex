defmodule AnomaWeb.Api.FitcoinController do
  use AnomaWeb, :controller

  require Logger

  alias Anoma.Accounts
  alias AnomaWeb.ApiSpec.Schemas.JsonError
  alias OpenApiSpex.Schema

  action_fallback AnomaWeb.FallbackController

  use OpenApiSpex.ControllerSpecs

  tags ["fitcoin"]

  operation :add,
    security: [%{"authorization" => []}],
    summary: "Add fitcoin to the account of the user",
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

  operation :balance,
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
  Adds 1 fitcoin to the user's account.
  """
  @spec add(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def add(conn, %{}) do
    user = conn.assigns.current_user
    {:ok, user} = Accounts.Fitcoin.add_fitcoin(user)

    render(conn, :balance, fitcoins: user.fitcoins)
  end

  def balance(conn, %{}) do
    user = conn.assigns.current_user
    {:ok, balance} = Accounts.Fitcoin.balance(user)

    render(conn, :balance, fitcoins: balance)
  end
end

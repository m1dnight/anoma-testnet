defmodule AnomaWeb.Api.UserController do
  use AnomaWeb, :controller

  require Logger

  alias Anoma.Accounts
  alias Anoma.Accounts.DailyPoints
  alias AnomaWeb.ApiSpec.Schemas.DailyPoint
  alias AnomaWeb.ApiSpec.Schemas.JsonError
  alias AnomaWeb.ApiSpec.Schemas.JsonSuccess
  alias AnomaWeb.ApiSpec.Schemas.User
  alias AnomaWeb.Plugs.AuthPlug
  alias AnomaWeb.Twitter
  alias OpenApiSpex.Schema

  action_fallback AnomaWeb.FallbackController

  use OpenApiSpex.ControllerSpecs

  tags ["users"]

  operation :auth,
    summary: "Authenticate with x.com parameters",
    parameters: [],
    request_body:
      {"auth parameters", "application/json",
       %Schema{
         type: :object,
         description: "Code and code verifier to obtain an access token from x.com",
         properties: %{
           code: %Schema{
             type: :string,
             description: "code value"
           },
           code_verifier: %Schema{
             type: :string,
             description: "code verifier value"
           }
         }
       }},
    responses: %{
      200 =>
        {"success", "application/json",
         %Schema{
           type: :object,
           properties: %{
             success: %Schema{type: :boolean, description: "success message", example: false},
             user: User,
             jwt: %Schema{type: :string, description: "jwt token", example: "1234567890"}
           }
         }},
      400 => {"Failed to authenticate", "application/json", JsonError}
    }

  operation :update_eth_address,
    security: [%{"authorization" => []}],
    summary: "Update the user's ethereum address",
    parameters: [],
    request_body:
      {"eth address", "application/json",
       %Schema{
         type: :object,
         description: "eth address",
         properties: %{
           address: %Schema{
             type: :string,
             description: "ethereum address",
             example: "0xdeadbeef"
           }
         }
       }},
    responses: %{
      200 => {"success", "application/json", JsonSuccess},
      401 => {"failed to update ethereum address", "application/json", JsonError}
    }

  operation :daily_points,
    security: [%{"authorization" => []}],
    summary: "Return the user's daily points",
    parameters: [],
    responses: %{
      200 =>
        {"success", "application/json",
         %Schema{
           type: :object,
           properties: %{
             success: %Schema{type: :boolean, description: "success message", example: false},
             daily_points: %Schema{
               description: "list of daily points for this user",
               type: :array,
               items: DailyPoint
             }
           },
           example: %{success: true, daily_points: [DailyPoint.schema().example]}
         }},
      401 => {"failed to update ethereum address", "application/json", JsonError}
    }

  operation :claim_point,
    security: [%{"authorization" => []}],
    summary: "Claim a daily point with the id of the point",
    parameters: [],
    request_body:
      {"eth address", "application/json",
       %Schema{
         type: :string,
         description: "point id",
         example: "0xdeadbeef"
       }},
    responses: %{
      200 =>
        {"success", "application/json",
         %Schema{
           type: :object,
           properties: %{
             success: %Schema{type: :boolean, description: "success message", example: false}
           },
           example: %{success: true}
         }},
      401 => {"failed to claim point", "application/json", JsonError}
    }

  @doc """
  The front-end calls this endpoint to let the backend obtain an access token
  for its profile.
  """
  @spec auth(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def auth(conn, %{"code" => code, "code_verifier" => code_verifier}) do
    with {:ok, access_token} <- Twitter.fetch_access_token(code, code_verifier),
         {:ok, user_meta_data} <- Twitter.fetch_user_meta_data(access_token),
         {:ok, db_user} <-
           Accounts.create_or_update_user_with_twitter_data(user_meta_data, access_token),
         token <- AuthPlug.generate_jwt_token(db_user) do
      json(conn, %{
        success: true,
        user: db_user,
        jwt: token
      })
    else
      {:error, reason} ->
        Logger.error("Error authenticating user: #{inspect(reason)}")

        conn
        |> put_status(:bad_request)
        |> json(%{success: false, error: reason})
    end
  end

  @doc """
  Assign an ethereum address to the user.
  """
  def update_eth_address(conn, %{"address" => eth_address}) do
    # update the user's ethereum address
    with user <- conn.assigns.current_user,
         {:ok, _user} <- Accounts.update_user_eth_address(user, eth_address) do
      json(conn, %{success: true})
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        error_message =
          Ecto.Changeset.traverse_errors(changeset, fn {msg, _} ->
            msg
          end)
          |> Enum.map_join(" ", fn {key, errs} ->
            "#{key}: #{Enum.join(errs, ",")}"
          end)

        {:error, error_message}
    end
  end

  @doc """
  Return the list of daily points the user can still claim.
  """
  def daily_points(conn, _params) do
    with user <- conn.assigns.current_user,
         daily_points <- DailyPoints.get_user_daily_points(user) do
      json(conn, %{success: true, daily_points: daily_points})
    end
  end

  @doc """
  Lets a user claim a daily point.
  """
  def claim_point(conn, %{"id" => id}) do
    with user <- conn.assigns.current_user,
         {:ok, daily_point} <- DailyPoints.get_daily_point(id) do
      owned? = daily_point.user.id == user.id
      claimed? = daily_point.claimed
      today? = daily_point.day == Date.utc_today()

      if owned? and not claimed? and today? do
        DailyPoints.claim_daily_point(daily_point)
        json(conn, %{success: true})
      else
        conn
        |> put_status(:forbidden)
        |> json(%{success: false, error: "cannot claim point"})
      end
    end
  end
end

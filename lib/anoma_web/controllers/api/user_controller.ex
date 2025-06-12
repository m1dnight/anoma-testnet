defmodule AnomaWeb.Api.UserController do
  use AnomaWeb, :controller

  require Logger

  alias Anoma.Accounts
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

  @doc """
  The front-end calls this endpoint to let the backend obtain an access token
  for its profile.
  """
  @spec auth(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def auth(conn, %{"code" => code, "code_verifier" => code_verifier}) do
    with {:ok, access_token} <- Twitter.fetch_access_token(code, code_verifier),
         {:ok, user_meta_data} <- Twitter.fetch_user_meta_data(access_token),
         meta_data <- Map.merge(user_meta_data, %{auth_token: access_token}),
         {:ok, db_user} <- Accounts.create_or_update_user_with_twitter_data(meta_data),
         {:ok, token} <- AuthPlug.generate_jwt_token(db_user) do
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
         {:ok, user} <- Accounts.update_user_eth_address(user, eth_address) do
      # broadcast the updated user to the channel
      AnomaWeb.Endpoint.broadcast("user:#{user.id}", "profile_update", %{
        type: "profile_update",
        user: user
      })

      json(conn, %{success: true})
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        error_message =
          Ecto.Changeset.traverse_errors(changeset, fn {msg, _} ->
            msg
          end)
          |> Enum.map(fn {key, errs} ->
            "#{key}: #{Enum.join(errs, ",")}"
          end)
          |> Enum.join(" ")

        {:error, error_message}
        |> IO.inspect(label: "error")
    end
  end
end

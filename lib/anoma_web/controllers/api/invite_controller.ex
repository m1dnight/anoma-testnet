defmodule AnomaWeb.Api.InviteController do
  use AnomaWeb, :controller

  alias Anoma.Accounts
  alias Anoma.Accounts.Invite
  alias AnomaWeb.ApiSpec.Schemas.JsonError
  alias AnomaWeb.ApiSpec.Schemas.JsonSuccess
  alias OpenApiSpex.Operation

  action_fallback AnomaWeb.FallbackController

  use OpenApiSpex.ControllerSpecs

  tags ["invites"]

  operation :redeem_invite,
    security: [%{"authorization" => []}],
    summary: "Redeem an invite code",
    parameters: [
      id: [in: :path, description: "invite code", type: :string, example: "let me in"]
    ],
    request_body: {},
    responses: %{
      401 => Operation.response("Failure", "application/json", JsonError),
      200 => Operation.response("Failure", "application/json", JsonSuccess)
    }

  def redeem_invite(conn, %{"invite_code" => invite_code}) do
    with user when not is_nil(user) <- Map.get(conn.assigns, :current_user),
         invite when not is_nil(invite) <- Accounts.get_invite_by_code!(invite_code),
         {:ok, %Invite{}} <- Accounts.claim_invite(invite, user) do
      json(conn, %{success: true})
    end
  end
end

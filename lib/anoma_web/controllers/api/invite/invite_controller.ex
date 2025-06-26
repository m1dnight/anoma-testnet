defmodule AnomaWeb.Api.InviteController do
  use AnomaWeb, :controller

  alias Anoma.Accounts.Invite
  alias Anoma.Invites
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

  @doc """
  Lets a user claim an invite code
  """
  def redeem_invite(conn, %{"invite_code" => invite_code}) do
    with user when not is_nil(user) <- Map.get(conn.assigns, :current_user),
         invite when not is_nil(invite) <- Invites.get_invite_by_code!(invite_code),
         {:ok, %Invite{}} <- Invites.claim_invite(invite, user) do
      render(conn, :redeem_invite)
    end
  end
end

defmodule AnomaWeb.InviteControllerTest do
  use AnomaWeb.ConnCase

  import Anoma.AccountsFixtures
  alias AnomaWeb.Plugs.AuthPlug

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "list invites" do
    test "renders empty invites", %{conn: conn} do
      user = user_fixture()

      # create a jwt for this user and add it as a header
      jwt = AuthPlug.generate_jwt_token(user)
      conn = put_req_header(conn, "authorization", "Bearer #{jwt}")

      # try and claim an invite
      conn = get(conn, ~p"/api/v1/invite")
      assert %{"invites" => []} = json_response(conn, 200)
    end

    test "renders invites", %{conn: conn} do
      user = user_fixture()
      invite = invite_fixture()
      Anoma.Invites.assign_invite(invite, user)
      # create a jwt for this user and add it as a header
      jwt = AuthPlug.generate_jwt_token(user)
      conn = put_req_header(conn, "authorization", "Bearer #{jwt}")

      # try and claim an invite
      conn = get(conn, ~p"/api/v1/invite")

      assert %{"invites" => [%{"code" => "some code", "claimed?" => false}]} =
               json_response(conn, 200)
    end

    test "renders invites that are claimed too", %{conn: conn} do
      user = user_fixture()
      invitee = user_fixture()
      invite = invite_fixture()
      Anoma.Invites.assign_invite(invite, user)
      Anoma.Invites.claim_invite(invite, invitee)

      # create a jwt for this user and add it as a header
      jwt = AuthPlug.generate_jwt_token(user)
      conn = put_req_header(conn, "authorization", "Bearer #{jwt}")

      # try and claim an invite
      conn = get(conn, ~p"/api/v1/invite")

      assert %{"invites" => [%{"code" => "some code", "claimed?" => true}]} =
               json_response(conn, 200)
    end
  end

  describe "claim invite" do
    test "renders invite when invite is valid", %{conn: conn} do
      user = user_fixture()
      invite = invite_fixture()

      # create a jwt for this user and add it as a header
      jwt = AuthPlug.generate_jwt_token(user)
      conn = put_req_header(conn, "authorization", "Bearer #{jwt}")

      # try and claim an invite
      conn = put(conn, ~p"/api/v1/invite/redeem/#{invite.code}")
      assert %{"success" => true} = json_response(conn, 200)
    end

    test "renders invite when invite is invalid", %{conn: conn} do
      user = user_fixture()
      invite = invite_fixture()

      # create a jwt for this user and add it as a header
      jwt = AuthPlug.generate_jwt_token(user)
      conn = put_req_header(conn, "authorization", "Bearer #{jwt}")

      # try and claim an invite
      assert_error_sent 404, fn ->
        put(conn, ~p"/api/v1/invite/redeem/#{invite.code <> "invalid"}")
      end
    end

    test "error when not logged in", %{conn: conn} do
      invite = invite_fixture()

      # try and claim an invite
      conn = put(conn, ~p"/api/v1/invite/redeem/#{invite.code}")
      assert "Unauthorized" = json_response(conn, 401)["error"]
    end
  end
end

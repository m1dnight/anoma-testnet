defmodule Anoma.InvitesTest do
  use Anoma.DataCase

  alias Anoma.Accounts

  describe "invites" do
    alias Anoma.Accounts.Invite
    import Anoma.AccountsFixtures

    @invalid_attrs %{code: nil}

    test "list_invites/0 returns all invites" do
      invite = invite_fixture()
      assert Accounts.list_invites() == [invite]
    end

    test "get_invite!/1 returns the invite with given id" do
      invite = invite_fixture()
      assert Accounts.get_invite!(invite.id) == invite
    end

    test "create_invite/1 with valid data creates a invite" do
      valid_attrs = %{code: "INVITE123"}

      assert {:ok, %Invite{} = invite} = Accounts.create_invite(valid_attrs)
      assert invite.code == "INVITE123"
    end

    test "create_invite/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_invite(@invalid_attrs)
    end

    test "update_invite/2 with valid data updates the invite" do
      invite = invite_fixture()
      update_attrs = %{code: "UPDATED123"}

      assert {:ok, %Invite{} = invite} = Accounts.update_invite(invite, update_attrs)
      assert invite.code == "UPDATED123"
    end

    test "update_invite/2 with invalid data returns error changeset" do
      invite = invite_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_invite(invite, @invalid_attrs)
      assert invite == Accounts.get_invite!(invite.id)
    end

    test "delete_invite/1 deletes the invite" do
      invite = invite_fixture()
      assert {:ok, %Invite{}} = Accounts.delete_invite(invite)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_invite!(invite.id) end
    end

    test "change_invite/1 returns a invite changeset" do
      invite = invite_fixture()
      assert %Ecto.Changeset{} = Accounts.change_invite(invite)
    end

    test "create_invite/1 generates unique codes" do
      {:ok, invite1} = Accounts.create_invite(%{code: "UNIQUE1"})
      {:ok, invite2} = Accounts.create_invite(%{code: "UNIQUE2"})
      assert invite1.code != invite2.code
    end

    test "create_invite/1 with duplicate code returns error" do
      {:ok, _invite} = Accounts.create_invite(%{code: "DUPLICATE"})
      assert {:error, %Ecto.Changeset{}} = Accounts.create_invite(%{code: "DUPLICATE"})
    end

    test "claim_invite/2 claims an invite" do
      user = user_fixture()
      invite = invite_fixture()
      assert {:ok, %Invite{} = invite} = Accounts.claim_invite(invite, user)
      assert invite.user_id == user.id
    end

    test "claim_invite/2 a claimed invite fails" do
      user = user_fixture()
      invite = invite_fixture()
      assert {:ok, %Invite{} = invite} = Accounts.claim_invite(invite, user)
      assert invite.user_id == user.id

      # claim second time and expect an error
      other_user = user_fixture()
      assert {:error, :invite_already_claimed} = Accounts.claim_invite(invite, other_user)

      # ensure the invite is still claimed by the first user
      invite = Accounts.get_invite!(invite.id)
      assert invite.user_id == user.id
    end
  end
end

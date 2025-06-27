defmodule AnomaWeb.Api.InviteJSON do
  @doc """
  Success after redeeming an invite.
  """
  def redeem_invite(_) do
    %{success: true}
  end

  @doc """
  Renders a list of invites.
  """
  def list_invites(%{invites: invites}) do
    %{invites: for(invite <- invites, do: invite(invite))}
  end

  @doc """
  Renders a single invite.
  """
  def invite(invite) do
    %{code: invite.code, claimed?: invite.invitee_id != nil}
  end
end

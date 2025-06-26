defmodule AnomaWeb.Api.InviteJSON do
  @doc """
  Success after redeeming an invite.
  """
  def redeem_invite(_) do
    %{success: true}
  end
end

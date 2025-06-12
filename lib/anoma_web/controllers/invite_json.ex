defmodule AnomaWeb.InviteJSON do
  alias Anoma.Accounts.Invite

  @doc """
  Renders a list of invites.
  """
  def index(%{invites: invites}) do
    %{data: for(invite <- invites, do: data(invite))}
  end

  @doc """
  Renders a single invite.
  """
  def show(%{invite: invite}) do
    %{data: data(invite)}
  end

  defp data(%Invite{} = invite) do
    %{
      id: invite.id,
      code: invite.code
    }
  end
end

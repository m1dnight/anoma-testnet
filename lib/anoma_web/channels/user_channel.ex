defmodule AnomaWeb.UserChannel do
  use AnomaWeb, :channel

  alias Anoma.Accounts
  alias AnomaWeb.Plugs.AuthPlug

  require Logger

  @impl true
  def join("user:" <> channel_user_id, %{"jwt" => jwt}, socket) do
    # verify the jwt token
    with {:ok, token} <- AuthPlug.verify_token(jwt),
         # fetch the user id from the token
         user_id <- Map.get(token, "user_id"),
         # query the user to ensure it really exists in the backend
         {:ok, user} <- Accounts.get_user(user_id) do
      # the user in the token should be the same as the user id in the channel
      if "#{user_id}" == channel_user_id do
        {:ok, user, socket}
      else
        {:error, %{reason: "unauthorized"}}
      end
    else
      # the user did not exist in the backend
      {:error, :not_found} ->
        {:error, %{reason: "user not found"}}
    end
  end

  @impl true
  def handle_in(msg, payload, socket) do
    IO.inspect(binding(), label: "user channel handle_in")
    {:noreply, socket}
  end
end

defmodule AnomaWeb.UserSocket do
  use Phoenix.Socket

  # Channels
  channel "user:*", AnomaWeb.UserChannel

  # Socket authentication - allow all connections for now
  @impl true
  def connect(_params, socket, _connect_info) do
    # Generate a simple session ID for this connection
    session_id = "session_#{generate_session_token()}"
    socket = assign(socket, :session_id, session_id)
    {:ok, socket}
  end

  # Socket id for disconnecting specific sessions
  @impl true
  def id(socket), do: "user_socket:#{socket.assigns.session_id}"

  # ----------------------------------------------------------------------------#
  #                                Sessions                                    #
  # ----------------------------------------------------------------------------#

  defp generate_session_token do
    :crypto.strong_rand_bytes(128)
    |> Base.url_encode64()
  end
end

defmodule AnomaWeb.Api.UserJSON do
  @doc """
  Renders the success authentication of a user.
  """
  def index(%{user: user, jwt: token}) do
    %{success: true, jwt: token, user: user}
  end

  @doc """
  Renders the success update ethereum address action.
  """
  def update_eth(_) do
    %{success: true}
  end

  @doc """
  Renders the success update ethereum address action.
  """
  def auth(%{user: user, jwt: token}) do
    %{success: true, user: user, jwt: token}
  end
end

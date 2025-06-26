defmodule AnomaWeb.Api.FitcoinJSON do
  @doc """
  Render the fitcoin balance.
  """
  def balance(%{fitcoins: fitcoins}) do
    %{success: true, fitcoins: fitcoins}
  end
end

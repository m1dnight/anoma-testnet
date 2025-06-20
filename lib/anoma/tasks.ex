defmodule Anoma.Tasks do
  @moduledoc """
  Defines a few functions that are being run as a task by the Quantum scheduler.
  """
  alias Anoma.Accounts.DailyPoints

  @doc """
  Create new rewards for all users
  """
  @daily_rewards 3
  def create_daily_rewards do
    Anoma.Accounts.list_users()
    |> Enum.flat_map(fn user ->
      # verify user has no dailies
      daily_points = DailyPoints.get_user_daily_points(user)

      if Enum.count(daily_points) >= 3 do
        []
      else
        for _ <- 1..@daily_rewards do
          attrs = %{
            user_id: user.id,
            location: Base.encode16(:crypto.strong_rand_bytes(64)),
            day: Date.utc_today()
          }

          {:ok, point} = DailyPoints.create_daily_point(attrs)
          point
        end
      end
    end)
  end
end

defmodule Anoma.Tasks do
  @moduledoc """
  Defines a few functions that are being run as a task by the Quantum scheduler.
  """
  alias Anoma.Accounts.DailyPoints
  alias Anoma.Invites

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

  @invite_count 10
  @doc """
  Generate invites for users.
  """
  def generate_invites do
    Anoma.Accounts.list_users()
    |> Enum.each(fn user ->
      invites = Invites.invites_for(user)

      for _ <- 1..(@invite_count - Enum.count(invites)) do
        code = Base.encode16(:crypto.strong_rand_bytes(8))
        {:ok, invite} = Invites.create_invite(%{code: code})
        Invites.assign_invite(invite, user)
      end
    end)
  end
end

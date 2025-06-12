defmodule Anoma.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Anoma.Accounts` context.
  """

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        confirmed_at: ~U[2025-06-11 12:43:00Z],
        email: "some email",
        eth_address: Base.encode16(:crypto.strong_rand_bytes(20)),
        points: 42
      })
      |> Anoma.Accounts.create_user()

    user
  end

  @doc """
  Generate a invite.
  """
  def invite_fixture(attrs \\ %{}) do
    {:ok, invite} =
      attrs
      |> Enum.into(%{
        code: "some code"
      })
      |> Anoma.Accounts.create_invite()

    invite
  end
end

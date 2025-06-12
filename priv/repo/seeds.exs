# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Anoma.Repo.insert!(%Anoma.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

# Script for populating the database with invite codes
alias Anoma.Repo
alias Anoma.Accounts.Invite

if Mix.env() == :dev do
  # Function to generate a unique invite code
  defmodule InviteCodeGenerator do
    def generate_code do
      # Generate a random string of 8 characters
      random = :crypto.strong_rand_bytes(4) |> Base.encode16(case: :lower)
      # Add timestamp to ensure uniqueness
      timestamp = DateTime.utc_now() |> DateTime.to_unix()
      # Combine and format
      "INV-#{random}-#{timestamp}"
    end
  end

  # Create 10 unique invite codes
  IO.puts("Creating 5000 invite codes...")

  Enum.each(1..10, fn _ ->
    code = InviteCodeGenerator.generate_code()

    %Invite{}
    |> Invite.changeset(%{code: code})
    |> Repo.insert!()
  end)

  IO.puts("Successfully created 5000 invite codes!")
end

defmodule Anoma.Invites do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false

  alias Anoma.Accounts
  alias Anoma.Accounts.Invite
  alias Anoma.Accounts.User
  alias Anoma.Repo

  require Logger

  @doc """
  Returns the list of invites.

  ## Examples

      iex> list_invites()
      [%Invite{}, ...]

  """
  def list_invites do
    Repo.all(Invite)
  end

  @doc """
  Retrieves an invite based on its code.

  ## Examples

      iex> get_invite_by_code!("INV-123456789")
      %Invite{}

      iex> get_invite_by_code!("nonexistent")
      nil
  """
  def get_invite_by_code!(code) do
    Repo.get_by!(Invite, code: code)
  end

  @doc """
  Gets a single invite.

  Raises `Ecto.NoResultsError` if the Invite does not exist.

  ## Examples

      iex> get_invite!(123)
      %Invite{}

      iex> get_invite!(456)
      ** (Ecto.NoResultsError)

  """
  def get_invite!(id), do: Repo.get!(Invite, id)

  @doc """
  Creates a invite.

  ## Examples

      iex> create_invite(%{field: value})
      {:ok, %Invite{}}

      iex> create_invite(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_invite(attrs \\ %{}) do
    %Invite{}
    |> Invite.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a invite.

  ## Examples

      iex> update_invite(invite, %{field: new_value})
      {:ok, %Invite{}}

      iex> update_invite(invite, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_invite(%Invite{} = invite, attrs) do
    invite
    |> Invite.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Claims an invite for a user.

  ## Examples

      iex> claim_invite(invite, user)
      {:ok, %Invite{}}

      iex> claim_invite(invite, user)
      {:error, %Ecto.Changeset{}}
  """
  def claim_invite(%Invite{} = invite, %User{} = user) do
    Repo.transaction(fn ->
      # ensure invite is not claimed
      invite = get_invite!(invite.id)
      user = Accounts.get_user!(user.id)

      cond do
        invite.owner_id != nil ->
          Repo.rollback(:invite_already_claimed)

        # user.invite != nil ->
        #   Repo.rollback(:user_already_claimed_invite)

        true ->
          invite
          |> Repo.preload(:owner)
          |> Invite.changeset(%{})
          |> Ecto.Changeset.put_assoc(:owner, user)
          |> Repo.update()
      end
    end)
    |> case do
      {:ok, res} ->
        res

      err ->
        err
    end
  end

  @doc """
  Deletes a invite.

  ## Examples

      iex> delete_invite(invite)
      {:ok, %Invite{}}

      iex> delete_invite(invite)
      {:error, %Ecto.Changeset{}}

  """
  def delete_invite(%Invite{} = invite) do
    Repo.delete(invite)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking invite changes.

  ## Examples

      iex> change_invite(invite)
      %Ecto.Changeset{data: %Invite{}}

  """
  def change_invite(%Invite{} = invite, attrs \\ %{}) do
    Invite.changeset(invite, attrs)
  end
end

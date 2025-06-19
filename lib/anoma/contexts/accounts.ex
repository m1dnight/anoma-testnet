defmodule Anoma.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false

  alias Anoma.Accounts.Invite
  alias Anoma.Accounts.User
  alias Anoma.Repo
  alias AnomaWeb.Twitter

  require Logger

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User) |> Repo.preload(:invite)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id) |> Repo.preload([:invite, :daily_points])

  @doc """
  Gets a single user.

  Returns {:ok, user} or {:error, :not_found}

  ## Examples

      iex> get_user(123)
      {:ok, %User{}}

      iex> get_user(456)
      {:error, :not_found}

  """
  def get_user(id) do
    case Repo.get(User, id) do
      nil -> {:error, :not_found}
      user -> {:ok, Repo.preload(user, [:invite, :daily_points])}
    end
  end

  @doc """
  Gets a user by Twitter ID.

  ## Examples

      iex> get_user_by_twitter_id("123456789")
      %User{}

      iex> get_user_by_twitter_id("nonexistent")
      nil

  """
  def get_user_by_twitter_id(twitter_id) do
    Repo.get_by(User, twitter_id: twitter_id) |> Repo.preload([:invite, :daily_points])
  end

  @doc """
  Creates a basic user with minimal required fields.

  ## Examples

      iex> create_basic_user()
      {:ok, %User{}}

  """
  def create_basic_user(attrs \\ %{}) do
    default_attrs = %{
      points: 0,
      confirmed_at: DateTime.utc_now()
    }

    attrs = Map.merge(default_attrs, attrs)

    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Adds Twitter data to an existing user or creates a new user if Twitter ID doesn't exist.

  ## Examples

      iex> add_twitter_data(%{twitter_id: "123", twitter_username: "user", ...})
      {:ok, %User{}}

  """
  @spec create_or_update_user_with_twitter_data(Twitter.user_meta_data(), String.t()) ::
          {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def create_or_update_user_with_twitter_data(twitter_data, access_token) do
    case get_user_by_twitter_id(twitter_data.id) do
      nil ->
        create_user_with_twitter_data(twitter_data, access_token)

      existing_user ->
        update_user_twitter_data(existing_user, twitter_data, access_token)
    end
  end

  @spec create_user_with_twitter_data(Twitter.user_meta_data(), String.t()) ::
          {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def create_user_with_twitter_data(twitter_data, access_token) do
    attrs = %{
      # twitter data
      twitter_id: twitter_data.id,
      twitter_username: twitter_data.username,
      twitter_name: twitter_data.name,
      twitter_avatar_url: twitter_data.profile_image_url,
      twitter_bio: twitter_data.description,
      twitter_verified: twitter_data.verified || false,
      twitter_public_metrics: twitter_data.public_metrics,
      # other data
      auth_provider: "twitter",
      auth_token: access_token,
      points: 0,
      confirmed_at: DateTime.utc_now()
    }

    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, user} ->
        {:ok, Repo.preload(user, [:invite, :daily_points])}

      err ->
        err
    end
  end

  @spec update_user_twitter_data(User.t(), Twitter.user_meta_data(), String.t()) ::
          {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def update_user_twitter_data(user, twitter_data, access_token) do
    attrs = %{
      # twitter data
      twitter_id: twitter_data.id,
      twitter_username: twitter_data.username,
      twitter_name: twitter_data.name,
      twitter_avatar_url: twitter_data.profile_image_url,
      twitter_bio: twitter_data.description,
      twitter_verified: twitter_data.verified || false,
      twitter_public_metrics: twitter_data.public_metrics,
      # other data
      auth_provider: "twitter",
      auth_token: access_token
    }

    user
    |> User.changeset(attrs)
    |> Repo.update()
    |> case do
      {:ok, user} ->
        {:ok, Repo.preload(user, [:invite, :daily_points])}

      err ->
        err
    end
  end

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, user} ->
        {:ok, Repo.preload(user, :invite)}

      err ->
        err
    end
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates a user's ETH address.

  ## Examples

      iex> update_user_eth_address(user, "0x1234...")
      {:ok, %User{}}

      iex> update_user_eth_address(user, invalid_address)
      {:error, %Ecto.Changeset{}}

  """
  def update_user_eth_address(%User{} = user, eth_address) do
    user
    |> User.changeset(%{eth_address: eth_address})
    |> Repo.update()
  end

  @doc """
  Adds points to a user's account.

  ## Examples

      iex> add_points_to_user(user, 100)
      {:ok, %User{}}

      iex> add_points_to_user(user, -50)
      {:ok, %User{}}

  """
  def add_points_to_user(%User{} = user, points) when is_integer(points) do
    current_points = user.points || 0
    new_points = current_points + points

    user
    |> User.changeset(%{points: new_points})
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  @doc """
  Returns the list of invites.

  ## Examples

      iex> list_invites()
      [%Invite{}, ...]

  """
  def list_invites do
    Repo.all(Invite) |> Repo.preload(:user)
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
    Repo.get_by!(Invite, code: code) |> Repo.preload(:user)
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
  def get_invite!(id), do: Repo.get!(Invite, id) |> Repo.preload(:user)

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
    |> case do
      {:ok, invite} ->
        {:ok, Repo.preload(invite, :user)}

      err ->
        err
    end
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
      user = get_user!(user.id)

      cond do
        invite.user_id != nil ->
          Repo.rollback(:invite_already_claimed)

        user.invite != nil ->
          Repo.rollback(:user_already_claimed_invite)

        true ->
          invite
          |> Repo.preload(:user)
          |> Invite.changeset(%{})
          |> Ecto.Changeset.put_assoc(:user, user)
          |> Repo.update()
          |> case do
            {:ok, invite} ->
              Repo.preload(invite, :user)

            {:error, changeset} ->
              Repo.rollback(changeset)
          end
      end
    end)
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

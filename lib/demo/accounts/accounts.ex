defmodule Demo.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Demo.Repo

  alias Demo.Accounts.User

  @topic inspect(__MODULE__)

  def subscribe do
    Phoenix.PubSub.subscribe(Demo.PubSub, @topic)
  end

  def subscribe(user_id) do
    Phoenix.PubSub.subscribe(Demo.PubSub, @topic <> "#{user_id}")
  end

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users(current_page, per_page) do
    Repo.all(
      from u in User,
        order_by: [asc: u.id],
        offset: ^((current_page - 1) * per_page),
        limit: ^per_page
    )
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
  def get_user!(id), do: Repo.get!(User, id)

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
    |> notify_subscribers([:user, :created])
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
    |> notify_subscribers([:user, :updated])
  end

  @doc """
  Deletes a User.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    user
    |> Repo.delete()
    |> notify_subscribers([:user, :deleted])
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{source: %User{}}

  """
  def change_user(user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  defp notify_subscribers({:ok, result}, event) do
    Phoenix.PubSub.broadcast(Demo.PubSub, @topic, {__MODULE__, event, result})
    Phoenix.PubSub.broadcast(Demo.PubSub, @topic <> "#{result.id}", {__MODULE__, event, result})
    {:ok, result}
  end

  defp notify_subscribers({:error, reason}, _event), do: {:error, reason}
end

defmodule Turbo.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset


  schema "users" do
    field :country, :string
    field :email, :string
    field :state, :string
    field :username, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :email, :state, :country])
    |> validate_required([:username, :email, :state, :country])
    |> validate_format(:email, ~r/.+@.+/, message: "must be a valid email address")
    |> unique_constraint(:email)
  end
end

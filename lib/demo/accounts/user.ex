defmodule Demo.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :username, :string
    field :email, :string
    field :phone_number, :string

    timestamps()
  end

  @phone ~r/\s?\+?[0-9.\-\s]+\s?$/

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :email, :phone_number])
    |> validate_required([:username, :email, :phone_number])
    |> validate_format(:username, ~r/^[a-zA-Z0-9_]*$/,
      message: "only letters, numbers, and underscores please"
    )
    |> validate_length(:username, max: 12)
    |> validate_format(:email, ~r/.+@.+/, message: "must be a valid email address")
    |> validate_format(:phone_number, @phone, message: "must be a valid number")
    |> unique_constraint(:email)
  end
end

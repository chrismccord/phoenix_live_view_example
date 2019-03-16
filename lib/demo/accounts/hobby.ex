defmodule Demo.Accounts.Hobby do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :title, :string
  end

  def changeset(hobby, attrs) do
    hobby
    |> cast(attrs, [:title])
    |> validate_required([:title])
    |> validate_length(:title, max: 20)
    |> validate_format(:title, ~r/^[a-zA-Z0-9_\s]*$/,
      message: "no special characters please"
    )
  end
end

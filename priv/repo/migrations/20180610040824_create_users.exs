defmodule Turbo.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :username, :string
      add :email, :string
      add :state, :string
      add :country, :string

      timestamps()
    end

    create unique_index(:users, :email)
  end
end

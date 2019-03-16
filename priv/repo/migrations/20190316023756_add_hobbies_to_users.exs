defmodule Demo.Repo.Migrations.AddHobbiesToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add(:hobbies, :map)
    end
  end
end

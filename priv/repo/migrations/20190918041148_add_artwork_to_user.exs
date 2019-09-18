defmodule Demo.Repo.Migrations.AddArtworkToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add(:artwork, :map)
    end
  end
end

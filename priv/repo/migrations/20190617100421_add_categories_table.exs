defmodule Dummy.Repo.Migrations.AddCategoriesTable do
  use Ecto.Migration

  def change do
    create table(:categories) do
      add :name, :string, null: false
      add :ancestry, :string
      add :ancestry_other, :string

      timestamps()
    end
  end
end

defmodule Dummy.CategoryColumn do
  @moduledoc false

  use Ecto.Schema

  use Ancestry,
    repo: Dummy.Repo,
    ancestry_column: :ancestry_other

  schema "categories" do
    field(:name, :string)
    field(:ancestry, :string)
    field(:ancestry_other, :string)

    timestamps()
  end
end

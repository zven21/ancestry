defmodule Dummy.Category do
  @moduledoc false

  use Ecto.Schema

  use Ancestry,
    repo: Dummy.Repo

  schema "categories" do
    field(:name, :string)
    field(:ancestry, :string)
    field(:ancestry_other, :string)

    timestamps()
  end
end

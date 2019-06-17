defmodule Dummy.Category do
  @moduledoc false

  use Ecto.Schema
  use Ancestry, repo: Dummy.Repo

  schema "categories" do
    field(:name, :string)
    field(:ancestry, :string)

    timestamps()
  end
end

defmodule Ancestry.AncestryColumnTest do
  @moduledoc """
  Test for `use Ancestry`, ancestry_column: :field
  """

  use ExUnit.Case

  defmodule Category do
    use Ecto.Schema

    use Ancestry,
      repo: Dummy.Repo,
      ancestry_column: :ancestry_other

    schema "categories" do
      field(:name, :string)
      field(:ancestry_other, :string)

      timestamps()
    end
  end

  defmodule Factory do
    use ExMachina.Ecto, repo: Dummy.Repo

    def category_factory do
      %Category{
        name: sequence(:name, &"name_#{&1}")
      }
    end
  end

  test "use Ancestry options ancestry_column" do
    root1 = Factory.insert(:category, name: "root")
    c1 = Factory.insert(:category, name: "c1", ancestry_other: "#{root1.id}")

    assert Category.is_only_child?(c1) == true
  end
end

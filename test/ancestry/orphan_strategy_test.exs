defmodule Ancestry.OrphanStrategyTest do
  @moduledoc """
  Test for `use Ancestry`, orphan_strategy: :value
  """

  use ExUnit.Case
  alias Dummy.Repo

  defmodule CategoryWithDestroy do
    use Ecto.Schema

    use Ancestry,
      repo: Dummy.Repo,
      orphan_strategy: :destroy

    schema "categories" do
      field(:name, :string)
      field(:ancestry, :string)

      timestamps()
    end
  end

  defmodule CategoryWithRootify do
    use Ecto.Schema

    use Ancestry,
      repo: Dummy.Repo,
      orphan_strategy: :rootify

    schema "categories" do
      field(:name, :string)
      field(:ancestry, :string)

      timestamps()
    end
  end

  defmodule CategoryWithRestrict do
    use Ecto.Schema

    use Ancestry,
      repo: Dummy.Repo,
      orphan_strategy: :restrict

    schema "categories" do
      field(:name, :string)
      field(:ancestry, :string)

      timestamps()
    end
  end

  defmodule CategoryWithBadValue do
    use Ecto.Schema

    use Ancestry,
      repo: Dummy.Repo,
      orphan_strategy: :bad_value

    schema "categories" do
      field(:name, :string)
      field(:ancestry, :string)

      timestamps()
    end
  end

  defmodule CategoryWithAdopt do
    use Ecto.Schema

    use Ancestry,
      repo: Dummy.Repo,
      orphan_strategy: :adopt

    schema "categories" do
      field(:name, :string)
      field(:ancestry, :string)

      timestamps()
    end
  end

  defmodule Factory do
    use ExMachina.Ecto, repo: Dummy.Repo

    def category_with_destroy_factory do
      %CategoryWithDestroy{
        name: sequence(:name, &"name_#{&1}")
      }
    end

    def category_with_rootify_factory do
      %CategoryWithRootify{
        name: sequence(:name, &"name_#{&1}")
      }
    end

    def category_with_adopt_factory do
      %CategoryWithAdopt{
        name: sequence(:name, &"name_#{&1}")
      }
    end

    def category_with_restrict_factory do
      %CategoryWithRestrict{
        name: sequence(:name, &"name_#{&1}")
      }
    end

    def category_with_bad_value_factory do
      %CategoryWithBadValue{
        name: sequence(:name, &"name_#{&1}")
      }
    end
  end

  describe "use Ancestry options orphan_strategy" do
    test ":destory" do
      root = Factory.insert(:category_with_destroy, name: "root")
      c1 = Factory.insert(:category_with_destroy, name: "c1", ancestry: "#{root.id}")
      c1a = Factory.insert(:category_with_destroy, name: "c1a", ancestry: "#{root.id}/#{c1.id}")

      CategoryWithDestroy.delete(root)
      assert Repo.get(CategoryWithDestroy, root.id) == nil
      assert Repo.get(CategoryWithDestroy, c1.id) == nil
      assert Repo.get(CategoryWithDestroy, c1a.id) == nil
    end

    test ":rootify" do
      root = Factory.insert(:category_with_rootify, name: "root")
      c1 = Factory.insert(:category_with_rootify, name: "c1", ancestry: "#{root.id}")
      c1a = Factory.insert(:category_with_rootify, name: "c1a", ancestry: "#{root.id}/#{c1.id}")

      CategoryWithRootify.delete(root)
      assert Repo.get(CategoryWithRootify, root.id) == nil
      assert Repo.get(CategoryWithRootify, c1.id).ancestry == nil
      assert Repo.get(CategoryWithRootify, c1a.id).ancestry == "#{c1.id}"
    end

    test ":restrict" do
      root = Factory.insert(:category_with_restrict, name: "root")
      c1 = Factory.insert(:category_with_restrict, name: "c1", ancestry: "#{root.id}")
      Factory.insert(:category_with_restrict, name: "c1a", ancestry: "#{root.id}/#{c1.id}")

      assert_raise Ancestry.RestrictError,
                   "Cannot delete record because it has descendants.",
                   fn ->
                     CategoryWithRestrict.delete(root)
                   end
    end

    test ":adopt" do
      root = Factory.insert(:category_with_adopt, name: "root")
      c1 = Factory.insert(:category_with_adopt, name: "c1", ancestry: "#{root.id}")
      c1a = Factory.insert(:category_with_adopt, name: "c1a", ancestry: "#{root.id}/#{c1.id}")

      CategoryWithAdopt.delete(c1)
      assert Repo.get(CategoryWithAdopt, root.id) == root
      assert Repo.get(CategoryWithAdopt, c1.id) == nil
      assert Repo.get(CategoryWithAdopt, c1a.id).ancestry == "#{root.id}"
    end

    test "with bad_value" do
      root = Factory.insert(:category_with_bad_value, name: "root")

      assert_raise RuntimeError, "orphan_strategy value bad_value not exist.", fn ->
        CategoryWithBadValue.delete(root)
      end
    end
  end
end

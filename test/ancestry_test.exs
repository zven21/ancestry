defmodule AncestryTest do
  use ExUnit.Case

  import Dummy.Factory

  alias Dummy.Category

  setup_all do
    {
      :ok,
      root_cate: insert(:category, name: "root_cate")
    }
  end

  test "roots" do
    assert Category.roots() |> length == 1
  end

  describe "ancestor" do
    test "ancestor_ids", context do
      root_cate = context[:root_cate]
      c1 = insert(:category, name: "c1", ancestry: "#{root_cate.id}")
      c2 = insert(:category, name: "c2", ancestry: "#{root_cate.id}/#{c1.id}")

      assert Category.ancestor_ids(c1) == [root_cate.id]
      assert Category.ancestor_ids(c2) == [root_cate.id, c1.id]
    end

    test "ancestors", context do
      root_cate = context[:root_cate]
      c1 = insert(:category, name: "c1", ancestry: "#{root_cate.id}")
      c2 = insert(:category, name: "c2", ancestry: "#{root_cate.id}/#{c1.id}")

      assert Category.ancestors(c1) == [root_cate]
      assert Category.ancestors(c2) == [root_cate, c1]
    end
  end
end

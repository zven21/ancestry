defmodule AncestryTest do
  use ExUnit.Case

  import Dummy.Factory

  alias Dummy.Category

  test "roots" do
    insert(:category)
    assert Category.roots() |> length == 1
  end

  describe "ancestor" do
    test "ancestor_ids" do
      root_cate = insert(:category)
      c1 = insert(:category, name: "c1", ancestry: "#{root_cate.id}")
      c1a = insert(:category, name: "c1a", ancestry: "#{root_cate.id}/#{c1.id}")

      assert Category.ancestor_ids(c1) == [root_cate.id]
      assert Category.ancestor_ids(c1a) == [root_cate.id, c1.id]
    end

    test "ancestors" do
      root_cate = insert(:category)
      c1 = insert(:category, name: "c1", ancestry: "#{root_cate.id}")
      c1a = insert(:category, name: "c1a", ancestry: "#{root_cate.id}/#{c1.id}")

      assert Category.ancestors(c1) == [root_cate]
      assert Category.ancestors(c1a) == [root_cate, c1]
    end
  end

  describe "children" do
    test "children" do
      root = insert(:category, name: "root")
      c1 = insert(:category, name: "c1", ancestry: "#{root.id}")
      c2 = insert(:category, name: "c2", ancestry: "#{root.id}")

      assert Category.children(root) == [c1, c2]
    end

    test "child_ids" do
      root = insert(:category, name: "root")
      c1 = insert(:category, name: "c1", ancestry: "#{root.id}")
      c2 = insert(:category, name: "c2", ancestry: "#{root.id}")

      assert Category.child_ids(root) == [c1.id, c2.id]
    end

    test "has_children?" do
      root = insert(:category, name: "root")
      insert(:category, name: "c1", ancestry: "#{root.id}")

      assert Category.has_children?(root) == true
    end
  end
end

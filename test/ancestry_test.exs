defmodule AncestryTest do
  use ExUnit.Case

  import Dummy.Factory

  alias Dummy.Category

  # test "roots" do
  #   root = insert(:category)
  #   assert Category.roots() == [root]
  # end

  describe "ancestor" do
    test "ancestor_ids" do
      root = insert(:category)
      c1 = insert(:category, name: "c1", ancestry: "#{root.id}")
      c1a = insert(:category, name: "c1a", ancestry: "#{root.id}/#{c1.id}")

      assert Category.ancestor_ids(c1) == [root.id]
      assert Category.ancestor_ids(c1a) == [root.id, c1.id]
    end

    test "ancestors" do
      root = insert(:category)
      c1 = insert(:category, name: "c1", ancestry: "#{root.id}")
      c1a = insert(:category, name: "c1a", ancestry: "#{root.id}/#{c1.id}")

      assert Category.ancestors(c1) == [root]
      assert Category.ancestors(c1a) == [root, c1]
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

    test "is_childless?" do
      root = insert(:category, name: "root")
      root2 = insert(:category, name: "root2")
      insert(:category, name: "c1", ancestry: "#{root2.id}")

      assert Category.is_childless?(root) == true
      assert Category.is_childless?(root2) == false
    end
  end

  describe "parent" do
    test "has_parent?" do
      root = insert(:category, name: "root")
      c1 = insert(:category, name: "c1", ancestry: "#{root.id}")
      assert Category.has_parent?(c1) == true
    end

    test "parent_id" do
      root = insert(:category, name: "root")
      c1 = insert(:category, name: "c1", ancestry: "#{root.id}")
      assert Category.parent_id(c1) == root.id
    end

    test "parent" do
      root = insert(:category, name: "root")
      c1 = insert(:category, name: "c1", ancestry: "#{root.id}")
      assert Category.parent(c1) == root
    end
  end

  describe "root" do
    test "root" do
      root = insert(:category)
      c1 = insert(:category, name: "c1", ancestry: "#{root.id}")
      c1a = insert(:category, name: "c1a", ancestry: "#{root.id}/#{c1.id}")

      assert Category.root(c1a) == root
    end

    test "root_id" do
      root = insert(:category)
      c1 = insert(:category, name: "c1", ancestry: "#{root.id}")
      c1a = insert(:category, name: "c1a", ancestry: "#{root.id}/#{c1.id}")

      assert Category.root_id(c1a) == root.id
    end

    test "is_root?" do
      root = insert(:category, name: "root")
      c1 = insert(:category, name: "c1", ancestry: "#{root.id}")

      assert Category.is_root?(root) == true
      assert Category.is_root?(c1) == false
    end
  end

  describe "siblings" do
    test "siblings" do
      root = insert(:category, name: "root")
      c1 = insert(:category, name: "c1", ancestry: "#{root.id}")
      c2 = insert(:category, name: "c2", ancestry: "#{root.id}")

      assert Category.siblings(c1) == [c1, c2]
      assert Category.siblings(root) == []
    end

    test "sibling_ids" do
      root = insert(:category, name: "root")
      c1 = insert(:category, name: "c1", ancestry: "#{root.id}")
      c2 = insert(:category, name: "c2", ancestry: "#{root.id}")

      assert Category.sibling_ids(c1) == [c1.id, c2.id]
      assert Category.sibling_ids(root) == []
    end

    test "has_siblings?" do
      root = insert(:category, name: "root")
      c1 = insert(:category, name: "c1", ancestry: "#{root.id}")
      insert(:category, name: "c2", ancestry: "#{root.id}")

      assert Category.has_siblings?(c1) == true
      assert Category.has_siblings?(root) == false
    end
  end
end

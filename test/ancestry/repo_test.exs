defmodule Ancestry.RepoTest do
  @moduledoc """
  Test for `use Ancestry`, orphan_strategy: :value
  """

  use ExUnit.Case

  import Dummy.Factory

  alias Dummy.Category

  test "get_ancestry_value with children" do
    root = insert(:category, name: "root")
    c1 = insert(:category, name: "c1", ancestry: "#{root.id}")

    assert Category.get_ancestry_value(root, "children") == "#{root.id}"
    assert Category.get_ancestry_value(c1, "children") == "#{root.id}/#{c1.id}"
  end

  test "gen_ancesty_value with siblings" do
    root = insert(:category, name: "root")
    c1 = insert(:category, name: "c1", ancestry: "#{root.id}")

    assert Category.get_ancestry_value(root, "siblings") == nil
    assert Category.get_ancestry_value(c1, "siblings") == "#{root.id}"
  end

  test "gen_ancesty_value with default value" do
    root = insert(:category, name: "root")
    c1 = insert(:category, name: "c1", ancestry: "#{root.id}")

    assert Category.get_ancestry_value(root) == "#{root.id}"
    assert Category.get_ancestry_value(c1) == "#{root.id}/#{c1.id}"
  end

  test "arrange" do
    root = insert(:category, name: "root")
    c1 = insert(:category, name: "c1", ancestry: "#{root.id}")
    c2 = insert(:category, name: "c2", ancestry: "#{root.id}")
    c1a = insert(:category, name: "c1a", ancestry: "#{root.id}/#{c1.id}")
    c2a = insert(:category, name: "c2a", ancestry: "#{root.id}/#{c2.id}")

    assert Category.arrange(root) ==
             Map.merge(root, %{
               children: [
                 Map.merge(c1, %{children: [c1a]}),
                 Map.merge(c2, %{children: [c2a]})
               ]
             })
  end
end

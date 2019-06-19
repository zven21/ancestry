defmodule Ancestry.RepoTest do
  @moduledoc """
  Test for `use Ancestry`, orphan_strategy: :value
  """

  use ExUnit.Case

  import Dummy.Factory

  alias Dummy.Category

  test "gen_ancestry_value with children" do
    root = insert(:category, name: "root")
    c1 = insert(:category, name: "c1", ancestry: "#{root.id}")

    assert Category.gen_ancestry_value(root, "children") == "#{root.id}"
    assert Category.gen_ancestry_value(c1, "children") == "#{root.id}/#{c1.id}"
  end

  test "gen_ancesty_value with siblings" do
    root = insert(:category, name: "root")
    c1 = insert(:category, name: "c1", ancestry: "#{root.id}")

    assert Category.gen_ancestry_value(root, "siblings") == nil
    assert Category.gen_ancestry_value(c1, "siblings") == "#{root.id}"
  end

  test "gen_ancesty_value with default value" do
    root = insert(:category, name: "root")
    c1 = insert(:category, name: "c1", ancestry: "#{root.id}")

    assert Category.gen_ancestry_value(root) == "#{root.id}"
    assert Category.gen_ancestry_value(c1) == "#{root.id}/#{c1.id}"
  end
end
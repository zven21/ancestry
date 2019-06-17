defmodule AncestryTest do
  use ExUnit.Case

  import Dummy.Factory

  alias Dummy.Category

  setup_all do
    {
      :ok,
      base_cate: insert(:category, name: "base_cate")
    }
  end

  test "roots" do
    assert Category.roots() |> length == 1
  end
end

defmodule Ancestry.Repo do
  @moduledoc false

  alias Ecto.Changeset

  @doc """
  Arrange an entire subtree into nested hashes for
  easy navigation after retrieval from the database.
  """
  @spec arrange(Ecto.Schema.t(), any, any) :: Map.t()
  def arrange(record, _opts, module) do
    case module.has_children?(record) do
      true ->
        Map.merge(record, %{children: do_build_children(record, module)})

      false ->
        record
    end
  end

  defp do_build_children(record, module) do
    record
    |> module.children()
    |> Enum.map(fn x ->
      case module.has_children?(x) do
        true ->
          Map.merge(x, %{children: do_build_children(x, module)})

        false ->
          x
      end
    end)
  end

  @doc """
  Get ancestry value
  """
  @spec get_ancestry_value(Ecto.Schema.t(), String.t(), any, any) :: String.t()
  def get_ancestry_value(record, "children", opts, module) do
    case module.is_root?(record) do
      true -> "#{record.id}"
      false -> "#{record |> Map.get(opts[:ancestry_column])}/#{record.id}"
    end
  end

  @spec get_ancestry_value(Ecto.Schema.t(), String.t(), any, any) :: String.t()
  def get_ancestry_value(record, "siblings", opts, _),
    do: record |> Map.get(opts[:ancestry_column])

  @doc """
  Delete ancestry

  ## orphan_strategy

    * :destroy   All children are destroyed as well (default).
    * :rootify   The children of the destroyed node become root nodes.
    * :restrict  An AncestryException is raised if any children exist.
    * :adopt     The orphan subtree is added to the parent of the deleted node.

  """
  def delete(record, opts, module) do
    prefix = opts[:prefix]
    repo = opts[:repo]

    repo.transaction(fn ->
      model = repo.delete!(record, prefix: prefix)
      handle_orphan_strategy(record, opts, module, prefix)
      model
    end)
  end

  defp handle_orphan_strategy(record, opts, module, prefix),
    do: do_handle_orphan_strategy(record, module, opts, opts[:orphan_strategy], prefix)

  # destroy
  defp do_handle_orphan_strategy(record, module, opts, :destroy, prefix) do
    record
    |> module.descendants_query()
    |> opts[:repo].delete_all(prefix: prefix)
  end

  # rootify
  defp do_handle_orphan_strategy(record, module, opts, :rootify, prefix) do
    child_ancestry = module.child_ancestry(record)

    record
    |> module.descendants()
    |> Enum.each(fn x ->
      new_ancestry =
        case x |> Map.get(opts[:ancestry_column]) do
          ^child_ancestry ->
            nil

          _ ->
            x
            |> Map.get(opts[:ancestry_column])
            |> String.replace(~r/^#{child_ancestry}\//, "")
        end

      x
      |> Changeset.change(%{opts[:ancestry_column] => new_ancestry})
      |> opts[:repo].update!(prefix: prefix)
    end)
  end

  # restrict
  defp do_handle_orphan_strategy(record, module, _, :restrict, _) do
    if module.has_children?(record), do: raise(Ancestry.RestrictError)
  end

  # adopt
  defp do_handle_orphan_strategy(record, module, opts, :adopt, prefix) do
    record
    |> module.descendants(prefix)
    |> Enum.each(fn descendant ->
      new_ancestry =
        module.ancestor_ids(descendant)
        |> Enum.reject(fn x -> x == record.id end)
        |> Enum.join("/")

      new_ancestry =
        case new_ancestry do
          "" -> nil
          _ -> new_ancestry
        end

      descendant
      |> Changeset.change(%{opts[:ancestry_column] => new_ancestry})
      |> opts[:repo].update!(prefix: prefix)
    end)
  end

  defp do_handle_orphan_strategy(_, _, opts, _, _),
    do: raise("orphan_strategy value #{opts[:orphan_strategy]} not exist.")
end

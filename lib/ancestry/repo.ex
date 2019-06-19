defmodule Ancestry.Repo do
  @moduledoc false

  @doc """
  Delete ancestry

  ## orphan_strategy

    * :destroy   All children are destroyed as well (default).
    * :rootify   The children of the destroyed node become root nodes.
    * :restrict  An AncestryException is raised if any children exist.
    * :adopt     The orphan subtree is added to the parent of the deleted node.

  """

  alias Ecto.Changeset

  def get_ancestry_value(record, "children", opts, module) do
    case module.is_root?(record) do
      true -> "#{record.id}"
      false -> "#{record |> Map.get(opts[:ancestry_column])}/#{record.id}"
    end
  end

  def get_ancestry_value(record, "siblings", opts, _),
    do: record |> Map.get(opts[:ancestry_column])

  def delete(record, opts, module) do
    repo = opts[:repo]

    repo.transaction(fn ->
      model = repo.delete!(record)
      handle_orphan_strategy(record, opts, module)
      model
    end)
  end

  defp handle_orphan_strategy(record, opts, module),
    do: do_handle_orphan_strategy(record, module, opts, opts[:orphan_strategy])

  # destroy
  defp do_handle_orphan_strategy(record, module, opts, :destroy) do
    record
    |> module.descendants_query()
    |> opts[:repo].delete_all()
  end

  # rootify
  defp do_handle_orphan_strategy(record, module, opts, :rootify) do
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
      |> opts[:repo].update!()
    end)
  end

  # restrict
  defp do_handle_orphan_strategy(record, module, _, :restrict) do
    if module.has_children?(record), do: raise(Ancestry.RestrictError)
  end

  # adopt
  defp do_handle_orphan_strategy(record, module, opts, :adopt) do
    record
    |> module.descendants()
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
      |> opts[:repo].update!()
    end)
  end

  defp do_handle_orphan_strategy(_, _, opts, _),
    do: raise("orphan_strategy value #{opts[:orphan_strategy]} not exist.")
end

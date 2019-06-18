defmodule Ancestry do
  @moduledoc """
  Documentation for Ancestry.
  """

  defmacro __using__(opts) do
    quote do
      import unquote(__MODULE__)
      @ancestry_opts unquote(opts)
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(%{module: module}) do
    ancestry_opts = Module.get_attribute(module, :ancestry_opts)
    repo = ancestry_opts[:repo]

    quote do
      import Ecto.Query

      @doc """
      Gets Root nodes.
      """
      def roots do
        query =
          from(u in unquote(module),
            where: is_nil(u.ancestry) or u.ancestry == ""
          )

        unquote(repo).all(query)
      end

      @doc """
      Gets ancestor ids of the record
      """
      def ancestor_ids(record) do
        record.ancestry
        |> parse_ancestry_column()
      end

      @doc """
      Retutns ancestors of the record, starting with the root and ending with the parent
      """
      def ancestors(record) do
        case ancestor_ids(record) do
          nil ->
            nil

          ancestors ->
            query =
              from(u in unquote(module),
                where: u.id in ^ancestors
              )

            unquote(repo).all(query)
        end
      end

      @doc """
      Returns true if the record is a root node, false otherwise
      """
      def is_root?(record) do
        case record.ancestry do
          "" -> true
          nil -> true
          _ -> false
        end
      end

      @doc """
      Gets root of the record's tree, self for a root node
      """
      def root(record) do
        unquote(repo).get!(unquote(module), root_id(record))
      end

      @doc """
      Gets root id of the record's tree, self for a root node
      """
      def root_id(record) do
        case is_root?(record) do
          true ->
            record.id

          false ->
            record.ancestry
            |> String.split("/")
            |> hd
            |> String.to_integer()
        end
      end

      @doc """
      Direct children of the record
      """
      def children(record) do
        record
        |> children_query()
        |> unquote(repo).all()
      end

      @doc """
      Direct children's ids
      """
      def child_ids(record) do
        record
        |> children()
        |> Enum.map(fn child -> Map.get(child, :id) end)
      end

      @doc """
      Returns true if the record has any children, false otherwise
      """
      def has_children?(record) do
        record
        |> children()
        |> length
        |> Kernel.>(0)
      end

      @doc """
      Gets parent of the record, nil for a root node
      """
      def parent(record) do
        case parent_id(record) do
          nil -> nil
          id -> unquote(repo).get!(unquote(module), id)
        end
      end

      @doc """
      Gets parent id of the record, nil for a root node
      """
      def parent_id(record) do
        case ancestor_ids(record) do
          nil ->
            nil

          ancestors ->
            ancestors |> List.last()
        end
      end

      @doc """
      Returns true if the record has a parent, false otherwise
      """
      def has_parent?(record) do
        case parent_id(record) do
          nil -> false
          _ -> true
        end
      end

      defp child_ancestry(record) do
        case is_root?(record) do
          true -> "#{record.id}"
          false -> "#{record.ancestry}/#{record.id}"
        end
      end

      defp children_query(record) do
        query =
          from(u in unquote(module),
            where: u.ancestry == ^child_ancestry(record)
          )
      end

      defp parse_ancestry_column(nil), do: nil

      defp parse_ancestry_column(field) do
        field
        |> String.split("/")
        |> Enum.map(fn x -> String.to_integer(x) end)
      end
    end
  end
end

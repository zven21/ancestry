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

    default_opts = [
      ancestry_column: :ancestry,
      orphan_strategy: :destroy
    ]

    opts = Keyword.merge(default_opts, ancestry_opts)

    quote do
      import Ecto.Query

      @doc """
      Gets Root nodes.
      """
      @spec roots() :: Enum.t()
      def roots do
        query =
          from(
            u in unquote(module),
            where:
              fragment(
                unquote("#{opts[:ancestry_column]} IS NULL OR #{opts[:ancestry_column]} = ''")
              )
          )

        unquote(opts[:repo]).all(query)
      end

      @doc """
      Gets ancestor ids of the record
      """
      @spec ancestor_ids(Ecto.Schema.t()) :: Enum.t()
      def ancestor_ids(record) do
        record.unquote(opts[:ancestry_column])
        |> parse_ancestry_column()
      end

      @doc """
      Retutns ancestors of the record, starting with the root and ending with the parent
      """
      @spec ancestors(Ecto.Schema.t()) :: Enum.t()
      def ancestors(record) do
        case ancestor_ids(record) do
          nil ->
            nil

          ancestors ->
            query =
              from(
                u in unquote(module),
                where: u.id in ^ancestors
              )

            unquote(opts[:repo]).all(query)
        end
      end

      @doc """
      Returns true if the record is a root node, false otherwise
      """
      @spec is_root?(Ecto.Schema.t()) :: true | false
      def is_root?(record) do
        case record.unquote(opts[:ancestry_column]) do
          "" -> true
          nil -> true
          _ -> false
        end
      end

      @doc """
      Gets root of the record's tree, self for a root node
      """
      @spec root(Ecto.Schema.t()) :: Ecto.Schema.t()
      def root(record) do
        unquote(opts[:repo]).get!(unquote(module), root_id(record))
      end

      @doc """
      Gets root id of the record's tree, self for a root node
      """
      @spec root_id(Ecto.Schema.t()) :: integer
      def root_id(record) do
        case is_root?(record) do
          true ->
            record.id

          false ->
            record.unquote(opts[:ancestry_column])
            |> parse_ancestry_column()
            |> hd()
        end
      end

      @doc """
      Direct children of the record
      """
      @spec children(Ecto.Schema.t()) :: Enum.t()
      def children(record) do
        record
        |> do_children_query()
        |> unquote(opts[:repo]).all()
      end

      @doc """
      Direct children's ids
      """
      @spec child_ids(Ecto.Schema.t()) :: Enum.t()
      def child_ids(record) do
        record
        |> children()
        |> Enum.map(fn child -> Map.get(child, :id) end)
      end

      @doc """
      Returns true if the record has any children, false otherwise
      """
      @spec has_children?(Ecto.Schema.t()) :: true | false
      def has_children?(record) do
        record
        |> children()
        |> length
        |> Kernel.>(0)
      end

      @doc """
      Returns true is the record has no children, false otherwise
      """
      @spec is_childless?(Ecto.Schema.t()) :: true | false
      def is_childless?(record) do
        not has_children?(record)
      end

      @doc """
      Gets parent of the record, nil for a root node
      """
      @spec parent(Ecto.Schema.t()) :: nil | Ecto.Schema.t()
      def parent(record) do
        case parent_id(record) do
          nil -> nil
          id -> unquote(opts[:repo]).get!(unquote(module), id)
        end
      end

      @doc """
      Gets parent id of the record, nil for a root node
      """
      @spec parent_id(Ecto.Schema.t()) :: nil | integer
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
      @spec has_parent?(Ecto.Schema.t()) :: true | false
      def has_parent?(record) do
        case parent_id(record) do
          nil -> false
          _ -> true
        end
      end

      @doc """
      Gets siblings of the record, the record itself is included
      """
      @spec siblings(Ecto.Schema.t()) :: Enum.t()
      def siblings(record) do
        record
        |> do_siblings_query()
        |> unquote(opts[:repo]).all()
      end

      @doc """
      Gets sibling ids
      """
      @spec sibling_ids(Ecto.Schema.t()) :: Enum.t()
      def sibling_ids(record) do
        record
        |> siblings()
        |> Enum.map(fn x -> Map.get(x, :id) end)
      end

      @doc """
      Returns true if the record's parent has more than one child
      """
      @spec has_siblings?(Ecto.Schema.t()) :: true | false
      def has_siblings?(record) do
        record
        |> siblings()
        |> length()
        |> Kernel.>(0)
      end

      @doc """
      Returns true if the record is the only child of its parent.
      """
      @spec is_only_child?(Ecto.Schema.t()) :: true | false
      def is_only_child?(record) do
        siblings(record) == [record]
      end

      defp do_siblings_query(record) do
        query =
          from(
            u in unquote(module),
            where:
              fragment(
                unquote("#{opts[:ancestry_column]} = ?"),
                ^record.unquote(opts[:ancestry_column])
              )
          )
      end

      defp do_children_query(record) do
        query =
          from(
            u in unquote(module),
            where:
              fragment(
                unquote("#{opts[:ancestry_column]} = ?"),
                ^child_ancestry(record)
              )
          )
      end

      defp child_ancestry(record) do
        case is_root?(record) do
          true -> "#{record.id}"
          false -> "#{record.unquote(opts[:ancestry_column])}/#{record.id}"
        end
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

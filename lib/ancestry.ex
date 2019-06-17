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

      def roots do
        query =
          from(u in unquote(module),
            where: is_nil(u.ancestry) or u.ancestry == ""
          )

        unquote(repo).all(query)
      end

      def ancestor_ids(record) do
        record.ancestry
        |> parse_ancestry_column()
      end

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

      defp parse_ancestry_column(nil), do: nil

      defp parse_ancestry_column(field) do
        field
        |> String.split("/")
        |> Enum.map(fn x -> String.to_integer(x) end)
      end
    end
  end
end

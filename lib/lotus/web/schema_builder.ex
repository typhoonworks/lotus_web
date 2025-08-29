defmodule Lotus.Web.SchemaBuilder do
  @moduledoc "Builds DB schemas for the editor."

  def build(data_repo) do
    case Lotus.list_tables(data_repo) do
      {:ok, tables} ->
        schema =
          tables
          |> Enum.reduce(%{}, fn {_schema, table}, acc ->
            case Lotus.get_table_schema(data_repo, table) do
              {:ok, columns} ->
                column_names = Enum.map(columns, & &1.name)
                Map.put(acc, table, column_names)

              {:error, _} ->
                acc
            end
          end)

        {:ok, schema}

      {:error, reason} ->
        {:error, reason}
    end
  end
end

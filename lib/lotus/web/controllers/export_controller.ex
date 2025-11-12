defmodule Lotus.Web.ExportController do
  @moduledoc """
  Controller for streaming CSV exports.
  """

  use Phoenix.Controller, formats: [:csv]

  alias Lotus.Export
  alias Lotus.Storage.Query

  plug(:fetch_query_params)

  @max_age 300

  @doc """
  Streams a CSV export directly to the response.

  Expects a signed token containing:
  - query_id: ID of the query to export
  - repo: data repository name
  - vars: variable values
  - search_path: optional search path
  - filename: suggested filename for download
  """
  def csv(conn, %{"token" => token}) do
    endpoint = Phoenix.Controller.endpoint_module(conn)

    case Phoenix.Token.decrypt(endpoint, secret(endpoint), token, max_age: @max_age) do
      {:ok, export_params} ->
        stream_csv_export(conn, export_params)

      {:error, :expired} ->
        conn
        |> put_status(:unauthorized)
        |> text("Export link has expired. Please try again")

      {:error, _reason} ->
        conn
        |> put_status(:unauthorized)
        |> text("Invalid export token")
    end
  end

  def csv(conn, _params) do
    conn
    |> put_status(:bad_request)
    |> text("Missing export token.")
  end

  defp stream_csv_export(conn, export_params) do
    case build_query(export_params) do
      %Query{} = query ->
        filename = Map.get(export_params, "filename", "export.csv")

        conn
        |> put_resp_content_type("text/csv")
        |> put_resp_header("content-disposition", ~s(attachment; filename="#{filename}"))
        |> send_chunked(200)
        |> stream_chunks(query, export_params)

      nil ->
        conn
        |> put_status(:not_found)
        |> text("Query not found.")
    end
  end

  defp build_query(%{"query_id" => query_id}) when not is_nil(query_id) do
    Lotus.get_query(query_id)
  end

  defp build_query(%{"query_attrs" => attrs} = params) do
    # Build query struct from attributes (for unsaved queries)
    %Query{
      statement: attrs["statement"],
      data_repo: params["repo"],
      search_path: params["search_path"],
      variables: build_variables(attrs["variables"] || [])
    }
  end

  defp build_query(_), do: nil

  defp build_variables(variables) when is_list(variables) do
    Enum.map(variables, fn var ->
      struct(Lotus.Storage.QueryVariable, var)
    end)
  end

  defp build_variables(_), do: []

  defp stream_chunks(conn, query, export_params) do
    repo = export_params["repo"]
    vars = export_params["vars"] || %{}
    search_path = export_params["search_path"]

    opts = [repo: repo, vars: vars]

    opts =
      if search_path && String.trim(search_path) != "" do
        Keyword.put(opts, :search_path, search_path)
      else
        opts
      end

    query
    |> Export.stream_csv(opts)
    |> Enum.reduce_while(conn, fn chunk, conn ->
      case chunk(conn, chunk) do
        {:ok, conn} -> {:cont, conn}
        {:error, :closed} -> {:halt, conn}
      end
    end)
  end

  @doc """
  Generates a signed token for export.

  Returns a signed token valid for #{@max_age} seconds.
  """
  def generate_token(endpoint, params) do
    Phoenix.Token.encrypt(endpoint, secret(endpoint), params, max_age: @max_age)
  end

  defp secret(endpoint), do: "lotus:" <> endpoint.config(:secret_key_base)
end

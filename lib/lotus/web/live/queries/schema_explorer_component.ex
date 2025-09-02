defmodule Lotus.Web.Queries.SchemaExplorerComponent do
  @moduledoc """
  A drawer component for browsing database tables and columns.
  """
  use Lotus.Web, :live_component

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <div
      class={[
        "absolute top-0 right-0 h-full w-80 bg-white dark:bg-gray-800 border-l border-gray-200 dark:border-gray-700 z-10 transition-transform duration-300 ease-in-out overflow-hidden",
        if(@visible, do: "translate-x-0", else: "translate-x-full")
      ]}
    >
      <%= if @visible do %>
        <div class="h-full flex flex-col">
          <.header {assigns} />
          <.content {assigns} />
        </div>
      <% end %>
    </div>
    """
  end

  defp header(assigns) do
    ~H"""
    <div class="px-4 py-3 border-b border-gray-200 dark:border-gray-700 bg-gray-50 dark:bg-gray-700">
      <div class="flex items-center justify-between">
        <.header_title {assigns} />
        <.close_button parent={@parent} />
      </div>
      <.header_subtitle {assigns} />
    </div>
    """
  end

  defp header_title(assigns) do
    ~H"""
    <%= case @view_mode do %>
      <% :databases -> %>
        <h3 class="text-sm font-medium text-text-light dark:text-text-dark">Data Reference</h3>
      <% :tables -> %>
        <div class="flex items-center">
          <.back_button target={@myself} />
          <h3 class="text-sm font-medium text-text-light dark:text-text-dark"><%= @current_database %></h3>
        </div>
      <% :columns -> %>
        <div class="flex items-center">
          <.back_button target={@myself} />
          <h3 class="text-sm font-medium text-text-light dark:text-text-dark"><%= @current_table %></h3>
        </div>
    <% end %>
    """
  end

  defp back_button(assigns) do
    ~H"""
    <button
      type="button"
      phx-click="navigate_back"
      phx-target={@target}
      class="p-1 mr-2 text-gray-400 dark:text-gray-500 hover:text-gray-600 dark:hover:text-gray-400"
    >
      <Icons.chevron_left class="h-3 w-3" />
    </button>
    """
  end

  defp close_button(assigns) do
    ~H"""
    <button
      type="button"
      phx-click="close_schema_explorer"
      phx-target={@parent}
      class="p-1 text-gray-400 dark:text-gray-500 hover:text-gray-600 dark:hover:text-gray-400"
    >
      <Icons.x_mark class="h-4 w-4" />
    </button>
    """
  end

  defp header_subtitle(assigns) do
    ~H"""
    <%= case @view_mode do %>
      <% :databases -> %>
        <p class="text-xs text-gray-500 dark:text-gray-400 mt-1">Browse the contents of your databases, tables, and columns. Pick a database to get started.</p>
      <% :tables -> %>
        <div class="flex items-center mt-2 text-xs text-gray-600 dark:text-gray-400">
          <Icons.tables class="h-3 w-3 mr-1" />
          <%= length(@tables) %> tables
        </div>
      <% :columns -> %>
        <p class="text-xs text-gray-500 dark:text-gray-400 mt-1">No description</p>
        <div class="flex items-center mt-2 text-xs text-gray-600 dark:text-gray-400">
          <Icons.tables class="h-3 w-3 mr-1" />
          <%= length(@columns) %> columns
        </div>
    <% end %>
    """
  end

  defp content(assigns) do
    ~H"""
    <div class="flex-1 overflow-y-auto">
      <%= case @view_mode do %>
        <% :databases -> %>
          <.databases_list databases={@databases} target={@myself} />
        <% :tables -> %>
          <.tables_list tables={@tables} target={@myself} />
        <% :columns -> %>
          <.columns_list columns={@columns} />
      <% end %>
    </div>
    """
  end

  defp databases_list(assigns) do
    ~H"""
    <div class="p-2">
      <div :for={database <- @databases} class="flex items-center py-2 px-2 text-sm text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-700 rounded cursor-pointer" phx-click="select_database" phx-value-database={database} phx-target={@target}>
        <div class="flex-shrink-0 mr-3">
          <Icons.database class="h-4 w-4 text-blue-500" />
        </div>
        <span class="text-blue-600 dark:text-blue-400 font-mono text-sm"><%= database %></span>
      </div>
    </div>
    """
  end

  defp tables_list(assigns) do
    ~H"""
    <div class="p-2">
      <div :for={{schema, table} <- @tables} class="flex items-center py-2 px-2 text-sm text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-700 rounded cursor-pointer" phx-click="select_table" phx-value-schema={schema} phx-value-table={table} phx-target={@target}>
        <div class="flex-shrink-0 mr-3">
          <Icons.tables class="h-4 w-4 text-green-500" />
        </div>
        <span class="text-blue-600 font-mono text-sm"><%= table %></span>
      </div>
    </div>
    """
  end

  defp columns_list(assigns) do
    ~H"""
    <div class="p-2">
      <div :for={column <- @columns} class="flex items-center py-2 px-2 text-sm text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-700 rounded cursor-pointer">
        <div class="flex-shrink-0 mr-3">
          <.column_icon column={column} />
        </div>
        <span class="text-blue-600 font-mono text-sm"><%= column.name %></span>
      </div>
    </div>
    """
  end

  defp column_icon(assigns) do
    ~H"""
    <%= case get_column_icon_type(@column) do %>
      <% :id -> %>
        <Icons.key class="h-4 w-4 text-blue-500" />
      <% :text -> %>
        <Icons.text_type class="h-4 w-4 text-gray-500" />
      <% :number -> %>
        <Icons.file_digit class="h-4 w-4 text-green-500" />
      <% :decimal -> %>
        <Icons.decimals class="h-4 w-4 text-green-500" />
      <% :datetime -> %>
        <Icons.calendar class="h-4 w-4 text-purple-500" />
      <% :foreign_key -> %>
        <Icons.key class="h-4 w-4 text-orange-500" />
      <% :boolean -> %>
        <Icons.toggle_boolean class="h-4 w-4 text-indigo-500" />
    <% end %>
    """
  end

  @impl Phoenix.LiveComponent
  def mount(socket) do
    databases = Lotus.list_data_repo_names()

    socket =
      socket
      |> assign(visible: false)
      |> assign(view_mode: :databases)
      |> assign(databases: databases)
      |> assign(tables: [])
      |> assign(columns: [])
      |> assign(current_database: nil)
      |> assign(current_table: nil)
      |> assign(current_schema: nil)

    {:ok, socket}
  end

  @impl Phoenix.LiveComponent
  def update(assigns, socket) do
    socket = assign(socket, assigns)

    # If initial_database is provided and it's different from current database, navigate to tables view
    initial_database = Map.get(assigns, :initial_database)

    if initial_database && initial_database != socket.assigns.current_database &&
         initial_database != "" do
      case Lotus.list_tables(initial_database) do
        {:ok, tables} ->
          socket =
            socket
            |> assign(view_mode: :tables)
            |> assign(current_database: initial_database)
            |> assign(tables: tables)
            |> assign(columns: [])
            |> assign(current_table: nil)
            |> assign(current_schema: nil)

          {:ok, socket}

        {:error, _reason} ->
          {:ok, socket}
      end
    else
      {:ok, socket}
    end
  end

  @impl Phoenix.LiveComponent
  def handle_event("select_database", %{"database" => database}, socket) do
    case Lotus.list_tables(database) do
      {:ok, tables} ->
        socket =
          socket
          |> assign(view_mode: :tables)
          |> assign(current_database: database)
          |> assign(tables: tables)
          |> assign(columns: [])
          |> assign(current_table: nil)
          |> assign(current_schema: nil)

        {:noreply, socket}

      {:error, _reason} ->
        {:noreply, socket}
    end
  end

  def handle_event("select_table", %{"schema" => schema, "table" => table}, socket) do
    case Lotus.get_table_schema(socket.assigns.current_database, table) do
      {:ok, columns} ->
        socket =
          socket
          |> assign(view_mode: :columns)
          |> assign(current_table: table)
          |> assign(current_schema: schema)
          |> assign(columns: columns)

        {:noreply, socket}

      {:error, _reason} ->
        {:noreply, socket}
    end
  end

  def handle_event("navigate_back", _params, socket) do
    case socket.assigns.view_mode do
      :tables ->
        databases = Lotus.list_data_repo_names()

        socket =
          socket
          |> assign(view_mode: :databases)
          |> assign(databases: databases)
          |> assign(current_database: nil)
          |> assign(tables: [])

        {:noreply, socket}

      :columns ->
        case Lotus.list_tables(socket.assigns.current_database) do
          {:ok, tables} ->
            socket =
              socket
              |> assign(view_mode: :tables)
              |> assign(tables: tables)
              |> assign(current_table: nil)
              |> assign(current_schema: nil)
              |> assign(columns: [])

            {:noreply, socket}

          {:error, _reason} ->
            {:noreply, socket}
        end

      _ ->
        {:noreply, socket}
    end
  end

  defp get_column_icon_type(column) do
    cond do
      column.primary_key ->
        :id

      String.contains?(column.name, "_id") and not column.primary_key ->
        :foreign_key

      String.contains?(column.type, "timestamp") or String.contains?(column.type, "date") ->
        :datetime

      String.contains?(column.type, "boolean") ->
        :boolean

      String.contains?(column.type, "numeric") or String.contains?(column.type, "decimal") ->
        :decimal

      String.contains?(column.type, "int") or String.contains?(column.type, "bigint") ->
        :number

      String.contains?(column.type, "varchar") or String.contains?(column.type, "text") or
          String.contains?(column.type, "character") ->
        :text

      true ->
        :text
    end
  end

  def show(socket) do
    assign(socket, visible: true)
  end

  def hide(socket) do
    assign(socket, visible: false)
  end
end

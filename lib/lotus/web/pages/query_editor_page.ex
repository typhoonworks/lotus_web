defmodule Lotus.Web.QueryEditorPage do
  @behaviour Lotus.Web.Page

  use Lotus.Web, :live_component

  alias Lotus.Web.Page
  alias Lotus.Storage.Query
  alias Lotus.Web.Live.SchemaExplorer

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <div id="query-editor-page" class="flex flex-col h-full overflow-hidden">
      <div class="mx-auto w-full px-4 sm:px-0 lg:px-6 py-6 h-full">
        <div class="bg-white shadow rounded-lg h-full overflow-y-auto relative">
          <div class="px-6 py-4 border-b border-gray-200 flex justify-between items-center">
            <h2 class="text-xl font-semibold">
              <%= case @page do
                  %{mode: :new} -> "New Query"
                  _ -> @save_form.params["name"]
                end %>
            </h2>
            <div class="flex gap-3">
              <%= if @page[:mode] == :edit do %>
                <.button
                  type="button"
                  variant="light"
                  phx-click={show_modal("delete-query-modal")}
                  class="text-red-600 hover:text-red-700 border-red-300 hover:bg-red-50"
                >
                  Delete
                </.button>
              <% end %>
              <.button
                type="button"
                disabled={@statement_empty}
                phx-click={show_modal("save-query-modal")}
                class={@statement_empty && "opacity-50 cursor-not-allowed"}
              >
                Save
              </.button>
            </div>
          </div>

          <div class="relative h-full">
            <.live_component
              module={SchemaExplorer}
              id="schema-explorer"
              visible={@drawer_visible}
              parent={@myself}
              initial_database={@form[:data_repo].value}
            />

            <div class={[
              "h-full transition-all duration-300 ease-in-out",
              if(@drawer_visible, do: "mr-80", else: "mr-0")
            ]}>

          <.form for={@form} phx-submit="run-query" phx-target={@myself} phx-change="validate">
            <div class="bg-slate-100">
              <div class="flex justify-between w-full px-6 py-3 border-b border-gray-200">
                <div class="w-48">
                  <.input
                    type="select"
                    field={@form[:data_repo]}
                    prompt="Select a database"
                    options={Enum.map(@data_repo_names, &{&1, &1})}
                  />
                </div>

                <div class="flex items-center space-x-1">
                  <button
                    type="button"
                    phx-click="toggle-drawer"
                    phx-target={@myself}
                    class="p-2 text-gray-400 hover:text-gray-600 transition-colors"
                    title="Browse tables"
                  >
                    <Icons.tables class="h-5 w-5" />
                  </button>

                  <button
                    type="button"
                    phx-click="toggle-editor"
                    phx-target={@myself}
                    class="p-2 text-gray-400 hover:text-gray-600 transition-colors"
                    title={if @editor_minimized, do: "Expand editor", else: "Minimize editor"}
                  >
                    <%= if @editor_minimized do %>
                      <Icons.maximize class="h-5 w-5" />
                    <% else %>
                      <Icons.minimize class="h-5 w-5" />
                    <% end %>
                  </button>
                </div>
              </div>

              <div class={["relative", if(@editor_minimized, do: "hidden", else: "")]}>
                <div id="editor" phx-update="ignore" class="w-full bg-slate-100" style="min-height: 300px;"></div>
                <.input type="textarea" field={@form[:statement]} phx-hook="EditorForm" style="display: none;" />

                <button
                  type="submit"
                  disabled={@running or @statement_empty}
                  class={[
                    "absolute bottom-4 right-4 w-12 h-12 rounded-full shadow-lg transition-all duration-200 flex items-center justify-center bg-pink-600",
                    if(@running or @statement_empty,
                      do: "cursor-not-allowed opacity-50",
                      else: "hover:bg-pink-500 hover:shadow-xl transform hover:scale-105"
                    )
                  ]}
                  title={if @statement_empty, do: "Enter SQL to run query", else: "Run Query"}
                >
                  <%= if @running do %>
                    <svg class="animate-spin h-5 w-5 text-white" fill="none" viewBox="0 0 24 24">
                      <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                      <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                    </svg>
                  <% else %>
                    <Icons.play class="h-5 w-5 text-white ml-0.5" />
                  <% end %>
                </button>
              </div>
            </div>
          </.form>

          <div class="px-4 sm:px-6 lg:px-8">
            <%= if @result do %>
              <.table id="query-results" rows={@result.rows}>
                <:col :let={row} :for={{col, index} <- Enum.with_index(@result.columns)} label={col}>
                  <%= format_cell_value(Enum.at(row, index)) %>
                </:col>
              </.table>
            <% else %>
              <div class="flex flex-col items-center justify-center py-16 text-gray-500">
                <%= if @error do %>
                  <div class="text-red-600 text-center">
                    <p class="font-medium">Error:</p>
                    <p class="text-sm mt-1"><%= @error %></p>
                  </div>
                <% else %>
                  <div class="w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center mb-6">
                    <Icons.terminal class="h-8 w-8 text-gray-400" />
                  </div>

                  <p class="text-base text-gray-600 mb-2">
                    To run your query, click on the Run button or type (⌘ + return)
                  </p>
                  <p class="text-sm text-gray-500">
                    Here's where your results will appear
                  </p>
                <% end %>
              </div>
            <% end %>
          </div>

          </div>
          </div>
        </div>
      </div>

      <.modal id="save-query-modal">
        <h3 class="text-lg font-semibold mb-4">Save Query</h3>
        <.form for={@save_form} phx-submit="save-query" phx-change="validate-save" phx-target={@myself}>
          <div class="space-y-4">
            <.input
              field={@save_form[:name]}
              type="text"
              label="Name"
              placeholder="Enter query name"
              required
            />
            <.input
              field={@save_form[:description]}
              type="textarea"
              label="Description"
              placeholder="Enter query description (optional)"
              rows="3"
            />
          </div>
          <div class="mt-6 flex justify-end gap-3">
            <.button
              type="button"
              variant="light"
              phx-click={hide_modal("save-query-modal")}
            >
              Cancel
            </.button>
            <.button
              type="submit"
              phx-click={hide_modal("save-query-modal")}
              disabled={!@save_form_valid}
            >
              Save Query
            </.button>
          </div>
        </.form>
      </.modal>

      <%= if @page[:mode] == :edit do %>
        <.modal id="delete-query-modal">
          <h3 class="text-lg font-semibold mb-4">Delete query</h3>
          <p class="text-sm text-gray-500 mb-6">
            Are you sure you want to delete this query? This action cannot be undone.
          </p>
          <div class="flex justify-end gap-3">
            <.button
              type="button"
              variant="light"
              phx-click={hide_modal("delete-query-modal")}
            >
              Cancel
            </.button>
            <.button
              type="button"
              phx-click="delete-query"
              phx-target={@myself}
              class="bg-red-600 hover:bg-red-700 focus-visible:outline-red-600"
            >
              Delete
            </.button>
          </div>
        </.modal>
      <% end %>
    </div>
    """
  end

  @impl Page
  def handle_mount(socket) do
    page = socket.assigns.page

    socket =
      socket
      |> assign_data_repos()
      |> assign_ui_state()

    if page[:mode] == :edit and page[:id] do
      case Lotus.get_query(page[:id]) do
        nil ->
          socket
          |> put_flash(:error, "Query not found")
          |> push_navigate(to: lotus_path(:queries))

        query ->
          socket
          |> assign_query_form(query)
          |> assign_save_form(query)
          |> maybe_auto_run_query()
      end
    else
      socket
      |> assign_new_query_form()
      |> assign_empty_save_form()
    end
  end

  defp assign_data_repos(socket) do
    data_repo_names = Lotus.list_data_repo_names()

    default_repo =
      case data_repo_names do
        [] -> "default"
        [first | _] -> first
      end

    assign(socket, data_repo_names: data_repo_names, default_repo: default_repo)
  end

  defp assign_query_form(socket, query) do
    form =
      to_form(
        %{
          "statement" => query.statement,
          "data_repo" => query.data_repo || socket.assigns.default_repo
        },
        as: "query"
      )

    statement_empty = String.trim(query.statement) == ""
    assign(socket, form: form, statement_empty: statement_empty)
  end

  defp assign_new_query_form(socket) do
    form =
      to_form(
        %{
          "statement" => "",
          "data_repo" => socket.assigns.default_repo
        },
        as: "query"
      )

    assign(socket, form: form, statement_empty: true)
  end

  defp assign_save_form(socket, query) do
    save_form =
      to_form(
        %{
          "name" => query.name,
          "description" => query.description || ""
        },
        as: "save_query"
      )

    save_form_valid = String.trim(query.name) != "" && !socket.assigns.statement_empty
    assign(socket, save_form: save_form, save_form_valid: save_form_valid)
  end

  defp assign_empty_save_form(socket) do
    save_form = to_form(%{"name" => "", "description" => ""}, as: "save_query")
    assign(socket, save_form: save_form, save_form_valid: false)
  end

  defp assign_ui_state(socket) do
    assign(socket,
      result: nil,
      error: nil,
      running: false,
      editor_minimized: false,
      drawer_visible: false
    )
  end

  defp maybe_auto_run_query(socket) do
    if !socket.assigns.statement_empty do
      send(self(), :auto_run_query)
    end

    socket
  end

  defp execute_query(socket, statement, data_repo) do
    socket = assign(socket, running: true, error: nil)

    case Lotus.run_sql(statement, [], repo: data_repo) do
      {:ok, result} ->
        {:noreply, assign(socket, result: result, error: nil, running: false)}

      {:error, error_msg} ->
        {:noreply, assign(socket, error: error_msg, result: nil, running: false)}
    end
  end

  @impl Page
  def handle_params(%{"id" => "new"}, _uri, socket) do
    socket =
      socket
      |> assign_new_query_form()
      |> assign_empty_save_form()

    {:noreply, socket}
  end

  def handle_params(%{"id" => id}, _uri, socket) do
    case Lotus.get_query(id) do
      nil ->
        {:noreply,
         socket
         |> put_flash(:error, "Query not found")
         |> push_navigate(to: lotus_path(:queries))}

      query ->
        socket =
          socket
          |> assign_query_form(query)
          |> assign_save_form(query)

        {:noreply, socket}
    end
  end

  @impl Page
  def handle_info(:auto_run_query, socket) do
    form_data = socket.assigns.form.params
    statement = form_data["statement"] |> String.trim()
    data_repo = form_data["data_repo"]

    execute_query(socket, statement, data_repo)
  end

  @impl Page
  def handle_info(_msg, socket), do: {:noreply, socket}

  @impl Phoenix.LiveComponent
  def handle_event("validate", %{"query" => query_params}, socket) do
    changeset = Query.new(query_params)
    form = to_form(changeset, as: "query")

    statement = query_params["statement"] |> String.trim()
    statement_empty = statement == ""

    # Update the SchemaExplorer with the new database selection
    send_update(SchemaExplorer,
      id: "schema-explorer",
      initial_database: query_params["data_repo"]
    )

    {:noreply, assign(socket, form: form, statement_empty: statement_empty)}
  end

  @impl Phoenix.LiveComponent
  def handle_event("editor_content_changed", %{"statement" => statement}, socket) do
    trimmed_statement = String.trim(statement)
    statement_empty = trimmed_statement == ""

    current_params = socket.assigns.form.params
    updated_params = Map.put(current_params, "statement", statement)
    form = to_form(updated_params, as: "query")

    {:noreply, assign(socket, form: form, statement_empty: statement_empty)}
  end

  @impl Phoenix.LiveComponent
  def handle_event("validate-save", %{"save_query" => save_params}, socket) do
    name_present = String.trim(save_params["name"] || "") != ""
    statement_present = !socket.assigns.statement_empty

    save_form = to_form(save_params, as: "save_query")

    {:noreply,
     assign(socket,
       save_form: save_form,
       save_form_valid: name_present && statement_present
     )}
  end

  @impl Phoenix.LiveComponent
  def handle_event("save-query", %{"save_query" => save_params}, socket) do
    form_data = socket.assigns.form.params
    statement = form_data["statement"] |> String.trim()
    data_repo = form_data["data_repo"]
    page = socket.assigns.page

    query_attrs = %{
      "name" => save_params["name"],
      "description" => save_params["description"],
      "statement" => statement,
      "data_repo" => data_repo
    }

    result =
      if page[:mode] == :edit && page[:id] do
        case Lotus.get_query(page.id) do
          nil ->
            {:error, "Query not found"}

          query ->
            Lotus.update_query(query, query_attrs)
        end
      else
        Lotus.create_query(query_attrs)
      end

    case result do
      {:ok, query} ->
        {:noreply,
         socket
         |> put_flash(:info, "Query saved successfully!")
         |> push_patch(to: lotus_path(["queries", query.id]), replace: true)}

      {:error, changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to save query: #{inspect(changeset.errors)}")}
    end
  end

  @impl Phoenix.LiveComponent
  def handle_event("delete-query", _params, socket) do
    query_id = socket.assigns.page.id

    case Lotus.get_query(query_id) do
      nil ->
        {:noreply,
         socket
         |> put_flash(:error, "Query not found")
         |> push_navigate(to: lotus_path(:queries), replace: true)}

      query ->
        case Lotus.delete_query(query) do
          {:ok, _} ->
            {:noreply,
             socket
             |> put_flash(:info, "Query deleted successfully")
             |> push_navigate(to: lotus_path(:queries), replace: true)}

          {:error, _} ->
            {:noreply,
             socket
             |> put_flash(:error, "Failed to delete query")
             |> push_event("close-modal", %{id: "delete-query-modal"})}
        end
    end
  end

  @impl Phoenix.LiveComponent
  def handle_event("toggle-editor", _params, socket) do
    {:noreply, assign(socket, editor_minimized: not socket.assigns.editor_minimized)}
  end

  @impl Phoenix.LiveComponent
  def handle_event("toggle-drawer", _params, socket) do
    {:noreply, assign(socket, drawer_visible: not socket.assigns.drawer_visible)}
  end

  @impl Phoenix.LiveComponent
  def handle_event("close-drawer", _params, socket) do
    {:noreply, assign(socket, drawer_visible: false)}
  end

  @impl Phoenix.LiveComponent
  def handle_event("run-query", %{"query" => query_params}, socket) do
    statement = query_params["statement"] |> String.trim()
    data_repo = query_params["data_repo"]

    if statement != "" do
      execute_query(socket, statement, data_repo)
    else
      {:noreply,
       assign(socket, error: "Please enter a SQL statement", result: nil, running: false)}
    end
  end

  # Helper function to safely format cell values for HTML display
  defp format_cell_value(value) do
    case value do
      nil -> ""
      value when is_binary(value) -> safe_string(value)
      value when is_number(value) -> to_string(value)
      value when is_boolean(value) -> to_string(value)
      value when is_atom(value) -> to_string(value)
      %Date{} = date -> Date.to_string(date)
      %DateTime{} = datetime -> DateTime.to_string(datetime)
      %NaiveDateTime{} = datetime -> NaiveDateTime.to_string(datetime)
      %Time{} = time -> Time.to_string(time)
      value when is_map(value) -> inspect(value, limit: 50)
      value when is_list(value) -> inspect(value, limit: 50)
      value -> inspect(value)
    end
  end

  defp safe_string(binary) when is_binary(binary) do
    if String.valid?(binary) do
      binary
    else
      case byte_size(binary) do
        size when size > 50 ->
          "<<binary, #{size} bytes>>"

        _ ->
          inspect(binary, limit: 50)
      end
    end
  end
end

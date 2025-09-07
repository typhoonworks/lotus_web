defmodule Lotus.Web.QueryEditorPage do
  @behaviour Lotus.Web.Page

  use Lotus.Web, :live_component

  @default_page_size 1000

  alias Lotus.Web.Page
  alias Lotus.Storage.Query
  alias Lotus.Storage.QueryVariable
  alias Lotus.Web.SchemaBuilder
  alias Lotus.Web.SourcesMap
  alias Lotus.Web.Queries.SchemaExplorerComponent
  alias Lotus.Web.Queries.VariableSettingsComponent
  alias Lotus.Web.Queries.DropdownOptionsModal
  alias Lotus.Web.Queries.ExportCompleteModal
  alias Lotus.Web.Formatters.VariableOptionsFormatter, as: OptionsFormatter

  import Lotus.Web.Queries.EditorComponent
  import Lotus.Web.Queries.ResultsComponent

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <div id="query-editor-page" phx-hook="Download" class="flex flex-col h-full overflow-hidden">
      <div class="mx-auto w-full px-4 sm:px-0 lg:px-6 py-6 h-full flex flex-col">
        <div class="bg-white dark:bg-gray-800 shadow rounded-lg h-full flex flex-col overflow-hidden">
          <.header statement_empty={@statement_empty} query={@query} mode={@page.mode} />

          <div class="relative flex-1 overflow-y-auto overflow-x-hidden">
            <.live_component
              module={SchemaExplorerComponent}
              id="schema-explorer"
              visible={@schema_explorer_visible}
              parent={@myself}
              initial_db={@query_form[:data_repo].value}
            />

            <.live_component
              module={VariableSettingsComponent}
              id="variable-settings"
              visible={@variable_settings_visible}
              form={@query_form}
              parent={@myself}
              active_tab={@variable_settings_active_tab}
            />

            <div class={[
              "transition-all duration-300 ease-in-out h-full flex flex-col overflow-hidden",
              cond do
                @schema_explorer_visible -> "mr-80"
                @variable_settings_visible -> "mr-80"
                true -> "mr-0"
              end
            ]}>

              <.editor
                form={@query_form}
                target={@myself}
                minimized={@editor_minimized}
                data_repo_names={@data_repo_names}
                schema={@editor_schema}
                dialect={@editor_dialect}
                running={@running}
                statement_empty={@statement_empty}
                schema_explorer_visible={@schema_explorer_visible}
                variable_settings_visible={@variable_settings_visible}
                variables={@query.variables}
                variable_values={Map.get(assigns, :variable_values, %{})}
                resolved_variable_options={@resolved_variable_options}
              />
              <div class="flex-1 overflow-y-auto min-h-0">
                <.render_result result={@result} error={@error} running={@running} os={Map.get(assigns, :os, :unknown)} target={@myself} />
              </div>

            </div>
          </div>
        </div>
      </div>

      <.save_modal query_form={@query_form} target={@myself} />
      <.delete_modal :if={@page.mode == :edit} target={@myself} />

      <%= if @dropdown_options_modal_visible do %>
        <.live_component
          module={DropdownOptionsModal}
          id="dropdown_options_modal"
          variable_name={@dropdown_options_variable_name}
          variable_data={get_variable_data(@query_form, @dropdown_options_variable_name)}
          parent={@myself}
        />
      <% end %>

      <%= if @export_modal_visible do %>
        <.live_component
          module={ExportCompleteModal}
          id="export_complete_modal"
          filename={@export_filename}
          file_path={@export_file_path}
          error={@export_error}
          parent={@myself}
        />
      <% end %>
    </div>
    """
  end

  defp header(assigns) do
    ~H"""
    <div class="px-6 py-4 border-b border-gray-200 dark:border-gray-700 flex justify-between items-center">
      <h2 class="text-xl font-semibold text-text-light dark:text-text-dark">
        <%= if @mode == :new, do: "New Query", else: (@query.name || "Untitled") %>
      </h2>
      <div class="flex gap-3">
        <%= if @mode == :edit do %>
          <.button
            type="button"
            variant="light"
            phx-click={show_modal("delete-query-modal")}
            class="text-red-600 hover:text-red-700 border-transparent hover:bg-red-50 dark:text-red-400 dark:hover:text-red-300 dark:border-transparent dark:hover:bg-white/10"
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
    """
  end

  defp save_modal(assigns) do
    ~H"""
    <.modal id="save-query-modal">
      <h3 class="text-lg font-semibold mb-4">Save Query</h3>

      <.form for={@query_form}
             phx-submit="save_query"
             phx-change="validate_save"
             phx-target={@target}>
        <div class="space-y-4">
          <.input
            field={@query_form[:name]}
            type="text"
            label="Name"
            placeholder="Enter query name"
            required
          />
          <.input
            field={@query_form[:description]}
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
            disabled={String.trim(Phoenix.HTML.Form.input_value(@query_form, :name) || "") == ""}
          >
            Save Query
          </.button>
        </div>
      </.form>
    </.modal>
    """
  end

  defp delete_modal(assigns) do
    ~H"""
    <.modal id="delete-query-modal">
      <h3 class="text-lg font-semibold mb-4">Delete query</h3>
      <p class="text-sm text-gray-500 dark:text-gray-400 mb-6">
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
          phx-click="delete_query"
          phx-target={@target}
          class="bg-red-600 hover:bg-red-700 focus-visible:outline-red-600"
        >
          Delete
        </.button>
      </div>
    </.modal>
    """
  end

  @impl Lotus.Web.Page
  def handle_mount(socket) do
    socket
    |> assign_data_repos()
    |> assign_ui_state()
  end

  @impl Lotus.Web.Page
  def handle_params(_params, _uri, socket) do
    case socket.assigns.page do
      %{mode: :edit, id: id} ->
        case Lotus.get_query(id) do
          nil ->
            {:noreply,
             socket
             |> put_flash(:error, "Query not found")
             |> push_navigate(to: lotus_path(:queries))}

          %Query{} = query ->
            {:noreply,
             socket
             |> ensure_query_repo_default(query)
             |> assign_query_changeset(query)
             |> maybe_auto_run_query()}
        end

      %{mode: :new} ->
        query = %Query{
          name: "",
          description: "",
          statement: "",
          data_repo: socket.assigns.default_repo,
          variables: []
        }

        {:noreply, assign_query_changeset(socket, query)}
    end
  end

  @impl Phoenix.LiveComponent
  def handle_event("close_variable_settings", _params, socket) do
    {:noreply,
     assign(socket, variable_settings_visible: false, variable_settings_active_tab: nil)}
  end

  @impl Phoenix.LiveComponent
  def handle_event("switch_variable_tab", %{"tab" => tab}, socket) do
    active_tab = String.to_existing_atom(tab)
    {:noreply, assign(socket, variable_settings_active_tab: active_tab)}
  end

  @impl Phoenix.LiveComponent
  def handle_event("validate", params, socket) do
    query_params = Map.get(params, "query", %{})
    var_params = Map.get(params, "variables", %{})

    changeset = build_query_changeset(socket.assigns.query, query_params)

    statement_empty =
      query_params["statement"]
      |> case do
        nil -> check_statement_empty(socket.assigns.query.statement)
        statement -> check_statement_empty(statement)
      end

    send_update(SchemaExplorerComponent,
      id: "schema-explorer",
      initial_db: query_params["data_repo"]
    )

    socket =
      socket
      |> update_query_state(changeset,
        statement_empty: statement_empty,
        variable_values: Map.merge(socket.assigns.variable_values || %{}, var_params)
      )
      |> maybe_update_editor_schema(query_params["data_repo"])

    {:noreply, socket}
  end

  @impl Phoenix.LiveComponent
  def handle_event("editor_content_changed", %{"statement" => statement}, socket) do
    base_params = socket.assigns.query_form.params || %{}
    params = Map.put(base_params, "statement", statement)
    changeset = Query.update(socket.assigns.query, params)

    socket =
      update_query_state(socket, changeset, statement_empty: check_statement_empty(statement))

    {:noreply, socket}
  end

  @impl Phoenix.LiveComponent
  def handle_event("validate_save", %{"query" => save_params}, socket) do
    changeset = build_query_changeset(socket.assigns.query, save_params)
    form = build_query_form(changeset)

    statement_present = not check_statement_empty(socket.assigns.query_form)
    name_present = String.trim(Phoenix.HTML.Form.input_value(form, :name) || "") != ""

    {:noreply,
     assign(socket,
       query_changeset: changeset,
       query_form: form,
       save_form_valid: name_present && statement_present
     )}
  end

  @impl Phoenix.LiveComponent
  def handle_event("save_query", %{"query" => save_params}, socket) do
    IO.inspect(socket.assigns[:access], label: "COMPONENT ACCESS LEVEL")

    if socket.assigns[:access] == :read_only do
      send(self(), {:put_flash, [:error, "You don't have permission to save queries"]})

      {:noreply,
       socket
       |> push_event("close-modal", %{id: "save-query-modal"})}
    else
      query_attrs = build_query_attrs(save_params, socket.assigns.query)
      result = perform_save_operation(socket.assigns.page, query_attrs)

      case result do
        {:ok, query} ->
          {:noreply,
           socket
           |> put_flash(:info, "Query saved successfully!")
           |> push_patch(to: lotus_path(["queries", query.id]), replace: true)
           |> assign(query: query)
           |> assign_query_changeset(query)}

        {:error, %Ecto.Changeset{} = cs} ->
          send(self(), {:put_flash, [:error, "Failed to save query"]})

          {:noreply,
           socket
           |> assign(query_changeset: cs, query_form: to_form(cs, as: "query"))}
      end
    end
  end

  @impl Phoenix.LiveComponent
  def handle_event("delete_query", _params, socket) do
    if socket.assigns[:access] == :read_only do
      send(self(), {:put_flash, [:error, "You don't have permission to delete queries"]})

      {:noreply,
       socket
       |> push_event("close-modal", %{id: "delete-query-modal"})}
    else
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
              send(self(), {:put_flash, [:error, "Failed to delete query"]})

              {:noreply,
               socket
               |> push_event("close-modal", %{id: "delete-query-modal"})}
          end
      end
    end
  end

  @impl Phoenix.LiveComponent
  def handle_event("toggle_editor", _params, socket) do
    {:noreply, assign(socket, editor_minimized: not socket.assigns.editor_minimized)}
  end

  @impl Phoenix.LiveComponent
  def handle_event("expand_editor", _params, socket) do
    {:noreply, assign(socket, editor_minimized: false)}
  end

  @impl Phoenix.LiveComponent
  def handle_event("minimize_editor", _params, socket) do
    {:noreply, assign(socket, editor_minimized: true)}
  end

  @impl Phoenix.LiveComponent
  def handle_event("toggle_schema_explorer", _params, socket) do
    socket =
      socket
      |> assign(schema_explorer_visible: not socket.assigns.schema_explorer_visible)
      |> assign(variable_settings_visible: false)

    {:noreply, socket}
  end

  @impl Phoenix.LiveComponent
  def handle_event("close_schema_explorer", _params, socket) do
    {:noreply, assign(socket, schema_explorer_visible: false)}
  end

  @impl Phoenix.LiveComponent
  def handle_event("toggle_variable_settings", _params, socket) do
    socket =
      socket
      |> assign(variable_settings_visible: not socket.assigns.variable_settings_visible)
      |> assign(schema_explorer_visible: false)

    {:noreply, socket}
  end

  @impl Phoenix.LiveComponent
  def handle_event("variables_changed", %{"variables" => incoming}, socket) do
    {:noreply,
     assign(socket, variable_values: Map.merge(socket.assigns.variable_values || %{}, incoming))}
  end

  @impl Phoenix.LiveComponent
  def handle_event("open_dropdown_options_modal", %{"variable" => variable_name}, socket) do
    {:noreply,
     assign(socket,
       dropdown_options_modal_visible: true,
       dropdown_options_variable_name: variable_name
     )}
  end

  @impl Phoenix.LiveComponent
  def handle_event("request_editor_schema", _params, socket) do
    data_repo = socket.assigns.query.data_repo
    socket = maybe_update_editor_schema(socket, data_repo)
    {:noreply, socket}
  end

  @impl Phoenix.LiveComponent
  def handle_event("variables_detected", %{"variables" => names}, socket) do
    names = List.wrap(names)
    existing_variables = socket.assigns.query.variables

    ordered_vars = build_ordered_variables(names, existing_variables)
    socket = update_variable_state(socket, ordered_vars, names)

    {:noreply, socket}
  end

  @impl Phoenix.LiveComponent
  def handle_event("copy-to-clipboard-success", _params, socket) do
    send(self(), {:put_flash, [:info, "Query copied to clipboard!"]})
    {:noreply, socket}
  end

  @impl Phoenix.LiveComponent
  def handle_event("copy-to-clipboard-error", %{"error" => _error}, socket) do
    send(self(), {:put_flash, [:error, "Failed to copy to clipboard!"]})
    {:noreply, socket}
  end

  @impl Phoenix.LiveComponent
  def handle_event("copy_query", _params, socket) do
    {:noreply, push_event(socket, "copy-editor-content", %{})}
  end

  @impl Phoenix.LiveComponent
  def handle_event("export_csv", _params, socket) do
    case socket.assigns.result do
      nil ->
        send(self(), {:put_flash, [:error, "No query results to export"]})
        {:noreply, socket}

      %{rows: [], meta: _} ->
        send(self(), {:put_flash, [:error, "No query results to export"]})
        {:noreply, socket}

      _result ->
        {:noreply, start_streaming_export(socket)}
    end
  end

  @impl Phoenix.LiveComponent
  def handle_event("close_export_modal", _params, socket) do
    {:noreply,
     assign(socket,
       export_modal_visible: false,
       export_filename: nil,
       export_file_path: nil,
       export_error: nil
     )}
  end

  @impl Phoenix.LiveComponent
  def handle_event("reveal_in_finder", %{"path" => file_path}, socket) do
    case :os.type() do
      {:unix, :darwin} ->
        System.cmd("open", ["-R", file_path])

      {:win32, _} ->
        System.cmd("explorer", ["/select,", file_path])

      _ ->
        dir = Path.dirname(file_path)
        System.cmd("xdg-open", [dir])
    end

    {:noreply, socket}
  end

  @impl Phoenix.LiveComponent
  def handle_event("open_file", %{"path" => file_path}, socket) do
    case :os.type() do
      {:unix, :darwin} ->
        System.cmd("open", [file_path])

      {:win32, _} ->
        System.cmd("cmd", ["/c", "start", "", file_path])

      _ ->
        System.cmd("xdg-open", [file_path])
    end

    {:noreply, socket}
  end

  @impl Phoenix.LiveComponent
  def handle_event("run_query", %{"query" => query_params} = _payload, socket) do
    changeset = build_query_changeset(socket.assigns.query, query_params)
    form = build_query_form(changeset)

    if check_statement_empty(form) do
      {:noreply,
       assign(socket, error: "Please enter a SQL statement", result: nil, running: false)}
    else
      query = Ecto.Changeset.apply_changes(changeset)

      socket =
        socket
        |> update_query_state(changeset, [])
        |> assign(page_index: 0)

      {:noreply, execute_query(socket, query)}
    end
  end

  @impl Phoenix.LiveComponent
  def handle_event("next_page", _params, socket) do
    case socket.assigns[:result] do
      %{} = result ->
        meta = Map.get(result, :meta, %{})
        total = Map.get(meta, :total_count)
        page_size = socket.assigns.page_size || @default_page_size
        page_index = socket.assigns.page_index || 0

        can_next =
          cond do
            is_integer(total) -> (page_index + 1) * page_size < total
            true -> length(result.rows || []) == page_size
          end

        if can_next do
          {:noreply,
           socket
           |> assign(page_index: page_index + 1)
           |> execute_query(socket.assigns.query)}
        else
          {:noreply, socket}
        end

      _ ->
        {:noreply, socket}
    end
  end

  @impl Phoenix.LiveComponent
  def handle_event("prev_page", _params, socket) do
    current = socket.assigns.page_index || 0
    new_index = max(current - 1, 0)

    if new_index != current do
      {:noreply,
       socket
       |> assign(page_index: new_index)
       |> execute_query(socket.assigns.query)}
    else
      {:noreply, socket}
    end
  end

  @impl Phoenix.LiveComponent
  def handle_event("goto_page", %{"index" => idx}, socket) do
    case Integer.parse(to_string(idx)) do
      {n, ""} when n >= 0 ->
        {:noreply, socket |> assign(page_index: n) |> execute_query(socket.assigns.query)}

      _ ->
        {:noreply, socket}
    end
  end

  @impl Page
  def handle_info({:source_changed, new_source, _field}, socket) do
    current_query = socket.assigns.query
    updated_query = %{current_query | data_repo: new_source}

    socket =
      socket
      |> assign(query: updated_query)
      |> assign_query_changeset(updated_query)
      |> maybe_update_editor_schema(new_source)

    {:noreply, socket}
  end

  def handle_info({:schema_changed, new_search_path, _field}, socket) do
    current_query = socket.assigns.query
    updated_query = %{current_query | search_path: new_search_path}

    socket =
      socket
      |> assign(query: updated_query)
      |> assign_query_changeset(updated_query)
      |> maybe_update_editor_schema(current_query.data_repo)

    {:noreply, socket}
  end

  def handle_info({:trigger_download, file_path}, socket) do
    case File.read(file_path) do
      {:ok, content} ->
        {:noreply,
         push_event(socket, "download-csv", %{
           data: content,
           filename: socket.assigns.export_filename
         })}

      {:error, _} ->
        {:noreply, socket}
    end
  end

  def handle_info(_msg, socket), do: {:noreply, socket}

  @impl Phoenix.LiveComponent
  def handle_async(:query_execution, {:ok, {:ok, result}}, socket) do
    {:noreply, assign(socket, result: result, error: nil, running: false)}
  end

  def handle_async(:query_execution, {:ok, {:error, error_msg}}, socket) do
    {:noreply, assign(socket, error: to_string(error_msg), result: nil, running: false)}
  end

  def handle_async(:query_execution, {:exit, _reason}, socket) do
    {:noreply, assign(socket, error: "Query execution failed", result: nil, running: false)}
  end

  @impl Phoenix.LiveComponent
  def handle_async(:csv_export, {:ok, {:ok, file_path}}, socket) do
    filename = Path.basename(file_path)

    {:noreply,
     assign(socket,
       export_modal_visible: true,
       export_filename: filename,
       export_file_path: file_path,
       export_task: nil
     )}
  end

  def handle_async(:csv_export, {:ok, {:error, error}}, socket) do
    {:noreply,
     assign(socket,
       export_error: to_string(error),
       export_task: nil,
       export_modal_visible: true
     )}
  end

  def handle_async(:csv_export, {:exit, _reason}, socket) do
    {:noreply,
     assign(socket,
       export_error: "Export failed unexpectedly",
       export_task: nil,
       export_modal_visible: true
     )}
  end

  @impl Phoenix.LiveComponent
  def update(%{action: :close_dropdown_options_modal}, socket) do
    {:ok,
     assign(socket, dropdown_options_modal_visible: false, dropdown_options_variable_name: nil)}
  end

  def update(%{action: :save_dropdown_options} = assigns, socket) do
    socket =
      socket
      |> update_variable_options(assigns.variable_name, assigns.options_data)
      |> assign(dropdown_options_modal_visible: false, dropdown_options_variable_name: nil)

    {:ok, socket}
  end

  def update(%{action: :test_dropdown_query} = assigns, socket) do
    repo = socket.assigns.query.data_repo || socket.assigns.default_repo
    search_path = socket.assigns.query.search_path

    case fetch_dropdown_options(assigns.sql_query, repo, search_path, limit: 3, cache: false) do
      {:ok, results} ->
        send_update(DropdownOptionsModal,
          id: "dropdown_options_modal",
          query_test_result: {:ok, results}
        )

      {:error, error} ->
        send_update(DropdownOptionsModal,
          id: "dropdown_options_modal",
          query_test_result: {:error, error}
        )
    end

    {:ok, socket}
  end

  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end

  defp assign_data_repos(socket) do
    data_repo_names = Lotus.list_data_repo_names()
    {default_repo, _module} = Lotus.default_data_repo()
    sources_map = SourcesMap.build()

    socket
    |> assign(data_repo_names: data_repo_names, default_repo: default_repo)
    |> assign(sources_map: sources_map)
  end

  defp assign_ui_state(socket) do
    assign(socket,
      result: nil,
      error: nil,
      running: false,
      page_size: @default_page_size,
      page_index: 0,
      editor_minimized: false,
      schema_explorer_visible: false,
      variable_settings_visible: false,
      variable_settings_active_tab: nil,
      dropdown_options_modal_visible: false,
      dropdown_options_variable_name: nil,
      editor_schema: nil,
      editor_dialect: nil,
      detected_variables: [],
      variable_form: to_form(%{}, as: "variables"),
      resolved_variable_options: %{},
      export_modal_visible: false,
      export_filename: nil,
      export_file_path: nil,
      export_error: nil,
      export_task: nil
    )
  end

  defp assign_query_changeset(socket, %Query{} = query) do
    changeset = Query.update(query, %{})
    resolved_options = resolve_variable_options(query)

    variable_values =
      case Map.get(socket.assigns, :variable_values) do
        nil ->
          query.variables
          |> Enum.filter(& &1.default)
          |> Map.new(fn v -> {v.name, v.default} end)

        existing ->
          existing
      end

    assign(socket,
      query: query,
      query_changeset: changeset,
      query_form: to_form(changeset, as: "query"),
      statement_empty: String.trim(query.statement) == "",
      variable_values: variable_values,
      resolved_variable_options: resolved_options
    )
  end

  defp ensure_query_repo_default(socket, %Query{} = q) do
    if q.data_repo in socket.assigns.data_repo_names do
      assign(socket, query: q)
    else
      assign(socket, query: %{q | data_repo: socket.assigns.default_repo})
    end
  end

  defp maybe_auto_run_query(socket) do
    query = socket.assigns[:query]
    variable_values = Map.get(socket.assigns, :variable_values, %{})

    if Lotus.can_run?(query, vars: variable_values) do
      execute_query(socket, query)
    else
      socket
    end
  end

  defp maybe_update_editor_schema(socket, data_repo) do
    if data_repo && data_repo != "" do
      dialect = dialect_for_repo(data_repo)
      search_path = socket.assigns.query && socket.assigns.query.search_path

      case SchemaBuilder.build(socket.assigns.sources_map, data_repo, search_path) do
        {:ok, schema} ->
          assign(socket, editor_schema: schema, editor_dialect: dialect)

        {:error, _reason} ->
          assign(socket, editor_schema: nil, editor_dialect: dialect)
      end
    else
      assign(socket, editor_schema: nil, editor_dialect: nil)
    end
  end

  defp dialect_for_repo(repo_name) do
    repo =
      try do
        Lotus.Config.get_data_repo!(repo_name)
      rescue
        _ -> nil
      end

    case repo && repo.__adapter__() do
      Ecto.Adapters.Postgres -> "postgres"
      Ecto.Adapters.MyXQL -> "mysql"
      Ecto.Adapters.SQLite3 -> "sqlite"
      _ -> "postgres"
    end
  end

  defp variable_to_params(%QueryVariable{} = v) do
    %{
      "name" => v.name,
      "type" => v.type,
      "widget" => v.widget,
      "label" => v.label,
      "default" => v.default,
      "static_options" => static_options_to_params(v.static_options),
      "options_query" => v.options_query
    }
  end

  defp static_options_to_params(static_options) do
    OptionsFormatter.static_options_to_storage(static_options)
  end

  defp format_variable_label(var_name) when is_binary(var_name) do
    var_name
    |> String.split("_")
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(" ")
  end

  defp format_variable_label(var_name), do: var_name

  defp normalize_query_params(params) do
    case Map.get(params, "variables") do
      nil ->
        params

      variables_map when is_map(variables_map) ->
        normalized_variables =
          variables_map
          |> Enum.map(fn {idx, var_attrs} ->
            normalized_attrs = normalize_variable_attrs(var_attrs)
            {idx, normalized_attrs}
          end)
          |> Map.new()

        Map.put(params, "variables", normalized_variables)

      _ ->
        params
    end
  end

  defp normalize_variable_attrs(attrs) when is_map(attrs) do
    case Map.get(attrs, "static_options") do
      options_string when is_binary(options_string) and options_string != "" ->
        options_maps = OptionsFormatter.from_display_format(options_string)
        Map.put(attrs, "static_options", options_maps)

      "" ->
        Map.put(attrs, "static_options", [])

      options_list when is_list(options_list) ->
        normalized_options = OptionsFormatter.normalize_to_maps(options_list)
        Map.put(attrs, "static_options", normalized_options)

      _ ->
        attrs
    end
  end

  defp normalize_variable_attrs(attrs), do: attrs

  defp build_query_changeset(query, params, action \\ :validate) do
    query
    |> Query.update(normalize_query_params(params))
    |> Map.put(:action, action)
  end

  defp build_query_form(changeset) do
    to_form(changeset, as: "query")
  end

  defp update_query_state(socket, changeset, additional_assigns) do
    form = build_query_form(changeset)
    query = Ecto.Changeset.apply_changes(changeset)

    base_assigns = [
      query: query,
      query_changeset: changeset,
      query_form: form
    ]

    assign(socket, base_assigns ++ additional_assigns)
  end

  defp check_statement_empty(statement) when is_binary(statement) do
    statement |> String.trim() |> Kernel.==("")
  end

  defp check_statement_empty(%Phoenix.HTML.Form{} = form) do
    form[:statement].value
    |> to_string()
    |> check_statement_empty()
  end

  defp check_statement_empty(nil), do: true

  defp execute_query(socket, query) do
    vars = Map.get(socket.assigns, :variable_values, %{})
    repo = query.data_repo || socket.assigns.default_repo
    page_size = socket.assigns.page_size || @default_page_size
    page_index = socket.assigns.page_index || 0

    opts = [
      repo: repo,
      vars: vars,
      window: [limit: page_size, offset: page_index * page_size, count: :exact]
    ]

    opts =
      if query.search_path && String.trim(query.search_path) != "" do
        Keyword.put(opts, :search_path, query.search_path)
      else
        opts
      end

    socket
    |> assign(running: true, error: nil, result: nil)
    |> start_async(:query_execution, fn ->
      Lotus.run_query(query, opts)
    end)
  end

  defp build_ordered_variables(names, existing_variables) do
    existing_by_name = Map.new(existing_variables, &{&1.name, &1})

    Enum.map(names, fn name ->
      case existing_by_name do
        %{^name => %QueryVariable{} = var} ->
          var

        _ ->
          %QueryVariable{
            name: name,
            type: :text,
            widget: :input,
            label: format_variable_label(name),
            default: nil,
            static_options: [],
            options_query: nil
          }
      end
    end)
  end

  defp merge_variable_defaults(current_values, ordered_vars) do
    Enum.reduce(ordered_vars, current_values, fn v, acc ->
      Map.update(acc, v.name, v.default, & &1)
    end)
  end

  defp update_variable_state(socket, ordered_vars, names) do
    params = %{"variables" => Enum.map(ordered_vars, &variable_to_params/1)}
    changeset = build_query_changeset(socket.assigns.query, params)

    current_vals = socket.assigns.variable_values || %{}
    keep = Map.take(current_vals, names)
    with_defaults = merge_variable_defaults(keep, ordered_vars)

    prev_names = Enum.map(socket.assigns.query.variables, & &1.name)
    new_names = names -- prev_names
    show_settings = new_names != [] and not socket.assigns.variable_settings_visible

    update_query_state(socket, changeset,
      variable_values: with_defaults,
      variable_settings_visible: show_settings || socket.assigns.variable_settings_visible,
      variable_settings_active_tab:
        if(show_settings, do: :settings, else: socket.assigns.variable_settings_active_tab),
      schema_explorer_visible:
        if(show_settings, do: false, else: socket.assigns.schema_explorer_visible)
    )
  end

  defp build_query_attrs(save_params, current_query) do
    %{
      "name" => save_params["name"],
      "description" => save_params["description"],
      "statement" => current_query.statement,
      "data_repo" => current_query.data_repo,
      "search_path" => current_query.search_path,
      "variables" => Enum.map(current_query.variables, &variable_to_params/1)
    }
  end

  defp perform_save_operation(page, query_attrs) do
    case page do
      %{mode: :edit, id: id} ->
        case Lotus.get_query(id) do
          nil -> {:error, "Query not found"}
          %Query{} = query -> Lotus.update_query(query, query_attrs)
        end

      %{mode: :new} ->
        Lotus.create_query(query_attrs)
    end
  end

  defp get_variable_data(form, variable_name) do
    variables = form[:variables].value || []

    case Enum.find(variables, fn var ->
           case var do
             %Ecto.Changeset{} = changeset ->
               Ecto.Changeset.get_field(changeset, :name) == variable_name

             %{name: name} ->
               name == variable_name

             _ ->
               false
           end
         end) do
      nil ->
        %{}

      %Ecto.Changeset{} = changeset ->
        Ecto.Changeset.apply_changes(changeset)

      variable ->
        variable
    end
  end

  defp update_variable_options(socket, variable_name, options_data) do
    current_query = socket.assigns.query

    updated_variables =
      Enum.map(current_query.variables, fn var ->
        if var.name == variable_name do
          %{
            var
            | static_options: options_data.static_options,
              options_query: options_data.options_query
          }
        else
          var
        end
      end)

    updated_query = %{current_query | variables: updated_variables}
    params = %{"variables" => Enum.map(updated_variables, &variable_to_params/1)}
    changeset = build_query_changeset(updated_query, params)

    resolved_options = resolve_variable_options(updated_query)

    socket
    |> update_query_state(changeset, [])
    |> assign(:resolved_variable_options, resolved_options)
  end

  defp fetch_dropdown_options(sql_query, repo, search_path, opts \\ []) do
    limit = Keyword.get(opts, :limit)
    use_cache = Keyword.get(opts, :cache, true)

    try do
      limited_query =
        if limit do
          "SELECT * FROM (#{sql_query}) AS test_query LIMIT #{limit}"
        else
          sql_query
        end

      run_opts = [repo: repo]

      run_opts =
        if search_path && String.trim(search_path) != "" do
          Keyword.put(run_opts, :search_path, search_path)
        else
          run_opts
        end

      run_opts =
        if use_cache do
          Keyword.put(run_opts, :cache, profile: :options)
        else
          run_opts
        end

      case Lotus.run_sql(limited_query, [], run_opts) do
        {:ok, result} ->
          formatted_results = OptionsFormatter.from_lotus_result(result)
          {:ok, formatted_results}

        {:error, error} ->
          {:error, to_string(error)}
      end
    rescue
      error ->
        {:error, "Query execution failed: #{Exception.message(error)}"}
    end
  end

  defp resolve_variable_options(%{data_repo: nil}), do: %{}
  defp resolve_variable_options(%{data_repo: ""}), do: %{}

  defp resolve_variable_options(%{
         data_repo: repo,
         search_path: search_path,
         variables: variables
       }) do
    variables
    |> Enum.reduce(%{}, fn var, acc ->
      case var.options_query do
        nil ->
          acc

        "" ->
          acc

        sql_query when is_binary(sql_query) ->
          case fetch_dropdown_options(sql_query, repo, search_path) do
            {:ok, results} ->
              options = OptionsFormatter.to_select_options(results)
              Map.put(acc, var.name, options)

            {:error, _error} ->
              Map.put(acc, var.name, [])
          end
      end
    end)
  end

  defp start_streaming_export(socket) do
    query = socket.assigns.query
    vars = Map.get(socket.assigns, :variable_values, %{})
    repo = query.data_repo || socket.assigns.default_repo

    timestamp =
      DateTime.utc_now()
      |> DateTime.to_naive()
      |> Calendar.strftime("%Y%m%d%H%M%S")

    base_name =
      case query.name do
        name when is_binary(name) and name != "" ->
          name
          |> String.trim()
          |> String.replace(~r/[^\w\s-]/, "")
          |> String.replace(~r/\s+/, "_")
          |> String.downcase()

        _ ->
          "query_results"
      end

    filename = "#{timestamp}_#{base_name}.csv"

    temp_dir = System.tmp_dir!()
    file_path = Path.join(temp_dir, filename)

    # Don't show modal yet - will show when complete
    socket =
      assign(socket,
        export_modal_visible: false,
        export_filename: filename,
        export_file_path: file_path,
        export_error: nil
      )

    start_async(socket, :csv_export, fn ->
      perform_streaming_export(query, repo, vars, file_path, self())
    end)
  end

  defp perform_streaming_export(query, repo, vars, file_path, parent_pid) do
    opts = [
      repo: repo,
      vars: vars,
      page_size: @default_page_size
    ]

    opts =
      if query.search_path && String.trim(query.search_path) != "" do
        Keyword.put(opts, :search_path, query.search_path)
      else
        opts
      end

    try do
      {:ok, file} = File.open(file_path, [:write, :utf8])

      stream = Lotus.Export.stream_csv(query, opts)

      stream
      |> Enum.each(fn chunk ->
        IO.write(file, chunk)
      end)

      File.close(file)

      send(parent_pid, {:trigger_download, file_path})

      {:ok, file_path}
    rescue
      error ->
        {:error, Exception.message(error)}
    end
  end
end

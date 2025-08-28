defmodule Lotus.Web.QueryEditorPage do
  @behaviour Lotus.Web.Page

  use Lotus.Web, :live_component

  alias Lotus.Web.Page
  alias Lotus.Storage.Query
  alias Lotus.Storage.QueryVariable
  alias Lotus.Web.CellFormatter
  alias Lotus.Web.SchemaBuilder
  alias Lotus.Web.Live.SchemaExplorer
  alias Lotus.Web.EditorComponents, as: Editor

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <div id="query-editor-page" class="flex flex-col h-full overflow-hidden">
      <div class="mx-auto w-full px-4 sm:px-0 lg:px-6 py-6 h-full">
        <div class="bg-white shadow rounded-lg h-full overflow-y-auto relative">
          <div class="px-6 py-4 border-b border-gray-200 flex justify-between items-center">
            <h2 class="text-xl font-semibold">
              <%= if @page.mode == :new, do: "New Query", else: (@query.name || "Untitled") %>
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
              visible={@schema_drawer_visible}
              parent={@myself}
              initial_database={@query_form[:data_repo].value}
            />

            <.variable_settings_drawer {assigns} />

            <div class={[
              "h-full transition-all duration-300 ease-in-out",
              cond do
                @schema_drawer_visible -> "mr-80"
                @variable_drawer_visible -> "mr-80"
                true -> "mr-0"
              end
            ]}>

          <.form for={@query_form} phx-submit="run_query" phx-target={@myself} phx-change="validate">
            <div class="bg-slate-100">
              <div class="flex items-center w-full px-6 py-3 border-b border-gray-200 gap-4">
                <div class="w-48">
                  <Editor.input
                    type="select"
                    field={@query_form[:data_repo]}
                    label="Source"
                    prompt="Select a database"
                    options={Enum.map(@data_repo_names, &{&1, &1})}
                    show_icons={true}
                  />
                </div>

                <div class="w-px self-stretch bg-gray-300"></div>

                <div class="flex-1 flex flex-wrap gap-3 items-center">
                  <.inputs_for :let={vf} field={@query_form[:variables]}>
                    <% name = vf[:name].value %>
                    <% label = vf[:label].value || format_variable_label(name) %>
                    <% value = @var_values[name] || vf[:default].value || "" %>

                    <div class="flex items-center gap-2 min-w-32">
                      <%= case vf[:widget].value do %>
                        <% :select -> %>
                          <Editor.input
                            id={"vars_#{name}"}
                            type="select"
                            name={"vars[#{name}]"}
                            value={value}
                            label={label}
                            options={vf[:static_options].value || []}
                            prompt="Select value"
                            class="min-w-32 w-32"
                          />
                        <% :date -> %>
                          <Editor.input
                            id={"vars_#{name}"}
                            type="date"
                            name={"vars[#{name}]"}
                            value={value}
                            label={label}
                            placeholder="Select date"
                            class="min-w-32 w-32"
                          />
                        <% _ -> %>
                          <Editor.input
                            id={"vars_#{name}"}
                            type="text"
                            name={"vars[#{name}]"}
                            value={value}
                            label={label}
                            placeholder="Enter value"
                            class="w-32"
                          />
                      <% end %>
                    </div>
                  </.inputs_for>
                </div>

                <div class="flex items-center space-x-1">
                  <button
                    type="button"
                    phx-click="toggle-variable-drawer"
                    phx-target={@myself}
                    class={[
                      "p-2 transition-colors",
                      if(@variable_drawer_visible,
                        do: "text-pink-600 hover:text-pink-700",
                        else: "text-gray-400 hover:text-gray-600"
                      )
                    ]}
                    title="Variable settings"
                  >
                    <Icons.variable class="h-5 w-5" />
                  </button>
                  <button
                    type="button"
                    phx-click="toggle-drawer"
                    phx-target={@myself}
                    class={[
                      "p-2 transition-colors",
                      if(@schema_drawer_visible,
                        do: "text-pink-600 hover:text-pink-700",
                        else: "text-gray-400 hover:text-gray-600"
                      )
                    ]}
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
                <.input type="textarea" field={@query_form[:statement]} phx-hook="EditorForm" style="display: none;" />
                <div data-editor-schema={Lotus.JSON.encode!(@editor_schema || %{})} style="display: none;"></div>

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
                  <%= CellFormatter.format(Enum.at(row, index)) %>
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

                  <p class="text-base text-gray-600 mb-2 flex items-center justify-center gap-2">
                    <span>To run your query, click on the Run button or press</span>
                    <span class="inline-flex items-center gap-1">
                      <%= if Map.get(assigns, :os) == :mac do %>
                        <kbd class="px-2 py-1 bg-gray-100 border border-gray-300 rounded text-sm font-sans text-gray-700">⌘</kbd>
                        <span class="text-sm text-gray-500">+</span>
                        <kbd class="px-2 py-1 bg-gray-100 border border-gray-300 rounded text-sm font-sans text-gray-700">Enter</kbd>
                      <% else %>
                        <kbd class="px-2 py-1 bg-gray-100 border border-gray-300 rounded text-sm font-sans text-gray-700">Ctrl</kbd>
                        <span class="text-sm text-gray-500">+</span>
                        <kbd class="px-2 py-1 bg-gray-100 border border-gray-300 rounded text-sm font-sans text-gray-700">Enter</kbd>
                      <% end %>
                    </span>
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

        <.form for={@query_form}
               as={:save_query}
               phx-submit="save-query"
               phx-change="validate-save"
               phx-target={@myself}>
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

  @impl Lotus.Web.Page
  def handle_mount(socket) do
    socket
    |> assign_data_repos()
    |> assign_ui_state()
  end

  @impl Lotus.Web.Page
  def handle_params(_params, _uri, socket) do
    IO.inspect(socket.assigns.page)

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

  @impl Page
  def handle_info(_msg, socket), do: {:noreply, socket}

  @impl Phoenix.LiveComponent
  def handle_event("validate", %{"query" => query_params}, socket) do
    changeset =
      socket.assigns.query
      |> Query.update(query_params)
      |> Map.put(:action, :validate)

    form = to_form(changeset, as: "query")

    statement_empty =
      query_params["statement"]
      |> to_string()
      |> String.trim()
      |> Kernel.==("")

    send_update(SchemaExplorer,
      id: "schema-explorer",
      initial_database: query_params["data_repo"]
    )

    socket = maybe_update_editor_schema(socket, query_params["data_repo"])

    {:noreply,
     assign(socket,
       query_changeset: changeset,
       query_form: form,
       statement_empty: statement_empty
     )}
  end

  @impl Phoenix.LiveComponent
  def handle_event("editor_content_changed", %{"statement" => statement}, socket) do
    cs =
      socket.assigns.query
      |> Query.update(%{"statement" => statement})

    {:noreply,
     assign(socket,
       query: Ecto.Changeset.apply_changes(cs),
       query_changeset: cs,
       query_form: to_form(cs, as: "query"),
       statement_empty: String.trim(statement) == ""
     )}
  end

  @impl Phoenix.LiveComponent
  def handle_event("validate-save", %{"save_query" => save_params}, socket) do
    changeset =
      socket.assigns.query
      |> Query.update(save_params)
      |> Map.put(:action, :validate)

    form = to_form(changeset, as: "query")

    statement_present =
      socket.assigns.query_form[:statement].value
      |> to_string()
      |> String.trim() != ""

    name_present =
      String.trim(Phoenix.HTML.Form.input_value(form, :name) || "") != ""

    {:noreply,
     assign(socket,
       query_changeset: changeset,
       query_form: form,
       save_form_valid: name_present && statement_present
     )}
  end

  @impl Phoenix.LiveComponent
  def handle_event("save-query", %{"save_query" => save_params}, socket) do
    page = socket.assigns.page
    query_attrs = Map.merge(socket.assigns.query_form.params, save_params)

    result =
      case page do
        %{mode: :edit, id: id} ->
          case Lotus.get_query(id) do
            nil -> {:error, "Query not found"}
            %Query{} = query -> Lotus.update_query(query, query_attrs)
          end

        %{mode: :new} ->
          Lotus.create_query(query_attrs)
      end

    case result do
      {:ok, query} ->
        {:noreply,
         socket
         |> put_flash(:info, "Query saved successfully!")
         |> push_patch(to: lotus_path(["queries", query.id]), replace: true)
         |> assign(query: query)
         |> assign_query_changeset(query)}

      {:error, %Ecto.Changeset{} = cs} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to save query")
         |> assign(query_changeset: cs, query_form: to_form(cs, as: "query"))}
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
    socket =
      socket
      |> assign(schema_drawer_visible: not socket.assigns.schema_drawer_visible)
      |> assign(variable_drawer_visible: false)

    {:noreply, socket}
  end

  @impl Phoenix.LiveComponent
  def handle_event("close-drawer", _params, socket) do
    {:noreply, assign(socket, schema_drawer_visible: false)}
  end

  @impl Phoenix.LiveComponent
  def handle_event("toggle-variable-drawer", _params, socket) do
    socket =
      socket
      |> assign(variable_drawer_visible: not socket.assigns.variable_drawer_visible)
      |> assign(schema_drawer_visible: false)

    {:noreply, socket}
  end

  @impl Phoenix.LiveComponent
  def handle_event("close-variable-drawer", _params, socket) do
    {:noreply, assign(socket, variable_drawer_visible: false)}
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

    q = socket.assigns.query
    existing = q.variables
    existing_by_name = Map.new(existing, &{&1.name, &1})

    prev_names = Enum.map(existing, & &1.name)
    new_names = names -- prev_names
    should_open_drawer = new_names != [] and not socket.assigns.variable_drawer_visible

    ordered_vars =
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

    params = %{"variables" => Enum.map(ordered_vars, &variable_to_params/1)}

    changeset =
      q
      |> Query.update(params)
      |> Map.put(:action, :validate)

    socket =
      socket
      |> assign(
        query_changeset: changeset,
        query_form: to_form(changeset, as: "query"),
        query: Ecto.Changeset.apply_changes(changeset),
        variable_drawer_visible: should_open_drawer || socket.assigns.variable_drawer_visible,
        schema_drawer_visible:
          if(should_open_drawer, do: false, else: socket.assigns.schema_drawer_visible)
      )

    {:noreply, socket}
  end

  @impl Phoenix.LiveComponent
  def handle_event("run_query", %{"query" => query_params} = _payload, socket) do
    changeset =
      socket.assigns.query
      |> Query.update(query_params)
      |> Map.put(:action, :validate)

    form = to_form(changeset, as: "query")

    stmt =
      Phoenix.HTML.Form.input_value(form, :statement)
      |> to_string()
      |> String.trim()

    if stmt == "" do
      {:noreply,
       assign(socket, error: "Please enter a SQL statement", result: nil, running: false)}
    else
      query = Ecto.Changeset.apply_changes(changeset)
      vars = Map.get(socket.assigns, :var_values, %{})
      repo = query.data_repo || socket.assigns.default_repo
      opts = [repo: repo, vars: vars]

      socket =
        assign(socket,
          query_changeset: changeset,
          query_form: form,
          query: query,
          running: true,
          error: nil
        )

      case Lotus.run_query(query, opts) do
        {:ok, result} ->
          {:noreply, assign(socket, result: result, running: false)}

        {:error, msg} ->
          {:noreply, assign(socket, error: to_string(msg), result: nil, running: false)}
      end
    end
  end

  defp assign_data_repos(socket) do
    data_repo_names = Lotus.list_data_repo_names()
    default_repo = List.first(data_repo_names)
    assign(socket, data_repo_names: data_repo_names, default_repo: default_repo)
  end

  defp assign_ui_state(socket) do
    assign(socket,
      result: nil,
      error: nil,
      running: false,
      editor_minimized: false,
      schema_drawer_visible: false,
      variable_drawer_visible: false,
      editor_schema: nil,
      detected_variables: [],
      variable_form: to_form(%{}, as: "variables"),
      variable_configs: %{}
    )
  end

  defp assign_query_changeset(socket, %Query{} = query) do
    changeset = Query.update(query, %{})

    assign(socket,
      query: query,
      query_changeset: changeset,
      query_form: to_form(changeset, as: "query"),
      statement_empty: String.trim(query.statement) == ""
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

    case Lotus.run_query(query) do
      {:ok, result} ->
        assign(socket, result: result, error: nil, running: false)

      {:error, error_msg} ->
        assign(socket, error: error_msg, result: nil, running: false)
        socket
    end
  end

  defp execute_query(%{assigns: %{query: q, var_values: vals}} = socket) do
    opts = [repo: q.data_repo, vars: vals]

    case Lotus.run_query(q, opts) do
      {:ok, result} ->
        {:noreply, assign(socket, result: result, error: nil, running: false)}

      {:error, msg} ->
        {:noreply, assign(socket, result: nil, error: msg, running: false)}
    end
  end

  defp maybe_update_editor_schema(socket, data_repo) do
    if data_repo && data_repo != "" do
      case SchemaBuilder.build(data_repo) do
        {:ok, schema} ->
          assign(socket, editor_schema: schema)

        {:error, _reason} ->
          assign(socket, editor_schema: nil)
      end
    else
      assign(socket, editor_schema: nil)
    end
  end

  defp variable_to_params(%QueryVariable{} = v) do
    %{
      "name" => v.name,
      "type" => v.type,
      "widget" => v.widget,
      "label" => v.label,
      "default" => v.default,
      "static_options" => v.static_options,
      "options_query" => v.options_query
    }
  end

  defp format_variable_label(var_name) when is_binary(var_name) do
    var_name
    |> String.split("_")
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(" ")
  end

  defp format_variable_label(var_name), do: var_name

  defp variable_settings_drawer(assigns) do
    ~H"""
    <div
      class={[
        "absolute top-0 right-0 h-full bg-white border-l border-gray-200 z-10 transition-all duration-300 ease-in-out overflow-hidden",
        if(@variable_drawer_visible, do: "w-80", else: "w-0")
      ]}
    >
      <%= if @variable_drawer_visible do %>
        <div class="h-full flex flex-col">
          <div class="px-4 py-3 border-b border-gray-200 bg-gray-50 flex justify-between items-center">
            <h3 class="text-sm font-medium text-gray-900">Variables</h3>
            <button type="button" phx-click="close-variable-drawer" phx-target={@myself}>
              <Icons.x_mark class="h-4 w-4" />
            </button>
          </div>

          <div class="flex-1 overflow-y-auto p-4 space-y-6">
            <.form for={@query_form} phx-change="validate" phx-target={@myself}>
              <.inputs_for :let={vf} field={@query_form[:variables]}>
                <div class="border-b border-gray-200 pb-4 last:border-0 space-y-3">
                  <div>
                    <label class="text-xs font-medium text-gray-700">Variable name</label>
                    <div class="mt-1 text-sm text-pink-600 font-mono"><%= vf[:name].value %></div>
                  </div>

                  <.input type="select" field={vf[:type]} label="Variable type"
                          options={[{"Text","text"},{"Number","number"},{"Date","date"}]} />

                  <.input type="text" field={vf[:label]} label="Input label"
                          placeholder={"Label for #{vf[:name].value}"} />

                  <%= if vf[:type].value != :date do %>
                    <.input type="radio" field={vf[:widget]} value="input" label="Input box" checked={vf[:widget].value == :input}/>
                    <.input type="radio" field={vf[:widget]} value="select" label="Dropdown list" checked={vf[:widget].value == :select}/>
                  <% end %>

                  <%= if vf[:widget].value == :select do %>
                    <.input type="radio" name={"#{vf[:name].name}_option_source"} value="static" label="Static values"
                            checked={QueryVariable.get_option_source(vf.source.data) == :static}/>
                    <.input type="radio" name={"#{vf[:name].name}_option_source"} value="query" label="SQL query"
                            checked={QueryVariable.get_option_source(vf.source.data) == :query}/>

                    <%= if QueryVariable.get_option_source(vf.source.data) == :static do %>
                      <.input type="textarea" field={vf[:static_options]} label="Static options" rows="3"
                              placeholder="One option per line"/>
                    <% else %>
                      <.input type="textarea" field={vf[:options_query]} label="Options query" rows="3"
                              placeholder="SELECT value_column, label_column FROM table_name"/>
                    <% end %>
                  <% end %>

                  <.input type="text" field={vf[:default]} label="Default value"
                          placeholder="Enter a default value..." />
                </div>
              </.inputs_for>
            </.form>
          </div>
        </div>
      <% end %>
    </div>
    """
  end

  defp execute_options_query(query, data_repo) do
    case Lotus.run_sql(query, [], repo: data_repo) do
      {:ok, result} ->
        # Convert result to {label, value} format
        options =
          result.rows
          |> Enum.map(fn row ->
            case row do
              [value, label] -> {to_string(label), to_string(value)}
              # fallback if only one column
              [value] -> {to_string(value), to_string(value)}
              _ -> nil
            end
          end)
          |> Enum.reject(&is_nil/1)

        {:ok, options}

      {:error, error} ->
        {:error, "Query error: #{inspect(error)}"}
    end
  end
end

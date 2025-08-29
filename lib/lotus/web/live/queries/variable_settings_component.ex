defmodule Lotus.Web.Queries.VariableSettingsComponent do
  @moduledoc """
  A drawer component for configuring variables.
  """

  use Lotus.Web, :live_component

  alias Lotus.Storage.QueryVariable

  @impl Phoenix.LiveComponent
  def mount(socket) do
    {:ok, assign(socket, active_tab: nil)}
  end

  @impl Phoenix.LiveComponent
  def update(assigns, socket) do
    has_variables = not empty_variables?(assigns.form)

    active_tab =
      case assigns.active_tab do
        nil -> if has_variables, do: :settings, else: :help
        tab -> tab
      end

    {:ok,
     socket
     |> assign(assigns)
     |> assign(active_tab: active_tab, has_variables: has_variables)}
  end

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <div
      class={[
        "absolute top-0 right-0 h-full bg-white border-l border-gray-200 z-10 transition-all duration-300 ease-in-out overflow-hidden",
        if(@visible, do: "w-80", else: "w-0")
      ]}
    >
      <div class="h-full flex flex-col">
        <.variable_settings_header active_tab={@active_tab} has_variables={@has_variables} myself={@myself} parent={@parent} />
        <%= if @active_tab == :help do %>
          <.variable_settings_help />
        <% else %>
          <.variable_settings_form form={@form} parent={@parent} />
        <% end %>
      </div>
    </div>
    """
  end

  defp variable_settings_header(assigns) do
    ~H"""
    <div class="px-4 py-3 border-b border-gray-200 bg-gray-50 flex justify-between items-center">
      <div class="flex items-center space-x-4">
        <h3 class="text-sm font-medium text-gray-900">Variables</h3>
        <div class="flex space-x-2">
          <button
            type="button"
            phx-click="switch_variable_tab"
            phx-value-tab="settings"
            phx-target={@parent}
            disabled={not @has_variables}
            class={[
              "px-2 py-1 text-xs rounded transition-colors",
              if(@active_tab == :settings, do: "bg-blue-100 text-blue-700", else: "text-gray-500 hover:text-gray-700"),
              unless(@has_variables, do: "opacity-50 cursor-not-allowed")
            ]}
          >
            Settings
          </button>
          <button
            type="button"
            phx-click="switch_variable_tab"
            phx-value-tab="help"
            phx-target={@parent}
            class={[
              "px-2 py-1 text-xs rounded transition-colors",
              if(@active_tab == :help, do: "bg-blue-100 text-blue-700", else: "text-gray-500 hover:text-gray-700")
            ]}
          >
            Help
          </button>
        </div>
      </div>
      <button type="button" phx-click="close_variable_settings" phx-target={@parent}>
        <Icons.x_mark class="h-4 w-4" />
      </button>
    </div>
    """
  end

  defp variable_settings_form(assigns) do
    ~H"""
    <div class="flex-1 overflow-y-auto p-4 space-y-6">
        <.form for={@form} phx-change="validate" phx-target={@parent}>
          <.inputs_for :let={vf} field={@form[:variables]}>
            <div class="border-b border-gray-200 pb-4 last:border-0 space-y-3">
              <div>
                <.label for={vf[:name].id}>Variable name</.label>
                <div class="mt-1 text-sm text-pink-600 font-mono"><%= vf.source.data.name || vf[:name].value %></div>
                <input type="hidden" name={vf[:name].name} value={vf[:name].value} />
              </div>

              <.input type="select" field={vf[:type]} label="Variable type"
                      options={[{"Text","text"},{"Number","number"},{"Date","date"}]} />

              <.input type="text" field={vf[:label]} label="Input label"
                      placeholder={"Label for #{vf[:name].value}"} />

              <%= if vf[:type].value != :date do %>
                <.label>Widget type</.label>
                <.input type="radio" field={vf[:widget]} value="input" label="Input box" checked={vf[:widget].value == :input}/>
                <.input type="radio" field={vf[:widget]} value="select" label="Dropdown list" checked={vf[:widget].value == :select}/>
              <% end %>

              <%= if vf[:widget].value == :select do %>
                  <.select_options_configuration vf={vf} />
              <% end %>

              <.input type="text" field={vf[:default]} label="Default value"
                      placeholder="Enter a default value..." />
            </div>
          </.inputs_for>
        </.form>
    </div>
    """
  end

  defp select_options_configuration(assigns) do
    ~H"""
    <.label>Options</.label>
    <.input type="radio" name={"#{@vf[:name].name}_option_source"} value="static" label="Static values"
            checked={QueryVariable.get_option_source(@vf.source.data) == :static}/>
    <.input type="radio" name={"#{@vf[:name].name}_option_source"} value="query" label="SQL query (coming soon)"
            checked={QueryVariable.get_option_source(@vf.source.data) == :query} disabled={true}/>

    <%= if QueryVariable.get_option_source(@vf.source.data) == :static do %>
      <div>
        <textarea
          id={"#{@vf[:static_options].name}_textarea"}
          name={@vf[:static_options].name}
          rows="3"
          placeholder="One option per line"
          class="mt-2 block w-full rounded-lg text-sm min-h-[6rem] border-zinc-300 focus:border-zinc-400 focus:ring-0"
        ><%= (@vf[:static_options].value || []) |> Enum.join("\n") %></textarea>
      </div>
    <% else %>
      <.input type="textarea" field={@vf[:options_query]} rows="3"
              placeholder="SELECT value_column, label_column FROM table_name"/>
    <% end %>
    """
  end

  defp variable_settings_help(assigns) do
    ~H"""
    <div class="flex-1 overflow-y-auto p-5 text-sm text-gray-700 space-y-5">
        <div>
          <h3 class="text-sm font-semibold text-gray-900">Using variables</h3>
          <p class="mt-1">
            Add variables in SQL with <code class="font-mono text-xs bg-gray-100 px-1 py-0.5 rounded">&#123;&#123;var_name&#125;&#125;</code>.
            When you type one, Lotus detects it and adds an input in the toolbar.
          </p>
        </div>

        <div class="rounded-md bg-gray-50 border border-gray-200 p-3">
          <pre class="font-mono text-xs leading-5">
    SELECT *
    FROM orders
    WHERE status = &#123;&#123;status&#125;&#125;
      AND created_at &gt;= &#123;&#123;from_date&#125;&#125;
      AND total_amount &gt;= &#123;&#123;min_amount&#125;&#125;</pre>
        </div>
      <div class="space-y-2">
        <h4 class="text-xs uppercase tracking-wide text-gray-500">Types</h4>
        <ul class="list-disc pl-5 space-y-1">
          <li><span class="font-medium">Text</span> – plain strings (quoted for you)</li>
          <li><span class="font-medium">Number</span> – integers/decimals</li>
          <li><span class="font-medium">Date</span> – date picker, ISO date</li>
        </ul>
      </div>

      <div class="space-y-2">
        <h4 class="text-xs uppercase tracking-wide text-gray-500">Widgets</h4>
        <ul class="list-disc pl-5 space-y-1">
          <li><span class="font-medium">Input</span> – free text/number entry</li>
          <li>
            <span class="font-medium">Dropdown</span> – choose one:
            <ul class="list-disc pl-5 mt-1 space-y-1">
              <li>
                <span class="font-medium">Static options</span> –
                one per line. <code class="font-mono text-xs bg-gray-100 px-1 py-0.5 rounded">value</code>.
              </li>
              <li>
                <span class="font-medium">SQL query</span> <span class="text-xs bg-amber-100 text-amber-700 px-1 py-0.5 rounded">coming soon</span> –
                return columns as <code class="font-mono text-xs bg-gray-100 px-1 py-0.5 rounded">value, label</code>
                (or a single <code class="font-mono text-xs bg-gray-100 px-1 py-0.5 rounded">value</code> column).
              </li>
            </ul>
          </li>
        </ul>
      </div>

      <div class="space-y-2">
        <h4 class="text-xs uppercase tracking-wide text-gray-500">Labels & defaults</h4>
        <ul class="list-disc pl-5 space-y-1">
          <li>
            Label defaults to title-cased variable name
            (e.g. <code class="font-mono text-xs bg-gray-100 px-1 py-0.5 rounded">min_age</code> → <em>Min Age</em>).
          </li>
          <li>
            <span class="font-medium">Default value</span> is used if the toolbar input is empty.
          </li>
        </ul>
      </div>

      <div class="rounded-md bg-amber-50 border border-amber-200 p-3 text-amber-800">
        Values are always sent as prepared parameters (no string interpolation), using your DB dialect’s placeholders.
      </div>
    </div>
    """
  end

  defp empty_variables?(form) do
    vars =
      try do
        form[:variables].value
      rescue
        _ -> nil
      end

    case vars do
      nil -> true
      [] -> true
      %{} -> map_size(vars) == 0
      _ -> Enum.empty?(List.wrap(vars))
    end
  end
end

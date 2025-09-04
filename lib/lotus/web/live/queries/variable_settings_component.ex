defmodule Lotus.Web.Queries.VariableSettingsComponent do
  @moduledoc """
  A drawer component for configuring variables.
  """

  use Lotus.Web, :live_component

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
        "absolute top-0 right-0 h-full w-80 bg-white dark:bg-gray-800 border-l border-gray-200 dark:border-gray-700 z-10 transition-transform duration-300 ease-in-out overflow-hidden",
        if(@visible, do: "translate-x-0", else: "translate-x-full")
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
    <div class="px-4 py-3 border-b border-gray-200 dark:border-gray-700 bg-gray-50 dark:bg-gray-700 flex justify-between items-center">
      <div class="flex items-center space-x-4">
        <h3 class="text-sm font-medium text-text-light dark:text-text-dark">Variables</h3>
        <div class="flex space-x-2">
          <button
            type="button"
            phx-click="switch_variable_tab"
            phx-value-tab="settings"
            phx-target={@parent}
            disabled={not @has_variables}
            class={[
              "px-2 py-1 text-xs rounded transition-colors",
              if(@active_tab == :settings, do: "bg-blue-100 dark:bg-blue-900 text-blue-700 dark:text-blue-300", else: "text-gray-500 dark:text-gray-400 hover:text-gray-700 dark:hover:text-gray-300"),
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
              if(@active_tab == :help, do: "bg-blue-100 dark:bg-blue-900 text-blue-700 dark:text-blue-300", else: "text-gray-500 dark:text-gray-400 hover:text-gray-700 dark:hover:text-gray-300")
            ]}
          >
            Help
          </button>
        </div>
      </div>
      <button type="button" phx-click="close_variable_settings" phx-target={@parent}>
        <Icons.x_mark class="h-4 w-4 text-gray-400 dark:text-gray-500 hover:text-gray-600 dark:hover:text-gray-400" />
      </button>
    </div>
    """
  end

  defp variable_settings_form(assigns) do
    ~H"""
    <div class="flex-1 overflow-y-auto p-4 space-y-6">
        <.form for={@form} phx-change="validate" phx-target={@parent}>
          <.inputs_for :let={vf} field={@form[:variables]}>
            <div class="border-b border-gray-200 dark:border-gray-700 pb-4 last:border-0 space-y-3">
              <div>
                <.label>Variable name</.label>
                <div class="mt-1 text-sm text-pink-600 dark:text-pink-400 font-mono"><%= vf.source.data.name || vf[:name].value %></div>
                <input type="hidden" name={vf[:name].name} value={vf[:name].value} />
              </div>

              <.input type="select" field={vf[:type]} label="Variable type"
                      options={[{"Text","text"},{"Number","number"},{"Date","date"}]} />

              <.input type="text" field={vf[:label]} label="Input label"
                      placeholder={"Label for #{vf[:name].value}"} />

              <%= if vf[:type].value != :date do %>
                <fieldset>
                  <legend class="block text-sm font-semibold leading-6 text-text-light dark:text-text-dark">Widget type</legend>
                  <div class="mt-1 space-y-2">
                    <.input type="radio" field={vf[:widget]} value="input" label="Input box" checked={vf[:widget].value == :input}/>
                    <div class="flex items-center justify-between">
                      <.input type="radio" field={vf[:widget]} value="select" label="Dropdown list" checked={vf[:widget].value == :select}/>
                      <%= if vf[:widget].value == :select do %>
                        <button
                          type="button"
                          phx-click="open_dropdown_options_modal"
                          phx-value-variable={vf[:name].value}
                          phx-target={@parent}
                          class="text-sm text-pink-600 dark:text-pink-400 hover:text-pink-800 dark:hover:text-pink-300 font-medium"
                        >
                          Edit
                        </button>
                      <% end %>
                    </div>
                  </div>
                </fieldset>
              <% end %>

              <%= if vf[:widget].value == :select do %>
                  <.select_options_configuration vf={vf} parent={@parent} />
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
    <input type="hidden" name={@vf[:static_options].name} value={format_static_options_for_form(@vf[:static_options].value)} />
    <input type="hidden" name={@vf[:options_query].name} value={@vf[:options_query].value || ""} />
    """
  end

  defp format_static_options_for_form(static_options) do
    alias Lotus.Web.Formatters.VariableOptionsFormatter, as: OptionsFormatter
    OptionsFormatter.to_display_format(static_options || [])
  end

  defp variable_settings_help(assigns) do
    ~H"""
    <div class="flex-1 overflow-y-auto p-5 text-sm text-gray-700 dark:text-gray-300 space-y-5">
        <div>
          <h3 class="text-sm font-semibold text-text-light dark:text-text-dark">Using variables</h3>
          <p class="mt-1">
            Add variables in SQL with <code class="font-mono text-xs bg-gray-100 dark:bg-gray-700 dark:text-gray-200 px-1 py-0.5 rounded">&#123;&#123;var_name&#125;&#125;</code>.
            When you type one, Lotus detects it and adds an input in the toolbar.
          </p>
        </div>

        <div class="rounded-md bg-gray-50 dark:bg-gray-700 border border-gray-200 dark:border-gray-600 p-3">
          <pre class="font-mono text-xs leading-5 text-gray-800 dark:text-gray-200">
    SELECT *
    FROM orders
    WHERE status = &#123;&#123;status&#125;&#125;
      AND created_at &gt;= &#123;&#123;from_date&#125;&#125;
      AND total_amount &gt;= &#123;&#123;min_amount&#125;&#125;</pre>
        </div>
      <div class="space-y-2">
        <h4 class="text-xs uppercase tracking-wide text-gray-500 dark:text-gray-400">Types</h4>
        <ul class="list-disc pl-5 space-y-1">
          <li><span class="font-medium">Text</span> – plain strings (quoted for you)</li>
          <li><span class="font-medium">Number</span> – integers/decimals</li>
          <li><span class="font-medium">Date</span> – date picker, ISO date</li>
        </ul>
      </div>

      <div class="space-y-2">
        <h4 class="text-xs uppercase tracking-wide text-gray-500 dark:text-gray-400">Widgets</h4>
        <ul class="list-disc pl-5 space-y-1">
          <li><span class="font-medium">Input</span> – free text/number entry</li>
          <li>
            <span class="font-medium">Dropdown</span> – choose one:
            <ul class="list-disc pl-5 mt-1 space-y-1">
              <li>
                <span class="font-medium">Static options</span> –
                one per line. <code class="font-mono text-xs bg-gray-100 dark:bg-gray-700 dark:text-gray-200 px-1 py-0.5 rounded">value</code>.
              </li>
              <li>
                <span class="font-medium">SQL query</span> –
                return columns as <code class="font-mono text-xs bg-gray-100 dark:bg-gray-700 dark:text-gray-200 px-1 py-0.5 rounded">value, label</code>
                (or a single <code class="font-mono text-xs bg-gray-100 dark:bg-gray-700 dark:text-gray-200 px-1 py-0.5 rounded">value</code> column).
              </li>
            </ul>
          </li>
        </ul>
      </div>

      <div class="space-y-2">
        <h4 class="text-xs uppercase tracking-wide text-gray-500 dark:text-gray-400">Labels & defaults</h4>
        <ul class="list-disc pl-5 space-y-1">
          <li>
            Label defaults to title-cased variable name
            (e.g. <code class="font-mono text-xs bg-gray-100 dark:bg-gray-700 dark:text-gray-200 px-1 py-0.5 rounded">min_age</code> → <em>Min Age</em>).
          </li>
          <li>
            <span class="font-medium">Default value</span> is used if the toolbar input is empty.
          </li>
        </ul>
      </div>

      <div class="rounded-md bg-amber-50 dark:bg-amber-900/20 border border-amber-200 dark:border-amber-700 p-3 text-amber-800 dark:text-amber-200">
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

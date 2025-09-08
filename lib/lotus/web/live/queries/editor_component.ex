defmodule Lotus.Web.Queries.EditorComponent do
  use Lotus.Web, :html

  alias Lotus.Web.Queries.SegmentedDataSelectorComponent
  import Lotus.Web.Queries.WidgetComponent

  attr(:minimized, :boolean, default: false)
  attr(:running, :boolean, default: false)
  attr(:statement_empty, :boolean, default: false)
  attr(:schema_explorer_visible, :boolean, default: false)
  attr(:variable_settings_visible, :boolean, default: false)
  attr(:form, Phoenix.HTML.Form, required: true)
  attr(:target, Phoenix.LiveComponent.CID, required: true)
  attr(:data_repo_names, :list, default: [])
  attr(:schema, :map, default: %{})
  attr(:dialect, :string, default: "postgres")
  attr(:variables, :list, default: [])
  attr(:variable_values, :map, default: %{})
  attr(:resolved_variable_options, :map, default: %{})

  def editor(assigns) do
    search_path_field = assigns.form[:search_path]

    search_path_value =
      case search_path_field.value do
        nil -> ""
        [] -> ""
        list when is_list(list) -> Enum.join(list, ",")
        value when is_binary(value) -> value
      end

    show_search_path = search_path_value != ""

    assigns =
      assigns
      |> assign(:search_path_value, search_path_value)
      |> assign(:show_search_path, show_search_path)

    ~H"""
    <.form for={@form} phx-submit="run_query" phx-target={@target} phx-change="validate">
      <div class="bg-editor-light dark:bg-editor-dark">
        <.render_toolbar
          form={@form}
          data_repo_names={@data_repo_names}
          schema_explorer_visible={@schema_explorer_visible}
          variable_settings_visible={@variable_settings_visible}
          target={@target}
          minimized={@minimized}
          variables={@variables}
          variable_values={@variable_values}
          resolved_variable_options={@resolved_variable_options}
        />

        <div class={["relative pb-8", if(@minimized, do: "hidden", else: "")]}>
          <div id="editor" phx-update="ignore" class="w-full bg-editor-light dark:bg-editor-dark" style="min-height: 300px;"></div>
          <.input type="textarea" field={@form[:statement]} phx-hook="EditorForm" style="display: none;" />
          <div
            data-editor-schema={Lotus.JSON.encode!(@schema || %{})}
            data-editor-dialect={@dialect || "postgres"}
            style="display: none;">
          </div>

          <%= if @show_search_path do %>
            <div class="absolute bottom-2 left-4 flex items-center gap-2 text-sm">
              <span class="font-medium text-gray-600 dark:text-gray-400">search_path:</span>
              <code class="px-2 py-0.5 bg-gray-100/80 dark:bg-gray-700/80 backdrop-blur-sm rounded text-xs font-mono text-gray-700 dark:text-gray-300">
                <%= @search_path_value %>
              </code>
            </div>
          <% end %>

          <button
            id="run-query-btn"
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
    """
  end

  attr(:form, Phoenix.HTML.Form, required: true)
  attr(:data_repo_names, :list, default: [])
  attr(:schema_explorer_visible, :boolean, default: false)
  attr(:variable_settings_visible, :boolean, default: false)
  attr(:target, Phoenix.LiveComponent.CID, required: true)
  attr(:minimized, :boolean, default: false)
  attr(:variables, :list, default: [])
  attr(:variable_values, :map, default: %{})
  attr(:resolved_variable_options, :map, default: %{})

  def render_toolbar(assigns) do
    ~H"""
    <div class="w-full border-b border-gray-200 dark:border-gray-700">
      <span class="sr-only">Toolbar</span>
      <div class="flex flex-col sm:flex-row sm:items-center w-full px-3 sm:px-6 py-3 gap-3 sm:gap-4">
        <div class="flex items-center gap-2 sm:gap-4">
          <.live_component
            module={SegmentedDataSelectorComponent}
            id="data-selector"
            source_field={@form[:data_repo]}
            schema_field={@form[:search_path]}
            source_options={Enum.map(@data_repo_names, &{&1, &1})}
            source_id="source-selector"
            schema_id="schema-selector"
            target_field="data_repo"
            parent={@target}
            disabled={false}
          />
        </div>

        <div class="hidden sm:block w-px self-stretch bg-gray-300 dark:bg-gray-600"></div>

        <div class="flex-1 flex flex-wrap gap-2 sm:gap-3 items-center">
          <%= for v <- @variables do %>
            <.widget
              var={v}
              value={Map.get(@variable_values, v.name, v.default)}
              resolved_options={get_variable_options(@resolved_variable_options, v.name)}
            />
          <% end %>
        </div>

        <div class="flex justify-end sm:justify-start">
          <.render_actions
            target={@target}
            schema_explorer_visible={@schema_explorer_visible}
            variable_settings_visible={@variable_settings_visible}
            minimized={@minimized}
          />
        </div>
      </div>
    </div>
    """
  end

  attr(:target, Phoenix.LiveComponent.CID, required: true)
  attr(:schema_explorer_visible, :boolean, default: false)
  attr(:variable_settings_visible, :boolean, default: false)
  attr(:minimized, :boolean, default: false)

  def render_actions(assigns) do
    ~H"""
    <div class="flex items-center space-x-1">
      <button
        id="copy-query-btn"
        type="button"
        phx-click="copy_query"
        phx-target={@target}
        class="p-2 text-gray-400 dark:text-gray-500 hover:text-gray-600 dark:hover:text-gray-400 transition-colors"
        data-title="Copy query to clipboard"
        phx-hook="Tippy"
      >
        <Icons.clipboard_copy class="h-5 w-5" />
      </button>
      <button
        id="variable-settings-btn"
        type="button"
        phx-click="toggle_variable_settings"
        phx-target={@target}
        class={[
          "p-2 transition-colors",
          if(@variable_settings_visible,
            do: "text-pink-600 hover:text-pink-700",
            else: "text-gray-400 dark:text-gray-500 hover:text-gray-600 dark:hover:text-gray-400"
          )
        ]}
        data-title="Variable settings"
        phx-hook="Tippy"
      >
        <Icons.variable class="h-5 w-5" />
      </button>
      <button
        id="schema-explorer-btn"
        type="button"
        phx-click="toggle_schema_explorer"
        phx-target={@target}
        class={[
          "p-2 transition-colors",
          if(@schema_explorer_visible,
            do: "text-pink-600 hover:text-pink-700",
            else: "text-gray-400 dark:text-gray-500 hover:text-gray-600 dark:hover:text-gray-400"
          )
        ]}
        data-title="Browse tables"
        phx-hook="Tippy"
      >
        <Icons.tables class="h-5 w-5" />
      </button>

      <button
        id="toggle-editor-btn"
        type="button"
        phx-click="toggle_editor"
        phx-target={@target}
        class="p-2 text-gray-400 dark:text-gray-500 hover:text-gray-600 dark:hover:text-gray-400 transition-colors"
        data-title={if @minimized, do: "Expand editor", else: "Minimize editor"}
        phx-hook="Tippy"
      >
        <%= if @minimized do %>
          <Icons.maximize class="h-5 w-5" />
        <% else %>
          <Icons.minimize class="h-5 w-5" />
        <% end %>
      </button>
    </div>
    """
  end

  defp get_variable_options(options, variable_name) do
    Map.get(options, variable_name)
  end
end

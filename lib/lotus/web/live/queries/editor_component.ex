defmodule Lotus.Web.Queries.EditorComponent do
  use Lotus.Web, :html

  alias Lotus.Web.Queries.ToolbarComponents, as: Toolbar
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

  def editor(assigns) do
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
        />

        <div class={["relative", if(@minimized, do: "hidden", else: "")]}>
          <div id="editor" phx-update="ignore" class="w-full bg-editor-light dark:bg-editor-dark" style="min-height: 300px;"></div>
          <.input type="textarea" field={@form[:statement]} phx-hook="EditorForm" style="display: none;" />
          <div
            data-editor-schema={Lotus.JSON.encode!(@schema || %{})}
            data-editor-dialect={@dialect || "postgres"}
            style="display: none;">
          </div>

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

  def render_toolbar(assigns) do
    ~H"""
    <div class="flex items-center w-full px-6 py-3 border-b border-gray-200 dark:border-gray-700 gap-4">
      <div class="w-48">
        <Toolbar.input
          type="select"
          field={@form[:data_repo]}
          label="Source"
          prompt="Select a database"
          options={Enum.map(@data_repo_names, &{&1, &1})}
          show_icons={true}
        />
      </div>

      <div class="w-px self-stretch bg-gray-300 dark:bg-gray-600"></div>

      <div class="flex-1 flex flex-wrap gap-3 items-center">
        <%= for v <- @variables do %>
          <.widget var={v} value={Map.get(@variable_values, v.name, v.default)} />
        <% end %>
      </div>

      <.render_actions
        target={@target}
        schema_explorer_visible={@schema_explorer_visible}
        variable_settings_visible={@variable_settings_visible}
        minimized={@minimized}
      />
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
        title="Variable settings"
      >
        <Icons.variable class="h-5 w-5" />
      </button>
      <button
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
        title="Browse tables"
      >
        <Icons.tables class="h-5 w-5" />
      </button>

      <button
        type="button"
        phx-click="toggle_editor"
        phx-target={@target}
        class="p-2 text-gray-400 dark:text-gray-500 hover:text-gray-600 dark:hover:text-gray-400 transition-colors"
        title={if @minimized, do: "Expand editor", else: "Minimize editor"}
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
end

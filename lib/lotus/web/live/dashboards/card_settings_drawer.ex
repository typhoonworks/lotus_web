defmodule Lotus.Web.Dashboards.CardSettingsDrawer do
  @moduledoc """
  Drawer component for configuring individual dashboard cards.
  Slides in from the right side.
  """

  use Lotus.Web, :live_component

  @impl Phoenix.LiveComponent
  def mount(socket) do
    {:ok,
     assign(socket,
       visible: false,
       card: nil,
       filters: [],
       available_columns: []
     )}
  end

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <div
      class={[
        "fixed sm:absolute top-0 right-0 h-full w-full sm:w-80 bg-white dark:bg-gray-800 border-l border-gray-200 dark:border-gray-700 z-20 transition-transform duration-300 ease-in-out overflow-hidden",
        if(@visible, do: "translate-x-0", else: "translate-x-full")
      ]}
    >
      <%= if @visible && @card do %>
        <div class="h-full flex flex-col">
          <.header card={@card} parent={@parent} />
          <div class="flex-1 overflow-y-auto p-4 space-y-6">
            <.title_section card={@card} parent={@parent} />
            <.layout_section card={@card} parent={@parent} />

            <%= if @card.card_type == :query do %>
              <.visualization_section card={@card} columns={@available_columns} parent={@parent} />
              <.filter_mapping_section card={@card} filters={@filters} parent={@parent} />
            <% else %>
              <.content_section card={@card} parent={@parent} />
            <% end %>

            <.danger_section card={@card} parent={@parent} />
          </div>
        </div>
      <% end %>
    </div>
    """
  end

  defp header(assigns) do
    ~H"""
    <div class="px-4 py-3 border-b border-gray-200 dark:border-gray-700 bg-gray-50 dark:bg-gray-700/50 flex items-center justify-between">
      <h3 class="font-medium text-gray-900 dark:text-white">
        <%= gettext("Card Settings") %>
      </h3>
      <button
        phx-click="close_card_settings"
        phx-target={@parent}
        class="p-1 text-gray-400 hover:text-gray-600 dark:hover:text-gray-300"
      >
        <Icons.x_mark class="h-5 w-5" />
      </button>
    </div>
    """
  end

  defp title_section(assigns) do
    ~H"""
    <div>
      <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
        <%= gettext("Card Title") %>
      </label>
      <form phx-change="update_card_title" phx-target={@parent}>
        <input type="hidden" name="card_id" value={@card.id} />
        <input
          type="text"
          name="title"
          value={@card.title || ""}
          phx-debounce="150"
          placeholder={default_title(@card)}
          class="w-full border border-gray-300 dark:border-gray-600 rounded-lg p-2.5 bg-white dark:bg-gray-700 dark:text-white focus:ring-pink-500 focus:border-pink-500"
        />
      </form>
    </div>
    """
  end

  defp layout_section(assigns) do
    layout = assigns.card.layout || %{x: 0, y: 0, w: 6, h: 4}

    assigns =
      assign(assigns,
        layout_x: get_layout_value(layout, :x, 0),
        layout_y: get_layout_value(layout, :y, 0),
        layout_w: get_layout_value(layout, :w, 6),
        layout_h: get_layout_value(layout, :h, 4)
      )

    ~H"""
    <div>
      <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
        <%= gettext("Layout Position") %>
      </label>
      <form phx-change="update_card_layout" phx-target={@parent}>
        <input type="hidden" name="card_id" value={@card.id} />
        <div class="grid grid-cols-2 gap-3">
          <div>
            <label class="block text-xs text-gray-500 dark:text-gray-400 mb-1">
              <%= gettext("X (0-11)") %>
            </label>
            <input
              type="number"
              name="layout[x]"
              value={@layout_x}
              min="0"
              max="11"
              class="w-full border border-gray-300 dark:border-gray-600 rounded-lg p-2 text-sm bg-white dark:bg-gray-700 dark:text-white focus:ring-pink-500 focus:border-pink-500"
            />
          </div>
          <div>
            <label class="block text-xs text-gray-500 dark:text-gray-400 mb-1">
              <%= gettext("Y Position") %>
            </label>
            <input
              type="number"
              name="layout[y]"
              value={@layout_y}
              min="0"
              class="w-full border border-gray-300 dark:border-gray-600 rounded-lg p-2 text-sm bg-white dark:bg-gray-700 dark:text-white focus:ring-pink-500 focus:border-pink-500"
            />
          </div>
          <div>
            <label class="block text-xs text-gray-500 dark:text-gray-400 mb-1">
              <%= gettext("Width (1-12)") %>
            </label>
            <input
              type="number"
              name="layout[w]"
              value={@layout_w}
              min="1"
              max="12"
              class="w-full border border-gray-300 dark:border-gray-600 rounded-lg p-2 text-sm bg-white dark:bg-gray-700 dark:text-white focus:ring-pink-500 focus:border-pink-500"
            />
          </div>
          <div>
            <label class="block text-xs text-gray-500 dark:text-gray-400 mb-1">
              <%= gettext("Height") %>
            </label>
            <input
              type="number"
              name="layout[h]"
              value={@layout_h}
              min="1"
              class="w-full border border-gray-300 dark:border-gray-600 rounded-lg p-2 text-sm bg-white dark:bg-gray-700 dark:text-white focus:ring-pink-500 focus:border-pink-500"
            />
          </div>
        </div>
      </form>
      <p class="mt-2 text-xs text-gray-500 dark:text-gray-400">
        <%= gettext("Grid uses 12 columns. Cards are positioned by column (X) and row (Y).") %>
      </p>
    </div>
    """
  end

  defp get_layout_value(layout, key, default) when is_atom(key) do
    Map.get(layout, key, Map.get(layout, to_string(key), default))
  end

  defp visualization_section(assigns) do
    config = assigns.card.visualization_config || %{}

    assigns =
      assign(assigns,
        chart_type: Map.get(config, "chart_type", Map.get(config, :chart_type)),
        x_field: Map.get(config, "x_field", Map.get(config, :x_field)),
        y_field: Map.get(config, "y_field", Map.get(config, :y_field)),
        series_field: Map.get(config, "series_field", Map.get(config, :series_field))
      )

    ~H"""
    <div>
      <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
        <%= gettext("Visualization") %>
      </label>
      <form phx-change="update_card_visualization" phx-target={@parent}>
        <input type="hidden" name="card_id" value={@card.id} />

        <div class="space-y-3">
          <div>
            <label class="block text-xs text-gray-500 dark:text-gray-400 mb-1">
              <%= gettext("Chart Type") %>
            </label>
            <select
              name="visualization[chart_type]"
              class="w-full border border-gray-300 dark:border-gray-600 rounded-lg p-2 text-sm bg-white dark:bg-gray-700 dark:text-white focus:ring-pink-500 focus:border-pink-500"
            >
              <option value=""><%= gettext("Table (default)") %></option>
              <option value="bar" selected={@chart_type == "bar"}><%= gettext("Bar Chart") %></option>
              <option value="line" selected={@chart_type == "line"}><%= gettext("Line Chart") %></option>
              <option value="area" selected={@chart_type == "area"}><%= gettext("Area Chart") %></option>
              <option value="scatter" selected={@chart_type == "scatter"}><%= gettext("Scatter Plot") %></option>
              <option value="pie" selected={@chart_type == "pie"}><%= gettext("Pie Chart") %></option>
            </select>
          </div>

          <%= if @chart_type do %>
            <div>
              <label class="block text-xs text-gray-500 dark:text-gray-400 mb-1">
                <%= gettext("X-Axis Field") %>
              </label>
              <select
                name="visualization[x_field]"
                class="w-full border border-gray-300 dark:border-gray-600 rounded-lg p-2 text-sm bg-white dark:bg-gray-700 dark:text-white focus:ring-pink-500 focus:border-pink-500"
              >
                <option value=""><%= gettext("Select field...") %></option>
                <%= for col <- @columns do %>
                  <option value={col} selected={@x_field == col}><%= col %></option>
                <% end %>
              </select>
            </div>

            <div>
              <label class="block text-xs text-gray-500 dark:text-gray-400 mb-1">
                <%= gettext("Y-Axis Field") %>
              </label>
              <select
                name="visualization[y_field]"
                class="w-full border border-gray-300 dark:border-gray-600 rounded-lg p-2 text-sm bg-white dark:bg-gray-700 dark:text-white focus:ring-pink-500 focus:border-pink-500"
              >
                <option value=""><%= gettext("Select field...") %></option>
                <%= for col <- @columns do %>
                  <option value={col} selected={@y_field == col}><%= col %></option>
                <% end %>
              </select>
            </div>

            <div>
              <label class="block text-xs text-gray-500 dark:text-gray-400 mb-1">
                <%= gettext("Color/Series Field") %> <span class="text-gray-400">(<%= gettext("optional") %>)</span>
              </label>
              <select
                name="visualization[series_field]"
                class="w-full border border-gray-300 dark:border-gray-600 rounded-lg p-2 text-sm bg-white dark:bg-gray-700 dark:text-white focus:ring-pink-500 focus:border-pink-500"
              >
                <option value=""><%= gettext("None") %></option>
                <%= for col <- @columns do %>
                  <option value={col} selected={@series_field == col}><%= col %></option>
                <% end %>
              </select>
            </div>
          <% end %>
        </div>
      </form>
    </div>
    """
  end

  defp filter_mapping_section(assigns) do
    ~H"""
    <div>
      <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
        <%= gettext("Filter Mappings") %>
      </label>
      <%= if @filters == [] do %>
        <p class="text-sm text-gray-500 dark:text-gray-400">
          <%= gettext("No dashboard filters configured.") %>
        </p>
      <% else %>
        <div class="space-y-2">
          <%= for filter <- @filters do %>
            <.filter_mapping_row filter={filter} card={@card} parent={@parent} />
          <% end %>
        </div>
      <% end %>
    </div>
    """
  end

  defp filter_mapping_row(assigns) do
    query = assigns.card.query
    variables = if query, do: query.variables || [], else: []
    current_mapping = Map.get(assigns.card.filter_mappings || %{}, assigns.filter.name)
    assigns = assign(assigns, variables: variables, current_mapping: current_mapping)

    ~H"""
    <div class="flex items-center gap-2 p-2 bg-gray-50 dark:bg-gray-700/50 rounded-lg">
      <span class="text-sm text-gray-700 dark:text-gray-300 min-w-[80px]">
        <%= @filter.label || @filter.name %>
      </span>
      <Icons.chevron_right class="h-4 w-4 text-gray-400" />
      <select
        name={"filter_mapping[#{@filter.name}]"}
        phx-change="update_filter_mapping"
        phx-target={@parent}
        phx-value-card-id={@card.id}
        phx-value-filter-name={@filter.name}
        class="flex-1 border border-gray-300 dark:border-gray-600 rounded p-1.5 text-sm bg-white dark:bg-gray-700 dark:text-white focus:ring-pink-500 focus:border-pink-500"
      >
        <option value=""><%= gettext("Not mapped") %></option>
        <%= for var <- @variables do %>
          <option value={var.name} selected={@current_mapping == var.name}>
            <%= var.label || var.name %>
          </option>
        <% end %>
      </select>
    </div>
    """
  end

  defp content_section(assigns) do
    content_value = get_content_value(assigns.card)
    assigns = assign(assigns, :content_value, content_value)

    ~H"""
    <div>
      <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
        <%= content_label(@card.card_type) %>
      </label>
      <form phx-change="update_card_content" phx-target={@parent}>
        <input type="hidden" name="card_id" value={@card.id} />
        <input type="hidden" name="card_type" value={@card.card_type} />
        <%= if @card.card_type == :link do %>
          <input
            type="url"
            name="content"
            value={@content_value}
            phx-debounce="150"
            placeholder="https://example.com"
            class="w-full border border-gray-300 dark:border-gray-600 rounded-lg p-2.5 bg-white dark:bg-gray-700 dark:text-white focus:ring-pink-500 focus:border-pink-500"
          />
        <% else %>
          <textarea
            name="content"
            phx-debounce="150"
            rows="4"
            placeholder={content_placeholder(@card.card_type)}
            class="w-full border border-gray-300 dark:border-gray-600 rounded-lg p-2.5 bg-white dark:bg-gray-700 dark:text-white focus:ring-pink-500 focus:border-pink-500"
          ><%= @content_value %></textarea>
        <% end %>
      </form>
    </div>
    """
  end

  defp get_content_value(%{card_type: :link, content: content}) do
    case content do
      nil -> ""
      url when is_binary(url) -> url
      %{"url" => url} -> url || ""
      %{url: url} -> url || ""
      _ -> ""
    end
  end

  defp get_content_value(%{card_type: type, content: content}) when type in [:text, :heading] do
    case content do
      nil -> ""
      text when is_binary(text) -> text
      %{"text" => text} -> text || ""
      %{text: text} -> text || ""
      _ -> ""
    end
  end

  defp get_content_value(_), do: ""

  defp content_label(:text), do: gettext("Text Content")
  defp content_label(:heading), do: gettext("Heading Text")
  defp content_label(:link), do: gettext("Link URL")
  defp content_label(_), do: gettext("Content")

  defp content_placeholder(:text), do: gettext("Enter text or markdown content...")
  defp content_placeholder(:heading), do: gettext("Enter heading text...")
  defp content_placeholder(_), do: ""

  defp danger_section(assigns) do
    ~H"""
    <div class="pt-4 border-t border-gray-200 dark:border-gray-700">
      <button
        phx-click="delete_card"
        phx-value-card-id={@card.id}
        phx-target={@parent}
        data-confirm={gettext("Are you sure you want to delete this card?")}
        class="w-full flex items-center justify-center gap-2 px-4 py-2 text-sm font-medium text-red-600 dark:text-red-400 bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-lg hover:bg-red-100 dark:hover:bg-red-900/30 transition-colors"
      >
        <Icons.trash class="h-4 w-4" />
        <%= gettext("Delete Card") %>
      </button>
    </div>
    """
  end

  defp default_title(%{card_type: :query, query: query}) when not is_nil(query) do
    query.name || gettext("Query")
  end

  defp default_title(%{card_type: :query}), do: gettext("Query")
  defp default_title(%{card_type: :text}), do: gettext("Text")
  defp default_title(%{card_type: :heading}), do: gettext("Heading")
  defp default_title(%{card_type: :link}), do: gettext("Link")
  defp default_title(_), do: gettext("Card")

  @impl Phoenix.LiveComponent
  def update(params, socket) do
    {:ok, assign(socket, params)}
  end
end

defmodule Lotus.Web.Dashboards.FilterBarComponent do
  @moduledoc """
  Renders the dashboard filter bar with filter widgets.
  """

  use Lotus.Web, :live_component

  @impl Phoenix.LiveComponent
  def mount(socket) do
    {:ok, assign(socket, filters: [], filter_values: %{})}
  end

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <div class="px-4 sm:px-6 py-3 border-b border-gray-200 dark:border-gray-700 bg-gray-50 dark:bg-gray-700/50">
      <form phx-change="filter_changed" phx-target={@parent} class="flex flex-wrap items-end gap-4">
        <%= for filter <- Enum.sort_by(@filters, & &1.position) do %>
          <.filter_widget
            filter={filter}
            value={Map.get(@filter_values, filter.name, filter.default_value)}
          />
        <% end %>

        <button
          type="button"
          phx-click="add_filter"
          phx-target={@parent}
          class="inline-flex items-center gap-1 text-sm text-pink-600 hover:text-pink-700 dark:text-pink-400 dark:hover:text-pink-300 pb-2"
        >
          <Icons.plus class="h-4 w-4" />
          <%= gettext("Add Filter") %>
        </button>
      </form>
    </div>
    """
  end

  defp filter_widget(assigns) do
    ~H"""
    <div class="min-w-[150px]">
      <label class="block text-xs font-medium text-gray-500 dark:text-gray-400 mb-1">
        <%= @filter.label || @filter.name %>
      </label>
      <%= case @filter.widget do %>
        <% :input -> %>
          <input
            type={input_type(@filter.filter_type)}
            name={"filter[#{@filter.name}]"}
            value={@value || ""}
            placeholder={@filter.label || @filter.name}
            class="w-full border border-gray-300 dark:border-gray-600 rounded-lg px-3 py-2 text-sm bg-white dark:bg-gray-700 dark:text-white focus:ring-pink-500 focus:border-pink-500"
          />
        <% :select -> %>
          <select
            name={"filter[#{@filter.name}]"}
            class="w-full border border-gray-300 dark:border-gray-600 rounded-lg px-3 py-2 text-sm bg-white dark:bg-gray-700 dark:text-white focus:ring-pink-500 focus:border-pink-500"
          >
            <option value=""><%= gettext("All") %></option>
            <%= for opt <- (@filter.config["options"] || []) do %>
              <option value={option_value(opt)} selected={@value == option_value(opt)}>
                <%= option_label(opt) %>
              </option>
            <% end %>
          </select>
        <% :date_picker -> %>
          <input
            type="date"
            name={"filter[#{@filter.name}]"}
            value={@value || ""}
            class="w-full border border-gray-300 dark:border-gray-600 rounded-lg px-3 py-2 text-sm bg-white dark:bg-gray-700 dark:text-white focus:ring-pink-500 focus:border-pink-500"
          />
        <% :date_range_picker -> %>
          <.date_range_picker filter={@filter} value={@value} />
        <% _ -> %>
          <input
            type="text"
            name={"filter[#{@filter.name}]"}
            value={@value || ""}
            placeholder={@filter.label || @filter.name}
            class="w-full border border-gray-300 dark:border-gray-600 rounded-lg px-3 py-2 text-sm bg-white dark:bg-gray-700 dark:text-white focus:ring-pink-500 focus:border-pink-500"
          />
      <% end %>
    </div>
    """
  end

  defp date_range_picker(assigns) do
    {start_value, end_value} = parse_date_range(assigns.value)
    assigns = assign(assigns, start_value: start_value, end_value: end_value)

    ~H"""
    <div class="flex items-center gap-2">
      <input
        type="date"
        name={"filter[#{@filter.name}][start]"}
        value={@start_value}
        class="flex-1 border border-gray-300 dark:border-gray-600 rounded-lg px-3 py-2 text-sm bg-white dark:bg-gray-700 dark:text-white focus:ring-pink-500 focus:border-pink-500"
      />
      <span class="text-gray-400">-</span>
      <input
        type="date"
        name={"filter[#{@filter.name}][end]"}
        value={@end_value}
        class="flex-1 border border-gray-300 dark:border-gray-600 rounded-lg px-3 py-2 text-sm bg-white dark:bg-gray-700 dark:text-white focus:ring-pink-500 focus:border-pink-500"
      />
    </div>
    """
  end

  defp input_type(:text), do: "text"
  defp input_type(:integer), do: "number"
  defp input_type(:float), do: "number"
  defp input_type(:date), do: "date"
  defp input_type(:datetime), do: "datetime-local"
  defp input_type(_), do: "text"

  defp option_value(%{"value" => value}), do: value
  defp option_value(%{value: value}), do: value
  defp option_value(value) when is_binary(value), do: value
  defp option_value(value), do: to_string(value)

  defp option_label(%{"label" => label}), do: label
  defp option_label(%{label: label}), do: label
  defp option_label(%{"value" => value}), do: value
  defp option_label(%{value: value}), do: value
  defp option_label(value), do: to_string(value)

  defp parse_date_range(nil), do: {nil, nil}
  defp parse_date_range(%{"start" => start, "end" => end_val}), do: {start, end_val}
  defp parse_date_range(%{start: start, end: end_val}), do: {start, end_val}
  defp parse_date_range(_), do: {nil, nil}

  @impl Phoenix.LiveComponent
  def update(params, socket) do
    {:ok, assign(socket, params)}
  end
end

defmodule Lotus.Web.Queries.ResultsComponent do
  use Lotus.Web, :html

  alias Lotus.Web.CellFormatter

  attr(:result, :any, default: nil)
  attr(:error, :string, default: nil)
  attr(:os, :atom, default: :unknown)
  attr(:target, Phoenix.LiveComponent.CID, default: nil)

  def render_result(assigns) do
    ~H"""
    <div class="px-4 sm:px-6 lg:px-8">
      <%= cond do %>
        <% @result != nil -> %>
          <div class="mt-6">
            <h2 class="text-lg font-semibold text-text-light dark:text-text-dark mb-3">Results</h2>
            <div class="flex items-center justify-between">
              <div>
                <span class="inline-flex items-center gap-1.5 px-2.5 py-1 text-sm font-medium bg-green-50 text-green-700 dark:bg-green-900/20 dark:text-green-400 rounded-md">
                  <Icons.check class="w-4 h-4" />
                  Success
                </span>
                <div class="text-sm text-gray-600 dark:text-gray-400 mt-1">
                  <%= @result.num_rows %> rows • <%= @result.duration_ms %>ms
                </div>
              </div>
              <button 
                phx-click="export_csv"
                phx-target={@target}
                class="inline-flex items-center gap-1.5 px-3 py-1.5 text-sm font-medium text-gray-600 dark:text-gray-400 hover:text-gray-900 dark:hover:text-gray-200 hover:bg-gray-50 dark:hover:bg-gray-800 rounded-md transition-colors">
                <Icons.download class="h-5 w-5" />
                Export (.csv)
              </button>
            </div>
          </div>
          <div class="overflow-x-auto mt-2">
            <.table id="query-results" rows={@result.rows}>
              <:col :let={row} :for={{col, index} <- Enum.with_index(@result.columns)} label={col}>
                <%= CellFormatter.format(Enum.at(row, index)) %>
              </:col>
            </.table>
            <%= if Enum.empty?(@result.rows) do %>
              <div class="text-center py-12 text-gray-500 dark:text-gray-400">
                <p class="text-base">No results found</p>
                <p class="text-sm mt-1">Your query returned no rows</p>
              </div>
            <% end %>
          </div>

        <% is_binary(@error) and @error != "" -> %>
          <div class="mt-6">
            <h2 class="text-lg font-semibold text-text-light dark:text-text-dark mb-3">Results</h2>
            <div class="flex items-center justify-between">
              <div>
                <span class="inline-flex items-center gap-1.5 px-2.5 py-1 text-sm font-medium bg-red-50 text-red-700 dark:bg-red-900/20 dark:text-red-400 rounded-md">
                  <Icons.x_mark class="w-4 h-4" />
                  Error
                </span>
              </div>
            </div>
          </div>
          <.render_error error={@error} />

        <% true -> %>
          <.empty_state os={@os} />
      <% end %>
    </div>
    """
  end

  attr(:error, :string, required: true)

  defp render_error(assigns) do
    ~H"""
    <div class="flex flex-col items-center justify-center py-16 text-gray-500">
      <div class="text-red-600 text-center">
        <p class="text-sm mt-1"><%= @error %></p>
      </div>
    </div>
    """
  end

  attr(:os, :atom, default: :unknown)

  defp empty_state(assigns) do
    ~H"""
    <div class="flex flex-col items-center justify-center py-16 text-gray-500">
      <div class="w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center mb-6">
        <Icons.terminal class="h-8 w-8 text-gray-400" />
      </div>

      <p class="text-base text-gray-600 mb-2 flex items-center justify-center gap-2">
        <span>To run your query, click on the Run button or press</span>
        <span class="inline-flex items-center gap-1">
          <%= if @os == :mac do %>
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
    </div>
    """
  end
end

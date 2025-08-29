defmodule Lotus.Web.Queries.ResultsComponent do
  use Lotus.Web, :html

  alias Lotus.Web.CellFormatter

  attr(:result, :any, default: nil)
  attr(:error, :string, default: nil)
  attr(:os, :atom, default: :unknown)

  def render_result(assigns) do
    ~H"""
    <div class="px-4 sm:px-6 lg:px-8">
      <%= cond do %>
        <% @result != nil -> %>
          <div class="overflow-x-auto">
            <.table id="query-results" rows={@result.rows}>
              <:col :let={row} :for={{col, index} <- Enum.with_index(@result.columns)} label={col}>
                <%= CellFormatter.format(Enum.at(row, index)) %>
              </:col>
            </.table>
          </div>

        <% is_binary(@error) and @error != "" -> %>
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
        <p class="font-medium">Error:</p>
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

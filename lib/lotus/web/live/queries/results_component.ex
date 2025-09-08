defmodule Lotus.Web.Queries.ResultsComponent do
  use Lotus.Web, :html

  alias Lotus.Web.CellFormatter

  attr(:result, :any, default: nil)
  attr(:error, :string, default: nil)
  attr(:running, :boolean, default: false)
  attr(:os, :atom, default: :unknown)
  attr(:target, Phoenix.LiveComponent.CID, default: nil)

  def render_result(assigns) do
    ~H"""
    <div class="px-4 sm:px-6 lg:px-8 h-full flex flex-col">
      <%= cond do %>
        <% @running == true -> %>
          <.loading_spinner />

        <% @result != nil -> %>
          <div class="mt-6 flex-shrink-0">
            <h2 class="text-lg font-semibold text-text-light dark:text-text-dark mb-3">Results</h2>
            <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3">
              <div>
                <span class="inline-flex items-center gap-1.5 px-2.5 py-1 text-sm font-medium bg-green-50 text-green-700 dark:bg-green-900/20 dark:text-green-400 rounded-md">
                  <Icons.check class="w-4 h-4" />
                  Success
                </span>
                <div class="text-sm text-gray-600 dark:text-gray-400 mt-1">
                  <%= info_text(@result) %>
                </div>
              </div>
              <div class="flex items-center gap-2">
                <button
                  phx-click="prev_page"
                  phx-target={@target}
                  class="inline-flex items-center gap-1.5 px-3 py-1.5 text-sm font-medium text-gray-600 dark:text-gray-400 hover:text-gray-900 dark:hover:text-gray-200 hover:bg-gray-50 dark:hover:bg-gray-800 rounded-md transition-colors disabled:opacity-50"
                  disabled={not can_prev(@result)}
                >
                  <Icons.chevron_left class="h-5 w-5" />
                  Prev
                </button>
                <button
                  phx-click="next_page"
                  phx-target={@target}
                  class="inline-flex items-center gap-1.5 px-3 py-1.5 text-sm font-medium text-gray-600 dark:text-gray-400 hover:text-gray-900 dark:hover:text-gray-200 hover:bg-gray-50 dark:hover:bg-gray-800 rounded-md transition-colors disabled:opacity-50"
                  disabled={not can_next(@result)}
                >
                  Next
                  <Icons.chevron_right class="h-5 w-5" />
                </button>
                <button 
                  phx-click="export_csv"
                  phx-target={@target}
                  class="inline-flex items-center gap-1.5 px-3 py-1.5 text-sm font-medium text-gray-600 dark:text-gray-400 hover:text-gray-900 dark:hover:text-gray-200 hover:bg-gray-50 dark:hover:bg-gray-800 rounded-md transition-colors">
                  <Icons.download class="h-5 w-5" />
                  Export (.csv)
                </button>
              </div>
            </div>
          </div>
          <div class="mt-2 flex-1 min-h-0">
            <.table id="query-results" rows={@result.rows} sticky_header={true}>
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
            <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3">
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

  defp info_text(%{num_rows: n, duration_ms: ms, meta: meta}) do
    {range_text, total_text} =
      case meta do
        %{} ->
          win = Map.get(meta, :window)
          total = Map.get(meta, :total_count)

          if is_map(win) do
            offset = Map.get(win, :offset, 0)
            from = if n > 0, do: offset + 1, else: 0
            to_ = offset + n
            range = if n > 0, do: "Showing #{from}–#{to_}", else: "Showing 0"
            total_part = if is_integer(total), do: " of #{total} rows", else: " rows"
            {range, total_part}
          else
            {"#{n} rows", ""}
          end

        _ ->
          {"#{n} rows", ""}
      end

    range_text <> total_text <> " • " <> to_string(ms) <> "ms"
  end

  defp can_prev(%{meta: %{} = meta}) do
    case Map.get(meta, :window) do
      %{} = win -> Map.get(win, :offset, 0) > 0
      _ -> false
    end
  end

  defp can_prev(_), do: false

  defp can_next(%{num_rows: n, meta: %{} = meta}) when is_integer(n) do
    win = Map.get(meta, :window, %{})
    page = Map.get(win, :limit)
    offset = Map.get(win, :offset, 0)
    total = Map.get(meta, :total_count)

    cond do
      is_integer(total) -> offset + n < total
      is_integer(page) -> n == page
      true -> false
    end
  end

  defp can_next(_), do: false

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

  defp loading_spinner(assigns) do
    ~H"""
    <div class="mt-6 flex-shrink-0">
      <h2 class="text-lg font-semibold text-text-light dark:text-text-dark mb-3">Results</h2>
      <div class="grid min-h-[140px] w-full place-items-center overflow-x-scroll rounded-lg p-6 lg:overflow-visible">
        <.spinner />
      </div>
    </div>
    """
  end
end

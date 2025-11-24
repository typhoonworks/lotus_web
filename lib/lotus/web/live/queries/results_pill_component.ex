defmodule Lotus.Web.Queries.ResultsPillComponent do
  @moduledoc """
  Floating pill notification that shows query results summary when results are scrolled out of view.
  """

  use Lotus.Web, :html

  attr(:error, :string, default: nil)
  attr(:result, :map, default: nil)
  attr(:target, Phoenix.LiveComponent.CID, required: true)
  attr(:results_visible, :boolean, default: true)

  def results_pill(assigns) do
    ~H"""
    <%= if (@result || @error) && !@results_visible do %>
      <div
        class="fixed bottom-6 right-6 z-30 cursor-pointer"
        phx-click="scroll_to_results"
        phx-target={@target}
      >
        <div class="inline-flex items-center gap-2 px-4 py-2.5 bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-lg shadow-lg hover:shadow-xl transition-shadow">
          <%= if @error do %>
            <Icons.x_mark class="w-4 h-4 text-red-600 dark:text-red-400" />
            <div class="flex flex-col">
              <span class="text-sm font-medium text-gray-900 dark:text-gray-100">Error</span>
              <span class="text-xs text-gray-600 dark:text-gray-400">See details below</span>
            </div>
          <% else %>
            <Icons.check class="w-4 h-4 text-green-600 dark:text-green-400" />
            <div class="flex flex-col">
              <span class="text-sm font-medium text-gray-900 dark:text-gray-100">Success</span>
              <span class="text-xs text-gray-600 dark:text-gray-400">
                <%= @result.num_rows %> <%= if @result.num_rows == 1, do: "row", else: "rows" %> • <%= @result.duration_ms %>ms
              </span>
            </div>
          <% end %>
          <Icons.chevron_down class="w-4 h-4 text-gray-400" />
        </div>
      </div>
    <% end %>
    """
  end
end

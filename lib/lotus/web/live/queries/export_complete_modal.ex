defmodule Lotus.Web.Queries.ExportCompleteModal do
  @moduledoc false

  use Lotus.Web, :live_component

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <div>
      <.modal id="export-complete-modal" show={true} on_cancel={JS.push("close_export_modal", target: @parent)}>
        <div class="flex items-center gap-2 mb-4">
          <Icons.check class="w-5 h-5 text-green-600 dark:text-green-400" />
          <h3 class="text-lg font-semibold text-gray-900 dark:text-gray-100">
            Download complete
          </h3>
        </div>

        <div class="space-y-4">
          <p class="text-sm text-gray-600 dark:text-gray-400">
            File <span class="font-medium text-gray-900 dark:text-gray-100"><%= @filename %></span> was downloaded.
          </p>
          
          <div class="flex gap-3">
            <button
              phx-click="reveal_in_finder"
              phx-target={@parent}
              phx-value-path={@file_path}
              class="flex-1 px-4 py-2 bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 rounded-md hover:bg-gray-200 dark:hover:bg-gray-600 transition-colors text-sm font-medium"
            >
              Reveal in Finder
            </button>
            <button
              phx-click="open_file"
              phx-target={@parent}
              phx-value-path={@file_path}
              class="flex-1 px-4 py-2 bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 rounded-md hover:bg-gray-200 dark:hover:bg-gray-600 transition-colors text-sm font-medium"
            >
              Open file
            </button>
          </div>
        </div>

        <%= if @error do %>
          <div class="mt-3 p-3 bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-md">
            <p class="text-sm text-red-600 dark:text-red-400">
              <%= @error %>
            </p>
          </div>
        <% end %>
      </.modal>
    </div>
    """
  end

  @impl Phoenix.LiveComponent
  def mount(socket) do
    {:ok,
     assign(socket,
       filename: nil,
       file_path: nil,
       error: nil
     )}
  end

  @impl Phoenix.LiveComponent
  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end
end

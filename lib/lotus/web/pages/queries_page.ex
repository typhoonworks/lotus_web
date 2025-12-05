defmodule Lotus.Web.QueriesPage do
  @moduledoc false

  @behaviour Lotus.Web.Page

  use Lotus.Web, :live_component

  alias Lotus.Web.Page

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
      <div id="queries-page" class="flex flex-col h-full overflow-hidden">
        <div class="mx-auto w-full px-0 sm:px-0 lg:px-6 py-0 sm:py-6 h-full">
          <div class="bg-white dark:bg-gray-800 shadow rounded-lg h-full overflow-y-auto">
            <div class="px-6 py-4 border-b border-gray-200 dark:border-gray-700">
              <h2 class="text-lg font-semibold text-text-light dark:text-text-dark"><%= gettext("Queries") %></h2>
            </div>
            <div class="px-4 sm:px-6 lg:px-8">
              <%= if @queries == [] do %>
                <div class="py-12 text-center text-gray-500 dark:text-gray-400">
                  <p><%= gettext("No saved queries yet.") %></p>
                </div>
              <% else %>
                <div class="mt-8">
                  <.table id="queries-table" rows={@queries}>
                  <:col :let={query} label={gettext("Name")}>
                    <.link navigate={lotus_path(["queries", query.id])} class="text-indigo-600 dark:text-indigo-400 hover:text-indigo-800 dark:hover:text-indigo-300 font-medium">
                      <%= query.name %>
                    </.link>
                  </:col>
                  <:col :let={query} label={gettext("Description")}>
                    <%= query.description || "-" %>
                  </:col>
                  <:col :let={query} label={gettext("Created")}>
                    <%= Calendar.strftime(query.inserted_at, "%b %d, %Y") %>
                  </:col>
                  </.table>
                </div>
              <% end %>
            </div>
          </div>
        </div>
      </div>
    """
  end

  @impl Page
  def handle_mount(socket) do
    queries = Lotus.list_queries()

    socket
    |> assign_new(:queries, fn -> queries end)
  end

  @impl Page
  def handle_params(_params, _uri, socket), do: {:noreply, socket}

  @impl Page
  def handle_info(_msg, socket), do: {:noreply, socket}
end

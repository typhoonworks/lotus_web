defmodule Lotus.Web.Queries.AiAssistantComponent do
  @moduledoc """
  AI Assistant drawer for generating SQL queries from natural language.
  Slides in from the left side.
  """
  use Lotus.Web, :live_component

  alias Phoenix.LiveView.JS
  alias Lotus.Web.Components.Icons

  # Assigns:
  # - visible: boolean
  # - parent: Phoenix.LiveComponent.CID
  # - data_source: string (from query_form)
  # - generating: boolean (loading state)
  # - error: string | nil

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <div
      class={[
        "fixed sm:absolute top-0 left-0 h-full w-full sm:w-96",
        "bg-white dark:bg-gray-800",
        "border-r-0 sm:border-r border-gray-200 dark:border-gray-700",
        "z-20 transition-transform duration-300 ease-in-out overflow-hidden",
        "flex flex-col",
        if(@visible, do: "translate-x-0", else: "-translate-x-full")
      ]}
    >
      <%= if @visible do %>
        <.header parent={@parent} />
        <.form_content {assigns} />
      <% end %>
    </div>
    """
  end

  attr(:parent, :any, required: true)

  defp header(assigns) do
    ~H"""
    <div class="px-4 py-3 border-b border-gray-200 dark:border-gray-700 bg-gray-50 dark:bg-gray-900/50">
      <div class="flex items-center justify-between">
        <div>
          <h3 class="text-sm font-semibold text-gray-900 dark:text-gray-100">
            <%= gettext("AI Assistant") %>
          </h3>
          <p class="text-xs text-gray-500 dark:text-gray-400 mt-0.5">
            <%= gettext("Describe your query in plain English") %>
          </p>
        </div>
        <button
          type="button"
          phx-click="close_ai_assistant"
          phx-target={@parent}
          class="p-1 text-gray-400 dark:text-gray-500 hover:text-gray-600 dark:hover:text-gray-300 transition-colors"
          aria-label={gettext("Close")}
        >
          <Icons.x_mark class="h-5 w-5" />
        </button>
      </div>
    </div>
    """
  end

  defp form_content(assigns) do
    ~H"""
    <div class="flex-1 flex flex-col p-4 overflow-y-auto">
      <form id="ai-prompt-form" phx-submit="generate_ai_query" phx-target={@parent} class="flex flex-col h-full">
        <div class="flex-1 flex flex-col">
          <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
            <%= gettext("What would you like to query?") %>
          </label>
          <textarea
            id="ai-prompt-input"
            name="prompt"
            rows="8"
            class="flex-1 w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm text-sm focus:outline-none focus:ring-2 focus:ring-pink-500 focus:border-transparent bg-white dark:bg-gray-900 text-gray-900 dark:text-gray-100 resize-none"
            placeholder={gettext("Example: Show all active users who signed up in the last 30 days")}
            required
            disabled={@generating}
            phx-hook="AIPromptInput"
            data-prompt={@prompt}
          ></textarea>

          <%= if @error do %>
            <div class="mt-3 p-3 bg-yellow-50 dark:bg-yellow-900/20 border border-yellow-200 dark:border-yellow-800 rounded-md">
              <div class="flex items-start">
                <Icons.exclamation_triangle class="h-5 w-5 text-yellow-600 dark:text-yellow-500 mr-2 flex-shrink-0 mt-0.5" />
                <div class="text-sm text-yellow-800 dark:text-yellow-200">
                  <p class="font-medium"><%= gettext("Unable to generate query") %></p>
                  <p class="mt-1"><%= @error %></p>
                </div>
              </div>
            </div>
          <% end %>
        </div>

        <div class="mt-4 flex items-center justify-end gap-2 pt-4 border-t border-gray-200 dark:border-gray-700">
          <button
            type="button"
            phx-click={JS.dispatch("clear", to: "#ai-prompt-input")}
            disabled={@generating}
            class="inline-flex items-center px-3 py-2 border border-gray-300 dark:border-gray-600 text-sm font-medium rounded-md text-gray-700 dark:text-gray-300 bg-white dark:bg-gray-800 hover:bg-gray-50 dark:hover:bg-gray-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-pink-500 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
          >
            <%= gettext("Clear") %>
          </button>
          <button
            type="submit"
            disabled={@generating}
            class={[
              "inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white transition-colors",
              if(@generating,
                do: "bg-gray-400 cursor-not-allowed",
                else: "bg-pink-600 hover:bg-pink-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-pink-500"
              )
            ]}
          >
            <%= if @generating do %>
              <svg class="animate-spin -ml-1 mr-2 h-4 w-4 text-white" fill="none" viewBox="0 0 24 24">
                <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 714 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
              </svg>
              <%= gettext("Generating...") %>
            <% else %>
              <%= gettext("Generate Query") %>
            <% end %>
          </button>
        </div>
      </form>
    </div>
    """
  end

  @impl Phoenix.LiveComponent
  def mount(socket) do
    {:ok,
     socket
     |> assign(visible: false)
     |> assign(generating: false)
     |> assign(error: nil)
     |> assign(prompt: "")}
  end

  @impl Phoenix.LiveComponent
  def update(params, socket) do
    {:ok, assign(socket, params)}
  end
end

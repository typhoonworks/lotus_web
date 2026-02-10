defmodule Lotus.Web.Queries.AiAssistantComponent do
  @moduledoc """
  Conversational AI Assistant for generating and refining SQL queries.
  Displays conversation history with message bubbles and supports multi-turn interactions.
  """
  use Lotus.Web, :live_component

  alias Lotus.Web.Components.Icons

  # Assigns:
  # - visible: boolean
  # - parent: Phoenix.LiveComponent.CID
  # - data_source: string (from query_form)
  # - generating: boolean (loading state)
  # - conversation: map (conversation history)

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
        <.header parent={@parent} conversation={@conversation} />
        <.conversation_history conversation={@conversation} parent={@parent} />
        <.input_area generating={@generating} parent={@parent} />
      <% end %>
    </div>
    """
  end

  attr(:parent, :any, required: true)
  attr(:conversation, :map, required: true)

  defp header(assigns) do
    ~H"""
    <div class="px-4 py-3 border-b border-gray-200 dark:border-gray-700 bg-gray-50 dark:bg-gray-900/50 flex-shrink-0">
      <div class="flex items-center justify-between">
        <div class="flex-1">
          <h3 class="text-sm font-semibold text-gray-900 dark:text-gray-100">
            <%= gettext("AI Assistant") %>
          </h3>
          <p class="text-xs text-gray-500 dark:text-gray-400 mt-0.5">
            <%= if length(@conversation.messages) == 0 do %>
              <%= gettext("Describe your query in plain English") %>
            <% else %>
              <%= gettext("%{count} messages • %{generations} queries generated",
                count: length(@conversation.messages),
                generations: @conversation.generation_count) %>
            <% end %>
          </p>
        </div>
        <div class="flex items-center gap-1">
          <%= if length(@conversation.messages) > 0 do %>
            <button
              type="button"
              phx-click="clear_ai_conversation"
              phx-target={@parent}
              class="p-1.5 text-gray-400 dark:text-gray-500 hover:text-pink-600 dark:hover:text-pink-400 transition-colors"
              aria-label={gettext("Clear conversation")}
              title={gettext("Clear conversation")}
            >
              <Icons.trash class="h-4 w-4" />
            </button>
          <% end %>
          <button
            type="button"
            phx-click="close_ai_assistant"
            phx-target={@parent}
            class="p-1.5 text-gray-400 dark:text-gray-500 hover:text-gray-600 dark:hover:text-gray-300 transition-colors"
            aria-label={gettext("Close")}
          >
            <Icons.x_mark class="h-5 w-5" />
          </button>
        </div>
      </div>
    </div>
    """
  end

  attr(:conversation, :map, required: true)
  attr(:parent, :any, required: true)

  defp conversation_history(assigns) do
    ~H"""
    <div
      id="ai-conversation-history"
      phx-hook="AutoScrollAI"
      class="flex-1 overflow-y-auto p-4 space-y-3"
    >
      <%= if length(@conversation.messages) == 0 do %>
        <.empty_state />
      <% else %>
        <%= for {message, index} <- Enum.with_index(@conversation.messages) do %>
          <.message_bubble message={message} index={index} parent={@parent} />
        <% end %>
      <% end %>
    </div>
    """
  end

  defp empty_state(assigns) do
    ~H"""
    <div class="flex flex-col items-center justify-center h-full text-center py-12">
      <div class="p-3 bg-pink-50 dark:bg-pink-900/20 rounded-full mb-4">
        <Icons.sparkles class="h-8 w-8 text-pink-600 dark:text-pink-400" />
      </div>
      <h4 class="text-sm font-medium text-gray-900 dark:text-gray-100 mb-1">
        <%= gettext("Start a conversation") %>
      </h4>
      <p class="text-xs text-gray-500 dark:text-gray-400 max-w-xs">
        <%= gettext("Ask me to generate a SQL query, and I can help you refine it through conversation") %>
      </p>
      <div class="mt-6 text-xs text-gray-400 dark:text-gray-500 space-y-2">
        <p class="font-medium"><%= gettext("Example prompts:") %></p>
        <ul class="space-y-1 text-left">
          <li>• <%= gettext("Show all active users") %></li>
          <li>• <%= gettext("Count orders by month") %></li>
          <li>• <%= gettext("Find top 10 products by revenue") %></li>
        </ul>
      </div>
    </div>
    """
  end

  attr(:message, :map, required: true)
  attr(:index, :integer, required: true)
  attr(:parent, :any, required: true)

  defp message_bubble(assigns) do
    ~H"""
    <div class={[
      "flex",
      if(@message.role == :user, do: "justify-end", else: "justify-start")
    ]}>
      <div class={[
        "max-w-[85%] rounded-lg px-3 py-2",
        case @message.role do
          :user -> "bg-pink-100 dark:bg-pink-900/20 text-gray-800 dark:text-pink-100"
          :assistant -> "bg-transparent text-gray-900 dark:text-gray-100"
          :error -> "bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 text-red-900 dark:text-red-100"
        end
      ]}>
        <%= case @message.role do %>
          <% :user -> %>
            <p class="text-sm whitespace-pre-wrap"><%= @message.content %></p>

          <% :assistant -> %>
            <div class="space-y-2">
              <%= if @message.content && @message.content != "" do %>
                <p class="text-xs text-gray-600 dark:text-gray-400"><%= @message.content %></p>
              <% end %>

              <%= if @message.sql do %>
                <div class="mt-2 relative group">
                  <pre class="text-xs bg-slate-100 dark:bg-gray-950 text-gray-900 dark:text-gray-100 p-2 rounded overflow-x-auto"><code><%= @message.sql %></code></pre>
                  <button
                    type="button"
                    phx-click="use_ai_query"
                    phx-value-sql={@message.sql}
                    phx-target={@parent}
                    class="mt-2 w-full inline-flex items-center justify-center px-3 py-1.5 text-xs font-medium rounded bg-pink-600 hover:bg-pink-700 text-white transition-colors"
                  >
                    <Icons.corner_down_right class="h-3.5 w-3.5 mr-1" />
                    <%= gettext("Use this query") %>
                  </button>
                </div>
              <% end %>
            </div>

          <% :error -> %>
            <div class="space-y-2">
              <div class="flex items-start">
                <Icons.exclamation_triangle class="h-4 w-4 text-red-600 dark:text-red-400 mr-2 flex-shrink-0 mt-0.5" />
                <div class="text-sm">
                  <p class="font-medium"><%= gettext("Query Failed") %></p>
                  <p class="mt-1 text-xs opacity-90"><%= @message.content %></p>
                </div>
              </div>

              <%= if @message.sql do %>
                <details class="mt-2">
                  <summary class="text-xs cursor-pointer text-red-800 dark:text-red-300 hover:underline">
                    <%= gettext("Show failed query") %>
                  </summary>
                  <pre class="mt-1 text-xs bg-red-100 dark:bg-red-950/30 p-2 rounded overflow-x-auto"><code><%= @message.sql %></code></pre>
                </details>
              <% end %>

              <button
                type="button"
                phx-click="retry_ai_with_error"
                phx-target={@parent}
                class="mt-2 w-full inline-flex items-center justify-center px-3 py-1.5 text-xs font-medium rounded bg-red-600 hover:bg-red-700 text-white transition-colors"
              >
                <Icons.rotate_ccw class="h-3.5 w-3.5 mr-1" />
                <%= gettext("Ask AI to fix this") %>
              </button>
            </div>
        <% end %>

        <p class="text-[10px] mt-1.5 opacity-60">
          <%= Calendar.strftime(@message.timestamp, "%I:%M %p") %>
        </p>
      </div>
    </div>
    """
  end

  attr(:generating, :boolean, required: true)
  attr(:parent, :any, required: true)

  defp input_area(assigns) do
    ~H"""
    <div class="flex-shrink-0 border-t border-gray-200 dark:border-gray-700 bg-gray-50 dark:bg-gray-900/50 p-4">
      <form id="ai-message-form" phx-submit="send_ai_message" phx-target={@parent}>
        <div class="flex gap-2">
          <textarea
            id="ai-message-input"
            name="message"
            rows="1"
            class="flex-1 px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-pink-500 focus:border-transparent bg-white dark:bg-gray-900 text-gray-900 dark:text-gray-100 resize-none"
            placeholder={gettext("Type your message...")}
            required
            disabled={@generating}
            phx-hook="AIMessageInput"
          ></textarea>
          <button
            type="submit"
            disabled={@generating}
            class={[
              "flex-shrink-0 p-2.5 rounded-lg transition-colors",
              if(@generating,
                do: "bg-gray-400 cursor-not-allowed",
                else: "bg-pink-600 hover:bg-pink-700"
              )
            ]}
            aria-label={gettext("Send message")}
          >
            <%= if @generating do %>
              <svg class="animate-spin h-5 w-5 text-white" fill="none" viewBox="0 0 24 24">
                <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
              </svg>
            <% else %>
              <Icons.send class="h-5 w-5 text-white" />
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
     |> assign(conversation: new_conversation())}
  end

  @impl Phoenix.LiveComponent
  def update(params, socket) do
    {:ok, assign(socket, params)}
  end

  defp new_conversation do
    %{
      messages: [],
      schema_context: %{tables_analyzed: []},
      generation_count: 0,
      started_at: DateTime.utc_now(),
      last_activity: DateTime.utc_now()
    }
  end
end

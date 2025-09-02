defmodule Lotus.Web.MultiSelectComponent do
  use Lotus.Web, :live_component

  @moduledoc """
  A Tailwind-styled, accessible multi-select dropdown with search functionality.

  Props:
    * id        - required, base id for button & listbox
    * name      - required, posted param name
    * options   - required, list of {label, value}
    * value     - current value (comma-separated string or list)
    * label     - optional label text
    * prompt    - optional prompt text when no values are selected
    * disabled  - boolean
    * errors    - list of error strings (shown under the field)
    * floating_label - boolean, render as fieldset or regular
    * show_icons - boolean, show icons in options

  Emits:
    * updates hidden `<input name>` elements so `phx-change` on the surrounding form
      receives the change as usual.
  """

  attr(:id, :string, required: true)
  attr(:name, :string, required: true)
  attr(:options, :list, required: true)
  attr(:value, :any, default: nil)
  attr(:label, :string, default: nil)
  attr(:floating_label, :boolean, default: false)
  attr(:prompt, :string, default: nil)
  attr(:search_prompt, :string, default: "Search")
  attr(:disabled, :boolean, default: false)
  attr(:errors, :list, default: [])
  attr(:show_icons, :boolean, default: false)
  attr(:class, :string, default: nil)

  def render(assigns) do
    ~H"""
    <div id={@id <> "-wrapper"}>
      <%= if @floating_label do %>
        <.render_fieldset_trigger {assigns} />
      <% else %>
        <.render_regular_trigger {assigns} />
      <% end %>

      <.error :for={msg <- @errors}><%= msg %></.error>
    </div>
    """
  end

  defp render_fieldset_trigger(assigns) do
    ~H"""
    <fieldset class={[
      "border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-input-dark focus-within:border-2 focus-within:border-pink-600",
      @errors != [] && "border-rose-400 focus-within:border-rose-500"
    ]}>
      <legend :if={@label} class="ml-1 px-1 text-xs font-medium text-gray-700 dark:text-gray-300">
        <%= @label %>
      </legend>

      <div class="relative" id={@id <> "-root"} phx-click-away="close" phx-target={@myself}>
        <input
          id={@id <> "-hidden"}
          type="hidden"
          name={@name}
          value={Enum.join(@value_list || [], ",")}
          phx-hook="DispatchChangeOnUpdate"
        />

        <button
          type="button"
          id={@id}
          phx-click={JS.push("toggle", target: @myself) |> JS.focus(to: "##{@id}-listbox")}
          phx-target={@myself}
          aria-haspopup="listbox"
          aria-controls={@id <> "-listbox"}
          aria-expanded={@open}
          disabled={@disabled}
          class={[
            "border-0 bg-transparent px-3 py-1.5 text-left text-gray-900 dark:text-gray-100 placeholder:text-gray-400 dark:placeholder:text-gray-500 focus:ring-0 sm:text-sm flex items-center justify-between",
            @class || "w-full"
          ]}
        >
          <span class="truncate">
            <%= display_selected_count(@value_list, @prompt) %>
          </span>
          <svg viewBox="0 0 16 16" fill="currentColor" aria-hidden="true"
              class="size-5 text-gray-500 dark:text-gray-400 sm:size-4">
            <path fill-rule="evenodd" clip-rule="evenodd"
              d="M5.22 10.22a.75.75 0 0 1 1.06 0L8 11.94l1.72-1.72a.75.75 0 1 1 1.06 1.06l-2.25 2.25a.75.75 0 0 1-1.06 0l-2.25-2.25a.75.75 0 0 1 0-1.06ZM10.78 5.78a.75.75 0 0 1-1.06 0L8 4.06 6.28 5.78a.75.75 0 0 1-1.06-1.06l2.25-2.25a.75.75 0 0 1 1.06 0l2.25 2.25a.75.75 0 0 1 0 1.06Z" />
          </svg>
        </button>

        <.render_dropdown {assigns} />
      </div>
    </fieldset>
    """
  end

  defp render_regular_trigger(assigns) do
    ~H"""
    <.label :if={@label} for={@id}><%= @label %></.label>

    <div class="relative mt-2 w-full" id={@id <> "-root"} phx-click-away="close" phx-target={@myself}>
      <input
        id={@id <> "-hidden"}
        type="hidden"
        name={@name}
        value={Enum.join(@value_list || [], ",")}
        phx-hook="DispatchChangeOnUpdate"
      />

      <button
        type="button"
        id={@id}
        phx-click={JS.push("toggle", target: @myself) |> JS.focus(to: "##{@id}-listbox")}
        phx-target={@myself}
        aria-haspopup="listbox"
        aria-controls={@id <> "-listbox"}
        aria-expanded={@open}
        disabled={@disabled}
        class={[
          "grid cursor-default grid-cols-1 rounded-md bg-white dark:bg-input-dark py-1.5 pl-3 pr-2 text-left text-gray-900 dark:text-gray-100",
          "outline outline-1 -outline-offset-1",
          @errors == [] && "outline-gray-300 dark:outline-gray-600 focus-visible:outline focus-visible:outline-2 focus-visible:-outline-offset-2 focus-visible:outline-pink-600",
          @errors != [] && "outline-rose-400 focus-visible:outline focus-visible:outline-2 focus-visible:-outline-offset-2 focus-visible:outline-rose-500",
          "sm:text-sm/6",
          @class || "w-full"
        ]}
      >
        <span class="col-start-1 row-start-1 truncate pr-6">
          <%= display_selected_count(@value_list, @prompt) %>
        </span>
        <svg viewBox="0 0 16 16" fill="currentColor" aria-hidden="true"
            class="col-start-1 row-start-1 size-5 self-center justify-self-end text-gray-500 dark:text-gray-400 sm:size-4">
          <path fill-rule="evenodd" clip-rule="evenodd"
            d="M5.22 10.22a.75.75 0 0 1 1.06 0L8 11.94l1.72-1.72a.75.75 0 1 1 1.06 1.06l-2.25 2.25a.75.75 0 0 1-1.06 0l-2.25-2.25a.75.75 0 0 1 0-1.06ZM10.78 5.78a.75.75 0 0 1-1.06 0L8 4.06 6.28 5.78a.75.75 0 0 1-1.06-1.06l2.25-2.25a.75.75 0 0 1 1.06 0l2.25 2.25a.75.75 0 0 1 0 1.06Z" />
        </svg>
      </button>

      <.render_dropdown {assigns} />
    </div>
    """
  end

  defp render_dropdown(assigns) do
    ~H"""
    <div
      id={@id <> "-listbox"}
      role="listbox"
      aria-labelledby={@id}
      tabindex="0"
      phx-hook="MultiSelectSearch"
      class={[
        "absolute w-full z-50 mt-1 max-h-60 overflow-auto rounded-md bg-white dark:bg-input-dark py-1 text-base shadow-lg outline outline-1 outline-black/5 dark:outline-gray-600 sm:text-sm",
        (!@open) && "hidden"
      ]}
      phx-keydown="listbox_keydown"
      phx-target={@myself}
    >
      <div class="px-3 py-2 text-sm text-zinc-800 dark:text-zinc-100 bg-white dark:bg-zinc-800 flex items-center gap-2 border-b border-gray-200 dark:border-gray-600">
        <Icons.search class="size-4 text-zinc-400 flex-shrink-0" />
        <input
          type="text"
          class="w-full text-sm bg-transparent border-0 outline-0 ring-0 focus:ring-0 focus:outline-0 focus:border-0 appearance-none rounded-none shadow-none p-0"
          placeholder={@search_prompt}
        />
      </div>


      <div class="no-results px-4 py-2 text-zinc-500" style="display: none;">No results</div>

      <div>
        <%= for {label, value} <- @options do %>
          <div
            role="option"
            aria-selected={value in (@value_list || [])}
            data-value={value}
            class="group/option relative cursor-default select-none py-2 pl-3 pr-9 text-gray-900 dark:text-gray-100 hover:bg-pink-600 hover:text-white"
            phx-click="toggle_option"
            phx-value-option={value}
            phx-target={@myself}
          >
            <div class="flex items-center">
              <.checkbox checked={value in (@value_list || [])} />
              <%= if @show_icons do %>
                <Icons.database class="mr-3 h-5 w-5 flex-shrink-0" />
              <% end %>
              <span class="block truncate"><%= label %></span>
            </div>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  defp checkbox(assigns) do
    ~H"""
    <div class="group grid size-4 grid-cols-1 mr-3">
      <span class={[
        "col-start-1 row-start-1 rounded border transition-colors",
        if(@checked,
          do: "border-pink-600 bg-pink-600",
          else: "border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-800"
        )
      ]}>
      </span>
      <svg viewBox="0 0 14 14" fill="none" class={[
        "pointer-events-none col-start-1 row-start-1 size-3.5 self-center justify-self-center stroke-white",
        if(@checked, do: "opacity-100", else: "opacity-0")
      ]}>
        <path d="M3 8L6 11L11 3.5" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" />
      </svg>
    </div>
    """
  end

  def update(assigns, socket) do
    value_list =
      case assigns[:value] do
        nil -> []
        "" -> []
        value when is_binary(value) -> String.split(value, ",", trim: true)
        value when is_list(value) -> value
      end

    socket =
      socket
      |> assign_new(:open, fn -> false end)
      |> assign(assigns)
      |> assign(value_list: value_list)

    {:ok, socket}
  end

  def handle_event("toggle", _params, socket) do
    new_open = !socket.assigns.open
    {:noreply, assign(socket, open: new_open)}
  end

  def handle_event("close", _params, socket) do
    {:noreply, assign(socket, open: false)}
  end

  def handle_event("toggle_option", %{"option" => option}, socket) do
    current_value_list = socket.assigns.value_list || []

    new_value_list =
      if option in current_value_list do
        List.delete(current_value_list, option)
      else
        [option | current_value_list] |> Enum.uniq()
      end

    {:noreply, assign(socket, value_list: new_value_list)}
  end

  def handle_event("listbox_keydown", %{"key" => "Escape"}, socket) do
    {:noreply, assign(socket, open: false)}
  end

  def handle_event("listbox_keydown", _params, socket) do
    {:noreply, socket}
  end

  defp display_selected_count(value_list, prompt) do
    case value_list do
      [] -> prompt || "Select options…"
      [single] -> single
      list -> "#{length(list)} selected"
    end
  end
end

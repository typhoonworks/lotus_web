defmodule Lotus.Web.SelectComponent do
  use Lotus.Web, :live_component

  @moduledoc """
  A Tailwind-styled, accessible single-select dropdown.

  Props:
    * id        - required, base id for button & listbox
    * name      - required, posted param name
    * options   - required, list of {label, value}
    * value     - current value (string/integer)
    * label     - optional label text
    * prompt    - optional prompt text when no value is selected
    * disabled  - boolean
    * errors    - list of error strings (shown under the field)

  Emits:
    * updates the hidden `<input name>` so `phx-change` on the surrounding form
      receives the change as usual.
  """

  attr(:id, :string, required: true)
  attr(:name, :string, required: true)
  attr(:options, :list, required: true)
  attr(:value, :any, default: nil)
  attr(:label, :string, default: nil)
  attr(:floating_label, :boolean, default: false)
  attr(:prompt, :string, default: nil)
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
        <input id={@id <> "-hidden"} type="hidden" name={@name} value={@value} />

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
            <%= selected_label(@options, @value) || @prompt || "Select…" %>
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
      <input id={@id <> "-hidden"} type="hidden" name={@name} value={@value} />

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
          <%= selected_label(@options, @value) || @prompt || "Select…" %>
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
    <ul
      id={@id <> "-listbox"}
      role="listbox"
      aria-labelledby={@id}
      tabindex="0"
      class={[
        "absolute w-full z-50 mt-1 max-h-60 overflow-auto rounded-md bg-white dark:bg-input-dark py-1 text-base shadow-lg outline outline-1 outline-black/5 dark:outline-gray-600 sm:text-sm",
        (!@open) && "hidden"
      ]}
      phx-keydown="listbox_keydown"
      phx-target={@myself}
    >
      <%= for {label, value} <- @options do %>
        <li
          id={@id <> "-opt-" <> to_string(value)}
          role="option"
          aria-selected={@value == value}
          data-value={value}
          class={[
            "group/option relative cursor-default select-none py-2 pl-3 pr-9 text-gray-900 dark:text-gray-100",
            if(@active_value == value, do: "bg-pink-600 text-white", else: "hover:bg-pink-600 hover:text-white")
          ]}
          phx-click={
            JS.set_attribute({"value", value}, to: "##{@id}-hidden")
            |> JS.push("choose",
              value: %{value: value},
              target: @myself
            )
            |> JS.dispatch("input", to: "##{@id}-hidden")
            |> JS.dispatch("change", to: "##{@id}-hidden")
          }
        >
          <div class="flex items-center">
            <%= if @show_icons do %>
              <Icons.database class="mr-3 h-5 w-5 flex-shrink-0" />
            <% end %>
            <span class={["block truncate", @value == value && "font-semibold"]}><%= label %></span>
          </div>
          <span class={[
            "absolute inset-y-0 right-0 items-center pr-4",
            @value == value && "flex", @value != value && "hidden",
            if(@active_value == value, do: "text-white", else: "text-pink-600 group-hover/option:text-white")
          ]}>
            <svg viewBox="0 0 20 20" fill="currentColor" aria-hidden="true" class="size-5">
              <path fill-rule="evenodd" clip-rule="evenodd"
                d="M16.704 4.153a.75.75 0 0 1 .143 1.052l-8 10.5a.75.75 0 0 1-1.127.075l-4.5-4.5a.75.75 0 1 1 1.06-1.06l3.894 3.893 7.48-9.817a.75.75 0 0 1 1.05-.143Z" />
            </svg>
          </span>
        </li>
      <% end %>
    </ul>
    """
  end

  def update(assigns, socket) do
    socket =
      socket
      |> assign_new(:open, fn -> false end)
      |> assign_new(:active_value, fn -> nil end)
      |> assign(assigns)

    {:ok, socket}
  end

  def handle_event("toggle", _params, socket) do
    new_open = !socket.assigns.open

    active_value =
      if new_open do
        socket.assigns.value || socket.assigns.options |> List.first() |> elem(1)
      else
        nil
      end

    {:noreply, assign(socket, open: new_open, active_value: active_value)}
  end

  def handle_event("close", _params, socket) do
    {:noreply, assign(socket, :open, false)}
  end

  def handle_event("choose", %{"value" => value}, socket) do
    value = to_string(value)

    {:noreply,
     socket
     |> assign(value: value, active_value: value)
     |> assign(:open, false)}
  end

  def handle_event("listbox_keydown", %{"key" => key}, socket) do
    {active, open} = navigate(socket.assigns, key)
    {:noreply, assign(socket, active_value: active, open: open)}
  end

  defp selected_label(options, value) do
    Enum.find_value(options, fn {l, v} -> if to_string(v) == to_string(value), do: l end)
  end

  defp navigate(%{options: options, value: value, active_value: active, open: open}, key) do
    values = Enum.map(options, fn {_l, v} -> v end)
    cur = get_current_value(active, value, values)
    idx = get_current_index(values, cur)

    case key do
      "ArrowDown" -> navigate_down(values, idx)
      "ArrowUp" -> navigate_up(values, idx)
      "Home" -> navigate_home(values)
      "End" -> navigate_end(values)
      "Enter" -> close_with_current(cur)
      "Escape" -> close_with_current(cur)
      _ -> keep_current(cur, open)
    end
  end

  defp navigate_down(values, idx) do
    {Enum.at(values, min(idx + 1, length(values) - 1)), true}
  end

  defp navigate_up(values, idx) do
    {Enum.at(values, max(idx - 1, 0)), true}
  end

  defp navigate_home(values) do
    {List.first(values), true}
  end

  defp navigate_end(values) do
    {List.last(values), true}
  end

  defp close_with_current(cur) do
    {cur, false}
  end

  defp keep_current(cur, open) do
    {cur, open}
  end

  defp get_current_value(active, value, values) do
    active || value || List.first(values)
  end

  defp get_current_index(values, cur) do
    Enum.find_index(values, &(to_string(&1) == to_string(cur))) || 0
  end
end

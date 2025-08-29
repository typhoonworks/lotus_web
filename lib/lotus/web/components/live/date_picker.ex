defmodule Lotus.Web.DatePickerComponent do
  @moduledoc """
  A date picker component for selecting dates with a calendar interface.

  Props:
    * id           - required, base id for the component
    * name         - required, posted param name
    * value        - current value (string/Date/DateTime)
    * label        - optional label text
    * placeholder  - optional placeholder text
    * disabled     - boolean
    * errors       - list of error strings (shown under the field)
    * min          - minimum selectable date
    * max          - maximum selectable date
    * timezone     - timezone for date display
    * floating_label - whether to use floating label style

  Emits:
    * updates the hidden `<input name>` so `phx-change` on the surrounding form
      receives the change as usual.
  """

  use Lotus.Web, :live_component
  alias Lotus.Web.Components.Icons

  @week_start_at :sunday

  attr(:id, :string, required: true)
  attr(:name, :string, required: true)
  attr(:value, :any, default: nil)
  attr(:label, :string, default: nil)
  attr(:placeholder, :string, default: "Select date")
  attr(:disabled, :boolean, default: false)
  attr(:errors, :list, default: [])
  attr(:min, :any, default: ~D[1900-01-01])
  attr(:max, :any, default: ~D[2100-12-31])
  attr(:timezone, :string, default: "UTC")
  attr(:floating_label, :boolean, default: false)
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
      "border border-gray-300 rounded-md bg-white focus-within:border-2 focus-within:border-pink-600",
      @errors != [] && "border-rose-400 focus-within:border-rose-500"
    ]}>
      <legend :if={@label} class="ml-1 px-1 text-xs font-medium text-gray-700">
        <%= @label %>
      </legend>

      <div class="relative" id={@id <> "-root"} phx-click-away="close-calendar" phx-target={@myself}>
        <input
          id={@id <> "-hidden"}
          type="hidden"
          name={@name}
          value={format_value_for_form(@value)}
          phx-hook="DispatchChangeOnUpdate"
        />

        <button
          type="button"
          id={@id}
          phx-click="open-calendar"
          phx-target={@myself}
          aria-haspopup="true"
          aria-expanded={@calendar_open}
          disabled={@disabled}
          class={[
            "border-0 bg-transparent px-3 py-1.5 text-left text-gray-900 placeholder:text-gray-400 focus:ring-0 sm:text-sm flex items-center justify-between",
            @class || "w-full"
          ]}
        >
          <span class="truncate">
            <%= format_selected_date(@value, @timezone) || @placeholder %>
          </span>
          <Icons.calendar class="size-5 text-gray-500" />
        </button>

        <.render_calendar {assigns} />
      </div>
    </fieldset>
    """
  end

  defp render_regular_trigger(assigns) do
    ~H"""
    <.label :if={@label} for={@id}><%= @label %></.label>

    <div class="relative mt-2 w-full" id={@id <> "-root"} phx-click-away="close-calendar" phx-target={@myself}>
      <input
        id={@id <> "-hidden"}
        type="hidden"
        name={@name}
        value={format_value_for_form(@value)}
        phx-hook="DispatchChangeOnUpdate"
      />

      <button
        type="button"
        id={@id}
        phx-click="open-calendar"
        phx-target={@myself}
        aria-haspopup="true"
        aria-expanded={@calendar_open}
        disabled={@disabled}
        class={[
          "grid cursor-default grid-cols-1 rounded-md bg-white py-1.5 pl-3 pr-2 text-left text-gray-900",
          "outline outline-1 -outline-offset-1",
          @errors == [] && "outline-gray-300 focus-visible:outline focus-visible:outline-2 focus-visible:-outline-offset-2 focus-visible:outline-pink-600",
          @errors != [] && "outline-rose-400 focus-visible:outline focus-visible:outline-2 focus-visible:-outline-offset-2 focus-visible:outline-rose-500",
          "sm:text-sm/6",
          @class || "w-full"
        ]}
      >
        <span class="col-start-1 row-start-1 truncate pr-6">
          <%= format_selected_date(@value, @timezone) || @placeholder %>
        </span>
        <Icons.calendar class="col-start-1 row-start-1 size-5 self-center justify-self-end text-gray-500" />
      </button>

      <.render_calendar {assigns} />
    </div>
    """
  end

  defp render_calendar(assigns) do
    ~H"""
    <div
      :if={@calendar_open}
      id={@id <> "-calendar"}
      class="absolute z-50 w-72 shadow-md transition-all top-full mt-2"
      phx-click-away="close-calendar"
      phx-target={@myself}
    >
      <div class="w-full bg-white rounded-md ring-1 ring-gray-300 shadow-lg focus:outline-none p-1">
        <div class="w-full p-1.5 my-2">
          <label :if={@label} for={@id <> "-display"} class="block text-xs text-gray-500 mb-2">
            <%= @label %>
          </label>
          <div>
            <input
              id={@id <> "-display"}
              type="text"
              readonly
              placeholder={@placeholder}
              value={format_selected_date_with_year(@value, @timezone)}
              class="w-full px-2 py-1 bg-transparent text-gray-900 text-[13px] placeholder:text-gray-500 focus:outline-none border border-gray-300 focus:border-transparent focus:ring-2 focus:ring-pink-600 rounded-md"
            />
          </div>
        </div>

        <div role="separator" class="relative -mx-1 h-px bg-gray-200"></div>

        <div class="flex justify-between p-1.5">
          <div class="self-center text-gray-900 text-xs tracking-wide">
            <%= @current.month %>
          </div>
          <div class="flex">
            <button
              type="button"
              phx-target={@myself}
              phx-click="prev-month"
              class="mr-1.5 p-1 text-gray-400 hover:text-gray-600 hover:bg-gray-100 rounded-md"
            >
              <svg viewBox="0 0 20 20" fill="currentColor" class="size-4">
                <path fill-rule="evenodd" d="M12.79 5.23a.75.75 0 01-.02 1.06L8.832 10l3.938 3.71a.75.75 0 11-1.04 1.08l-4.5-4.25a.75.75 0 010-1.08l4.5-4.25a.75.75 0 011.06.02z" clip-rule="evenodd" />
              </svg>
            </button>
            <button
              type="button"
              phx-target={@myself}
              phx-click="next-month"
              class="ml-1.5 p-1 text-gray-400 hover:text-gray-600 hover:bg-gray-100 rounded-md"
            >
              <svg viewBox="0 0 20 20" fill="currentColor" class="size-4">
                <path fill-rule="evenodd" d="M7.21 14.77a.75.75 0 01.02-1.06L11.168 10 7.23 6.29a.75.75 0 111.04-1.08l4.5 4.25a.75.75 0 010 1.08l-4.5 4.25a.75.75 0 01-1.06-.02z" clip-rule="evenodd" />
              </svg>
            </button>
          </div>
        </div>

        <div class="text-sm text-center">
          <button
            type="button"
            phx-click="today"
            phx-target={@myself}
            class="text-xs text-gray-400 hover:text-gray-600"
          >
            Today
          </button>
        </div>

        <div class="text-center my-2 grid grid-cols-7 text-xs leading-6 text-gray-500">
          <div :for={week_day <- List.first(@current.week_rows)}>
            <%= Calendar.strftime(week_day, "%a") %>
          </div>
        </div>

        <div role="separator" class="relative -mx-1 h-px bg-gray-200"></div>

        <div class="isolate mt-2 grid grid-cols-7 gap-px text-sm">
          <button
            :for={day <- Enum.flat_map(@current.week_rows, & &1)}
            type="button"
            phx-target={@myself}
            phx-click="pick-date"
            phx-value-date={Date.to_string(day)}
            class={[
              "calendar-day overflow-hidden py-1 h-10 w-auto focus:z-10 text-sm",
              today?(day, @timezone) && "font-semibold bg-gray-100 ring-1 ring-gray-300",
              (before_min_date?(day, @min) or after_max_date?(day, @max)) &&
                "text-gray-300 cursor-not-allowed",
              (!before_min_date?(day, @min) and not after_max_date?(day, @max)) &&
                "hover:bg-pink-600 rounded-full text-gray-900 hover:text-white",
              other_month?(day, @current.date) && "text-gray-400",
              selected_date?(day, @value) &&
                "bg-pink-600 text-white hover:bg-pink-700"
            ]}
            disabled={before_min_date?(day, @min) or after_max_date?(day, @max)}
          >
            <time
              class="mx-auto flex h-4 w-4 items-center justify-center rounded-full"
              datetime={Date.to_string(day)}
            >
              <%= Calendar.strftime(day, "%d") %>
            </time>
          </button>
        </div>
      </div>
    </div>
    """
  end

  def update(assigns, socket) do
    current_date = Date.utc_today()
    value = parse_date_value(assigns[:value])

    socket =
      socket
      |> assign_new(:calendar_open, fn -> false end)
      |> assign(assigns)
      |> assign(:current, format_date(current_date))
      |> assign(:value, value)

    {:ok, socket}
  end

  def handle_event("open-calendar", _params, socket) do
    {:noreply, assign(socket, :calendar_open, true)}
  end

  def handle_event("close-calendar", _params, socket) do
    {:noreply, assign(socket, :calendar_open, false)}
  end

  def handle_event("today", _params, socket) do
    new_date = Date.utc_today()
    {:noreply, assign(socket, :current, format_date(new_date))}
  end

  def handle_event("prev-month", _params, socket) do
    new_date = prev_month_date(socket.assigns.current.date)
    {:noreply, assign(socket, :current, format_date(new_date))}
  end

  def handle_event("next-month", _params, socket) do
    new_date = next_month_date(socket.assigns.current.date)
    {:noreply, assign(socket, :current, format_date(new_date))}
  end

  def handle_event("pick-date", %{"date" => date_str}, socket) do
    case Date.from_iso8601(date_str) do
      {:ok, date} ->
        cond do
          before_min_date?(date, socket.assigns.min) ->
            {:noreply, socket}

          after_max_date?(date, socket.assigns.max) ->
            {:noreply, socket}

          true ->
            {:noreply,
             socket
             |> assign(:value, date)
             |> assign(:calendar_open, false)}
        end

      {:error, _} ->
        {:noreply, socket}
    end
  end

  # Helper functions

  defp format_date(date) do
    %{
      date: date,
      month: Calendar.strftime(date, "%B %Y"),
      week_rows: week_rows(date)
    }
  end

  defp week_rows(current_date) do
    first =
      current_date
      |> Date.beginning_of_month()
      |> Date.beginning_of_week(@week_start_at)

    last =
      current_date
      |> Date.end_of_month()
      |> Date.end_of_week(@week_start_at)

    Date.range(first, last)
    |> Enum.map(& &1)
    |> Enum.chunk_every(7)
  end

  defp prev_month_date(current_date) do
    current_date
    |> Date.beginning_of_month()
    |> Date.add(-1)
  end

  defp next_month_date(current_date) do
    current_date
    |> Date.end_of_month()
    |> Date.add(1)
  end

  defp before_min_date?(day, min), do: Date.compare(day, parse_date_value(min)) == :lt
  defp after_max_date?(day, max), do: Date.compare(day, parse_date_value(max)) == :gt
  defp today?(day, _timezone), do: day == Date.utc_today()

  defp other_month?(day, current_date),
    do: Date.beginning_of_month(day) != Date.beginning_of_month(current_date)

  defp selected_date?(_day, nil), do: false
  defp selected_date?(day, %Date{} = selected_date), do: day == selected_date

  defp selected_date?(day, %DateTime{} = selected_date),
    do: day == DateTime.to_date(selected_date)

  defp selected_date?(day, selected_date) when is_binary(selected_date) do
    case parse_date_value(selected_date) do
      nil -> false
      date -> selected_date?(day, date)
    end
  end

  defp selected_date?(_day, _selected_date), do: false

  defp format_selected_date(nil, _timezone), do: nil

  defp format_selected_date(%Date{} = date, _timezone) do
    Calendar.strftime(date, "%b %d")
  end

  defp format_selected_date(%DateTime{} = datetime, _timezone) do
    Calendar.strftime(datetime, "%b %d")
  end

  defp format_selected_date(date_str, timezone) when is_binary(date_str) do
    case parse_date_value(date_str) do
      nil -> nil
      date -> format_selected_date(date, timezone)
    end
  end

  defp format_selected_date(_date, _timezone), do: nil

  defp format_selected_date_with_year(nil, _timezone), do: nil

  defp format_selected_date_with_year(%Date{} = date, _timezone) do
    Calendar.strftime(date, "%b %d, %Y")
  end

  defp format_selected_date_with_year(%DateTime{} = datetime, _timezone) do
    Calendar.strftime(datetime, "%b %d, %Y")
  end

  defp format_selected_date_with_year(date_str, timezone) when is_binary(date_str) do
    case parse_date_value(date_str) do
      nil -> nil
      date -> format_selected_date_with_year(date, timezone)
    end
  end

  defp format_selected_date_with_year(_date, _timezone), do: nil

  defp parse_date_value(nil), do: nil
  defp parse_date_value(""), do: nil
  defp parse_date_value(%Date{} = date), do: date
  defp parse_date_value(%DateTime{} = datetime), do: DateTime.to_date(datetime)

  defp parse_date_value(date_str) when is_binary(date_str) do
    case Date.from_iso8601(date_str) do
      {:ok, date} ->
        date

      {:error, _} ->
        case DateTime.from_iso8601(date_str) do
          {:ok, datetime, _} -> DateTime.to_date(datetime)
          {:error, _} -> nil
        end
    end
  end

  defp parse_date_value(_), do: nil

  defp format_value_for_form(nil), do: ""
  defp format_value_for_form(%Date{} = date), do: Date.to_string(date)

  defp format_value_for_form(%DateTime{} = datetime),
    do: Date.to_string(DateTime.to_date(datetime))

  defp format_value_for_form(value) when is_binary(value), do: value
  defp format_value_for_form(_), do: ""
end

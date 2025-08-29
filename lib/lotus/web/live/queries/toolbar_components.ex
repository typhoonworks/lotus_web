defmodule Lotus.Web.Queries.ToolbarComponents do
  @moduledoc """
  Editor toolbar UI components.
  """

  use Phoenix.Component

  @doc """
  Renders a fieldset-based input with legend acting as floating label.

  This approach uses semantic HTML with fieldset/legend to create a natural
  border cutout effect that works with any background color.

  ## Examples

      <.input field={@form[:name]} label="Name" />
      <.input field={@form[:email]} type="email" label="Email" />
  """
  attr(:id, :any, default: nil)
  attr(:name, :any)
  attr(:label, :string, default: nil)
  attr(:value, :any)

  attr(:type, :string,
    default: "text",
    values: ~w(checkbox color date datetime-local email file month number password
               range search select tel text textarea time url week)
  )

  attr(:field, Phoenix.HTML.FormField,
    doc: "a form field struct retrieved from the form, for example: @form[:email]"
  )

  attr(:errors, :list, default: [])
  attr(:checked, :boolean, doc: "the checked flag for checkbox inputs")
  attr(:prompt, :string, default: nil, doc: "the prompt for select inputs")
  attr(:options, :list, doc: "the options to pass to Phoenix.HTML.Form.options_for_select/2")
  attr(:multiple, :boolean, default: false, doc: "the multiple flag for select inputs")
  attr(:show_icons, :boolean, default: false, doc: "whether to show icons in select options")

  attr(:rest, :global,
    include: ~w(accept autocomplete capture cols disabled form list max maxlength min minlength
                multiple pattern placeholder readonly required rows size step)
  )

  def input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []

    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, errors)
    |> assign_new(:name, fn -> if assigns.multiple, do: field.name <> "[]", else: field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> input()
  end

  def input(%{type: "checkbox"} = assigns) do
    assigns =
      assigns
      |> assign_new(:checked, fn ->
        Phoenix.HTML.Form.normalize_value("checkbox", assigns[:value])
      end)
      |> assign(:formatted_label, format_label(assigns[:label]))

    ~H"""
    <fieldset class={[
      "border border-gray-300 rounded-md bg-white px-3 py-2 focus-within:border-2 focus-within:border-pink-600",
      @errors != [] && "border-rose-400 focus-within:border-rose-500"
    ]}>
      <legend :if={@label} class="ml-1 px-1 text-xs font-medium text-gray-700">
        {@formatted_label}
      </legend>
      <div class="flex items-center gap-4">
        <input type="hidden" name={@name} value="false" disabled={@rest[:disabled]} />
        <input
          type="checkbox"
          id={@id}
          name={@name}
          value="true"
          checked={@checked}
          class="rounded border-gray-300 text-pink-600 focus:ring-0 focus:ring-offset-0"
          {@rest}
        />
        <span class="text-sm text-gray-700">{@formatted_label}</span>
      </div>
      <.error :for={msg <- @errors}>{msg}</.error>
    </fieldset>
    """
  end

  def input(%{type: "select"} = assigns) do
    assigns = assign(assigns, :formatted_label, format_label(assigns[:label]))

    ~H"""
    <.live_component
      module={Lotus.Web.SelectComponent}
      id={@id || "#{@name}-select-editor"}
      name={@name}
      label={@formatted_label}
      floating_label={true}
      value={@value}
      options={@options || []}
      prompt={@prompt}
      disabled={@rest[:disabled]}
      errors={@errors}
      show_icons={@show_icons}
      {@rest}
    />
    """
  end

  def input(%{type: "date"} = assigns) do
    assigns = assign(assigns, :formatted_label, format_label(assigns[:label]))

    ~H"""
    <.live_component
      module={Lotus.Web.DatePickerComponent}
      id={@id || "#{@name}-date-picker-editor"}
      name={@name}
      label={@formatted_label}
      floating_label={true}
      value={@value}
      placeholder={@rest[:placeholder] || "Select date"}
      disabled={@rest[:disabled]}
      errors={@errors}
      min={@rest[:min] || ~D[1900-01-01]}
      max={@rest[:max] || ~D[2100-12-31]}
      timezone={@rest[:timezone] || "UTC"}
      {@rest}
    />
    """
  end

  def input(%{type: "textarea"} = assigns) do
    assigns = assign(assigns, :formatted_label, format_label(assigns[:label]))

    ~H"""
    <fieldset class={[
      "border border-gray-300 rounded-md bg-white focus-within:border-2 focus-within:border-pink-600",
      @errors != [] && "border-rose-400 focus-within:border-rose-500"
    ]}>
      <legend :if={@label} class="ml-1 px-1 text-xs font-medium text-gray-700">
        {@formatted_label}
      </legend>
      <textarea
        id={@id}
        name={@name}
        class="w-full border-0 bg-transparent px-3 py-1.5 text-gray-900 placeholder:text-gray-400 focus:ring-0 sm:text-sm resize-none min-h-[6rem]"
        {@rest}
      >{Phoenix.HTML.Form.normalize_value("textarea", @value)}</textarea>
      <.error :for={msg <- @errors}>{msg}</.error>
    </fieldset>
    """
  end

  # All other inputs text, datetime-local, url, password, etc. are handled here...
  def input(assigns) do
    assigns =
      assigns
      |> assign(
        :has_value,
        Phoenix.HTML.Form.normalize_value(assigns[:type] || "text", assigns[:value]) not in [
          nil,
          ""
        ]
      )
      |> assign(:formatted_label, format_label(assigns[:label]))

    ~H"""
    <fieldset class={[
      "group border rounded-md bg-white",
      @has_value && "border-pink-600",
      !@has_value && "border-gray-300 focus-within:border-pink-600",
      @errors != [] && "border-rose-400 focus-within:border-rose-500"
    ]}>
      <legend :if={@label} class="ml-1 px-1 text-xs font-medium text-gray-700">
        {@formatted_label}
      </legend>
      <div class="flex items-center px-2 cursor-text">
        <input
          type={@type}
          name={@name}
          id={@id}
          value={Phoenix.HTML.Form.normalize_value(@type, @value)}
          placeholder={!@has_value && "Enter value" || ""}
          class={[
            "w-full border-0 bg-transparent focus:ring-0 text-sm py-1.5 focus:placeholder:hidden",
            @has_value && "text-pink-600 focus:text-gray-900",
            !@has_value && "text-gray-900"
          ]}
          {@rest}
        />
      </div>
      <.error :for={msg <- @errors}>{msg}</.error>
    </fieldset>
    """
  end

  @doc """
  Generates a generic error message.
  """
  slot(:inner_block, required: true)

  def error(assigns) do
    ~H"""
    <p class="mt-2 text-sm text-rose-600">
      {render_slot(@inner_block)}
    </p>
    """
  end

  defp format_label(nil), do: nil

  defp format_label(label) when is_binary(label) do
    label
    |> String.split("_")
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(" ")
  end

  defp format_label(label), do: to_string(label)
end

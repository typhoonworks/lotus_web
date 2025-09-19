defmodule Lotus.Web.Queries.WidgetComponent do
  use Lotus.Web, :html
  alias Lotus.Web.Queries.ToolbarComponents, as: Toolbar
  alias Lotus.Web.Formatters.VariableOptionsFormatter, as: OptionsFormatter

  @moduledoc """
  Renders a single variable widget for the toolbar.

  Props:
    * var               - %QueryVariable{} or map with keys:
                          :name, :type (:text|:number|:date),
                          :widget (:input|:select|:date),
                          :label, :default, :static_options
    * value             - current value override (from @variable_values); falls back to var.default
    * class             - extra classes for outer wrapper
    * resolved_options  - pre-resolved Phoenix select options [{label, value}] for SQL-based dropdowns;
                          takes precedence over static_options when provided
  """

  attr(:var, :map, required: true)
  attr(:value, :any, default: nil)
  attr(:class, :string, default: nil)
  attr(:resolved_options, :list, default: nil)

  def widget(assigns) do
    assigns =
      assigns
      |> assign_new(:name, fn -> "variables[#{assigns.var.name}]" end)
      |> assign_new(:label, fn -> assigns.var.label || format_label(assigns.var.name) end)
      |> assign_new(:id, fn -> "variable_#{assigns.var.name}" end)
      |> assign_new(:value, fn -> assigns.value || assigns.var.default end)
      |> assign_new(:widget, fn -> widget_type(assigns.var) end)
      |> assign_new(:options, fn ->
        if assigns.resolved_options && assigns.resolved_options != [] do
          assigns.resolved_options
        else
          OptionsFormatter.to_select_options(assigns.var.static_options)
        end
      end)

    ~H"""
    <div class={["flex items-center gap-2 min-w-32", @class]}>
      <%= case @widget do %>
        <% :date -> %>
          <Toolbar.input
            id={@id}
            type="date"
            name={@name}
            label={@label}
            value={@value}
            class="min-w-32 w-32"
          />

        <% :select -> %>
          <Toolbar.input
            id={@id}
            type="select"
            name={@name}
            label={@label}
            value={@value}
            options={@options}
            prompt={if @options == [], do: "Select value"}
            disabled={@options == []}
            class="min-w-32 w-32"
          />

        <% _ -> %>
          <Toolbar.input
            id={@id}
            type={if @var.type == :number, do: "number", else: "text"}
            name={@name}
            label={@label}
            value={@value}
            placeholder="Enter value"
            class="w-32"
          />
      <% end %>
    </div>
    """
  end

  defp widget_type(%{type: :date}), do: :date
  defp widget_type(%{widget: :select}), do: :select
  defp widget_type(_), do: :input

  defp format_label(name) when is_binary(name) do
    name
    |> String.split("_")
    |> Enum.map_join(" ", &String.capitalize/1)
  end

  defp format_label(name), do: to_string(name)
end

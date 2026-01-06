defmodule Lotus.Web.VegaSpecBuilder do
  @moduledoc """
  Transforms query results and visualization config into Vega-Lite specifications.
  """

  @doc """
  Builds a Vega-Lite spec from query result and visualization config.

  ## Config shape

      %{
        "chart_type" => "bar" | "line" | "area" | "scatter" | "pie",
        "x_field" => "column_name",
        "y_field" => "column_name",
        "series_field" => "column_name" | nil,
        "x_axis_title" => "Custom Label" | nil,
        "y_axis_title" => "Custom Label" | nil,
        "x_axis_show_label" => boolean (default: true),
        "y_axis_show_label" => boolean (default: true)
      }

  ## Examples

      iex> result = %{columns: ["name", "value"], rows: [["A", 10], ["B", 20]]}
      iex> config = %{"chart_type" => "bar", "x_field" => "name", "y_field" => "value"}
      iex> VegaSpecBuilder.build(result, config)
      %{
        "$schema" => "https://vega.github.io/schema/vega-lite/v5.json",
        "data" => %{"values" => [%{"name" => "A", "value" => 10}, %{"name" => "B", "value" => 20}]},
        "mark" => %{"type" => "bar"},
        "encoding" => %{
          "x" => %{"field" => "name", "type" => "nominal"},
          "y" => %{"field" => "value", "type" => "quantitative"}
        }
      }
  """
  def build(result, config) do
    %{
      "$schema" => "https://vega.github.io/schema/vega-lite/v5.json",
      "data" => %{"values" => transform_data(result)},
      "mark" => chart_mark(config["chart_type"]),
      "encoding" => build_encoding(config, result)
    }
  end

  defp transform_data(%{columns: columns, rows: rows}) do
    Enum.map(rows, fn row ->
      columns
      |> Enum.zip(row)
      |> Map.new()
    end)
  end

  defp chart_mark("bar"), do: %{"type" => "bar"}
  defp chart_mark("line"), do: %{"type" => "line", "point" => true}
  defp chart_mark("area"), do: %{"type" => "area", "line" => true}
  defp chart_mark("scatter"), do: %{"type" => "point"}
  defp chart_mark("pie"), do: %{"type" => "arc"}
  defp chart_mark(_), do: %{"type" => "bar"}

  defp build_encoding(config, result) do
    chart_type = config["chart_type"]

    if chart_type == "pie" do
      build_pie_encoding(config, result)
    else
      build_cartesian_encoding(config, result)
    end
  end

  defp build_cartesian_encoding(config, result) do
    x_field = config["x_field"]
    y_field = config["y_field"]
    series_field = config["series_field"]

    base = %{
      "x" => %{
        "field" => x_field,
        "type" => infer_type(x_field, result),
        "axis" => build_axis_config(config, :x, x_field)
      },
      "y" => %{
        "field" => y_field,
        "type" => "quantitative",
        "axis" => build_axis_config(config, :y, y_field)
      }
    }

    if series_field && series_field != "" do
      Map.put(base, "color", %{
        "field" => series_field,
        "type" => "nominal"
      })
    else
      base
    end
  end

  defp build_axis_config(config, axis, default_title) do
    {title_key, show_label_key} =
      case axis do
        :x -> {"x_axis_title", "x_axis_show_label"}
        :y -> {"y_axis_title", "y_axis_show_label"}
      end

    show_label = Map.get(config, show_label_key, true)
    custom_title = Map.get(config, title_key)

    base_axis =
      case axis do
        :x -> %{"labelAngle" => -45}
        :y -> %{}
      end

    title =
      cond do
        show_label == false -> nil
        custom_title && custom_title != "" -> custom_title
        true -> default_title
      end

    Map.put(base_axis, "title", title)
  end

  defp build_pie_encoding(config, _result) do
    x_field = config["x_field"]
    y_field = config["y_field"]
    series_field = config["series_field"]

    # For pie charts, theta is the angle (value) and color is the category
    category_field = if series_field && series_field != "", do: series_field, else: x_field

    %{
      "theta" => %{
        "field" => y_field,
        "type" => "quantitative"
      },
      "color" => %{
        "field" => category_field,
        "type" => "nominal"
      }
    }
  end

  # Infer field type based on sample data
  defp infer_type(field, %{columns: columns, rows: rows}) when length(rows) > 0 do
    field_index = Enum.find_index(columns, &(&1 == field))

    if field_index do
      sample_value = rows |> hd() |> Enum.at(field_index)
      infer_type_from_value(sample_value)
    else
      "nominal"
    end
  end

  defp infer_type(_field, _result), do: "nominal"

  defp infer_type_from_value(value) when is_number(value), do: "quantitative"
  defp infer_type_from_value(%Date{}), do: "temporal"
  defp infer_type_from_value(%DateTime{}), do: "temporal"
  defp infer_type_from_value(%NaiveDateTime{}), do: "temporal"

  defp infer_type_from_value(value) when is_binary(value) do
    # Try to detect if it's a date/time string
    if Regex.match?(~r/^\d{4}-\d{2}-\d{2}/, value) do
      "temporal"
    else
      "nominal"
    end
  end

  defp infer_type_from_value(_), do: "nominal"
end

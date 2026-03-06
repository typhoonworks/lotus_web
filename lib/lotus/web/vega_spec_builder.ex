defmodule Lotus.Web.VegaSpecBuilder do
  @moduledoc """
  Transforms query results and visualization config into Vega-Lite specifications.
  """

  use Gettext, backend: Lotus.Web.Gettext

  @chart_type_ids ~w(bar horizontal_bar line area combo scatter bubble histogram heatmap pie donut funnel waterfall kpi trend gauge progress sparkline)

  @doc "Returns the ordered list of chart type ID strings."
  def chart_type_ids, do: @chart_type_ids

  @doc "Returns chart types organized into display groups for the UI grid."
  def chart_type_groups do
    [
      {gettext("Charts"), ~w(bar horizontal_bar line area combo)},
      {gettext("Distribution"), ~w(scatter bubble histogram heatmap)},
      {gettext("Part of whole"), ~w(pie donut funnel waterfall)},
      {gettext("Single value"), ~w(kpi trend gauge progress sparkline)}
    ]
  end

  @doc "Returns a human-readable label for the given chart type ID."
  def chart_type_label("bar"), do: gettext("Bar Chart")
  def chart_type_label("horizontal_bar"), do: gettext("Horizontal Bar")
  def chart_type_label("line"), do: gettext("Line Chart")
  def chart_type_label("area"), do: gettext("Area Chart")
  def chart_type_label("combo"), do: gettext("Combo Chart")
  def chart_type_label("scatter"), do: gettext("Scatter Plot")
  def chart_type_label("bubble"), do: gettext("Bubble Chart")
  def chart_type_label("pie"), do: gettext("Pie Chart")
  def chart_type_label("donut"), do: gettext("Donut Chart")
  def chart_type_label("funnel"), do: gettext("Funnel Chart")
  def chart_type_label("waterfall"), do: gettext("Waterfall")
  def chart_type_label("heatmap"), do: gettext("Heatmap")
  def chart_type_label("histogram"), do: gettext("Histogram")
  def chart_type_label("kpi"), do: gettext("KPI Card")
  def chart_type_label("trend"), do: gettext("Trend")
  def chart_type_label("gauge"), do: gettext("Gauge")
  def chart_type_label("progress"), do: gettext("Progress Bar")
  def chart_type_label("sparkline"), do: gettext("Sparkline")
  def chart_type_label(_), do: gettext("Chart")

  @doc """
  Returns `true` when `config` contains enough fields for its chart type to render.

  Used by both the query editor and results components to decide whether a
  visualization can be shown.
  """
  @spec valid_config?(map() | nil) :: boolean()
  def valid_config?(nil), do: false

  def valid_config?(%{"chart_type" => "kpi", "value_field" => vf})
      when is_binary(vf) and vf != "",
      do: true

  def valid_config?(%{"chart_type" => "histogram", "x_field" => xf})
      when is_binary(xf) and xf != "",
      do: true

  def valid_config?(config) when is_map(config) do
    Map.has_key?(config, "chart_type") &&
      Map.has_key?(config, "x_field") && config["x_field"] != "" &&
      Map.has_key?(config, "y_field") && config["y_field"] != ""
  end

  def valid_config?(_), do: false

  @doc """
  Builds the appropriate config map for a given chart type, picking only the
  relevant keys from `viz`. Prevents stale fields from leaking across type switches.

  Returns `%{}` when `chart_type` is nil or empty (i.e. "Table (default)" selected).

  Note: axis display fields (x_axis_title, y_axis_title, etc.) are intentionally
  excluded because the dashboard card settings don't currently expose axis controls.
  """
  @spec build_config(map()) :: map()
  def build_config(%{"chart_type" => ct}) when ct in [nil, ""], do: %{}

  def build_config(viz) do
    chart_type = viz["chart_type"]

    base = %{"chart_type" => chart_type}

    fields =
      case chart_type do
        "kpi" -> ~w(value_field kpi_label)
        "histogram" -> ~w(x_field bin_count series_field)
        _ -> ~w(x_field y_field series_field)
      end

    Enum.reduce(fields, base, fn key, acc ->
      case viz[key] do
        nil -> acc
        "" -> acc
        val -> Map.put(acc, key, val)
      end
    end)
  end

  @doc """
  Builds a Vega-Lite spec from query result and visualization config.

  ## Config shape

      %{
        "chart_type" => "bar" | "line" | "area" | "scatter" | "pie" | "funnel" | "heatmap" | "histogram" | "kpi" | "sparkline",
        "x_field" => "column_name",
        "y_field" => "column_name",
        "series_field" => "column_name" | nil,
        "x_axis_title" => "Custom Label" | nil,
        "y_axis_title" => "Custom Label" | nil,
        "x_axis_show_label" => boolean (default: true),
        "y_axis_show_label" => boolean (default: true),
        "value_field" => "column_name" (for KPI),
        "kpi_label" => "Custom Label" (for KPI, optional),
        "bin_count" => integer (for histogram, default: 10)
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
    chart_type = config["chart_type"]

    case chart_type do
      "kpi" -> build_kpi(result, config)
      "sparkline" -> build_sparkline(result, config)
      "histogram" -> build_histogram(result, config)
      "funnel" -> build_funnel(result, config)
      "heatmap" -> build_heatmap(result, config)
      "horizontal_bar" -> build_horizontal_bar(result, config)
      _ -> build_standard(result, config)
    end
  end

  defp build_standard(result, config) do
    %{
      "$schema" => "https://vega.github.io/schema/vega-lite/v5.json",
      "data" => %{"values" => transform_data(result)},
      "mark" => chart_mark(config["chart_type"]),
      "encoding" => build_encoding(config, result)
    }
  end

  # --- Horizontal bar chart ---
  # Swaps x/y: nominal field on y-axis, quantitative field on x-axis
  defp build_horizontal_bar(result, config) do
    x_field = config["x_field"]
    y_field = config["y_field"]
    series_field = config["series_field"]

    base = %{
      "$schema" => "https://vega.github.io/schema/vega-lite/v5.json",
      "data" => %{"values" => transform_data(result)},
      "mark" => %{"type" => "bar"},
      "encoding" => %{
        "y" => %{
          "field" => x_field,
          "type" => infer_type(x_field, result),
          "axis" => build_axis_config(config, :y, x_field),
          "sort" => nil
        },
        "x" => %{
          "field" => y_field,
          "type" => "quantitative",
          "axis" => build_axis_config(config, :x, y_field)
        }
      }
    }

    if series_field && series_field != "" do
      put_in(base, ["encoding", "color"], %{
        "field" => series_field,
        "type" => "nominal"
      })
    else
      base
    end
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
  defp chart_mark("donut"), do: %{"type" => "arc", "innerRadius" => 50}
  defp chart_mark(_), do: %{"type" => "bar"}

  defp build_encoding(config, result) do
    chart_type = config["chart_type"]

    if chart_type in ~w(pie donut) do
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

  # --- Funnel chart ---
  # Uses stack: "center" to produce symmetric centered bars (native Vega-Lite approach).
  # See: https://stackoverflow.com/questions/60444288
  defp build_funnel(result, config) do
    x_field = config["x_field"]
    y_field = config["y_field"]

    %{
      "$schema" => "https://vega.github.io/schema/vega-lite/v5.json",
      "data" => %{"values" => transform_data(result)},
      "encoding" => %{
        "y" => %{
          "field" => x_field,
          "type" => "nominal",
          "sort" => %{"field" => y_field, "order" => "descending"},
          "axis" => %{"title" => nil}
        }
      },
      "layer" => [
        %{
          "mark" => %{"type" => "bar"},
          "encoding" => %{
            "color" => %{
              "field" => x_field,
              "type" => "nominal",
              "legend" => nil
            },
            "x" => %{
              "field" => y_field,
              "type" => "quantitative",
              "stack" => "center",
              "axis" => nil
            }
          }
        },
        %{
          "mark" => %{"type" => "text", "fontSize" => 12},
          "encoding" => %{
            "text" => %{
              "field" => y_field,
              "type" => "quantitative"
            }
          }
        }
      ]
    }
  end

  # --- Heatmap chart ---
  # Both axes default to nominal for discrete cells.
  # When an explicit value field (series_field) is provided it drives the color
  # encoding as quantitative; otherwise the y_field is reused as nominal.
  defp build_heatmap(result, config) do
    x_field = config["x_field"]
    y_field = config["y_field"]
    explicit_color = config["series_field"]

    {color_field, color_type} =
      if explicit_color && explicit_color != "" do
        {explicit_color, "quantitative"}
      else
        {y_field, "nominal"}
      end

    %{
      "$schema" => "https://vega.github.io/schema/vega-lite/v5.json",
      "data" => %{"values" => transform_data(result)},
      "mark" => %{"type" => "rect"},
      "encoding" => %{
        "x" => %{
          "field" => x_field,
          "type" => "nominal",
          "axis" => build_axis_config(config, :x, x_field)
        },
        "y" => %{
          "field" => y_field,
          "type" => "nominal",
          "axis" => build_axis_config(config, :y, y_field)
        },
        "color" => %{
          "field" => color_field,
          "type" => color_type,
          "scale" => %{"scheme" => "yellowgreenblue"}
        }
      }
    }
  end

  # --- Histogram chart ---
  # Bins a numeric field and shows frequency distribution
  defp build_histogram(result, config) do
    x_field = config["x_field"]
    bin_count = parse_bin_count(config["bin_count"])

    base = %{
      "$schema" => "https://vega.github.io/schema/vega-lite/v5.json",
      "data" => %{"values" => transform_data(result)},
      "mark" => %{"type" => "bar"},
      "encoding" => %{
        "x" => %{
          "field" => x_field,
          "bin" => %{"maxbins" => bin_count},
          "type" => "quantitative",
          "axis" => build_axis_config(config, :x, x_field)
        },
        "y" => %{
          "aggregate" => "count",
          "type" => "quantitative",
          "axis" => build_axis_config(config, :y, "Count")
        }
      }
    }

    series_field = config["series_field"]

    if series_field && series_field != "" do
      put_in(base, ["encoding", "color"], %{
        "field" => series_field,
        "type" => "nominal"
      })
    else
      base
    end
  end

  @max_bins 100
  defp parse_bin_count(nil), do: 10
  defp parse_bin_count(val) when is_integer(val) and val > 0, do: min(val, @max_bins)

  defp parse_bin_count(val) when is_binary(val) do
    case Integer.parse(val) do
      {n, _} when n > 0 -> min(n, @max_bins)
      _ -> 10
    end
  end

  defp parse_bin_count(_), do: 10

  # --- KPI / Metric Card ---
  # Renders a single large number with optional label text
  defp build_kpi(result, config) do
    value_field = config["value_field"]
    kpi_label = config["kpi_label"]
    data = transform_data(result)

    # Extract the first row's value
    first_row = List.first(data) || %{}
    raw_value = Map.get(first_row, value_field)

    {display_value, format} =
      case raw_value do
        nil -> {"—", nil}
        v when is_number(v) -> {v, ","}
        v -> {to_string(v), nil}
      end

    kpi_data = [
      %{
        "_value" => display_value,
        "_label" => kpi_label || value_field || ""
      }
    ]

    value_encoding =
      if format do
        %{"field" => "_value", "type" => "quantitative", "format" => format}
      else
        %{"field" => "_value", "type" => "nominal"}
      end

    %{
      "$schema" => "https://vega.github.io/schema/vega-lite/v5.json",
      "data" => %{"values" => kpi_data},
      "layer" => [
        %{
          "mark" => %{
            "type" => "text",
            "fontSize" => 64,
            "fontWeight" => "bold",
            "align" => "center",
            "baseline" => "middle",
            "dy" => -10
          },
          "encoding" => %{
            "text" => value_encoding
          }
        },
        %{
          "mark" => %{
            "type" => "text",
            "fontSize" => 16,
            "align" => "center",
            "baseline" => "middle",
            "dy" => 30,
            "color" => "#6b7280"
          },
          "encoding" => %{
            "text" => %{"field" => "_label", "type" => "nominal"}
          }
        }
      ]
    }
  end

  # --- Sparkline chart ---
  # A minimal line chart with no axes, gridlines, or labels
  defp build_sparkline(result, config) do
    x_field = config["x_field"]
    y_field = config["y_field"]

    %{
      "$schema" => "https://vega.github.io/schema/vega-lite/v5.json",
      "data" => %{"values" => transform_data(result)},
      "mark" => %{
        "type" => "area",
        "line" => true,
        "interpolate" => "monotone",
        "opacity" => 0.3
      },
      "encoding" => %{
        "x" => %{
          "field" => x_field,
          "type" => infer_type(x_field, result),
          "axis" => nil
        },
        "y" => %{
          "field" => y_field,
          "type" => "quantitative",
          "axis" => nil,
          "scale" => %{"zero" => false}
        }
      },
      "config" => %{
        "view" => %{"stroke" => nil}
      }
    }
  end

  # Infer field type based on sample data
  defp infer_type(field, %{columns: columns, rows: [_ | _] = rows}) do
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

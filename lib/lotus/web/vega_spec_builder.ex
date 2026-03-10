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

  def valid_config?(%{"chart_type" => ct, "value_field" => vf})
      when ct in ~w(kpi gauge progress trend) and is_binary(vf) and vf != "",
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

    Enum.reduce(config_fields(chart_type), base, fn key, acc ->
      case viz[key] do
        nil -> acc
        "" -> acc
        val -> Map.put(acc, key, val)
      end
    end)
  end

  defp config_fields("kpi"), do: ~w(value_field kpi_label)
  defp config_fields("gauge"), do: ~w(value_field kpi_label min_value max_value)
  defp config_fields("progress"), do: ~w(value_field kpi_label goal_value)
  defp config_fields("trend"), do: ~w(value_field kpi_label comparison_field)
  defp config_fields("histogram"), do: ~w(x_field bin_count series_field)
  defp config_fields("bubble"), do: ~w(x_field y_field series_field size_field)
  defp config_fields("combo"), do: ~w(x_field y_field y2_field series_field y2_axis_title)
  defp config_fields(_), do: ~w(x_field y_field series_field)

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
        "$schema" => "https://vega.github.io/schema/vega-lite/v6.json",
        "data" => %{"values" => [%{"name" => "A", "value" => 10}, %{"name" => "B", "value" => 20}]},
        "mark" => %{"type" => "bar"},
        "encoding" => %{
          "x" => %{"field" => "name", "type" => "nominal"},
          "y" => %{"field" => "value", "type" => "quantitative"}
        }
      }
  """
  def build(result, %{"chart_type" => "kpi"} = config), do: build_kpi(result, config)
  def build(result, %{"chart_type" => "sparkline"} = config), do: build_sparkline(result, config)
  def build(result, %{"chart_type" => "histogram"} = config), do: build_histogram(result, config)
  def build(result, %{"chart_type" => "funnel"} = config), do: build_funnel(result, config)
  def build(result, %{"chart_type" => "heatmap"} = config), do: build_heatmap(result, config)

  def build(result, %{"chart_type" => "horizontal_bar"} = config),
    do: build_horizontal_bar(result, config)

  def build(result, %{"chart_type" => "waterfall"} = config), do: build_waterfall(result, config)
  def build(result, %{"chart_type" => "gauge"} = config), do: build_gauge(result, config)
  def build(result, %{"chart_type" => "progress"} = config), do: build_progress(result, config)
  def build(result, %{"chart_type" => "trend"} = config), do: build_trend(result, config)
  def build(result, %{"chart_type" => "combo"} = config), do: build_combo(result, config)
  def build(result, config), do: build_standard(result, config)

  defp build_standard(result, config) do
    %{
      "$schema" => "https://vega.github.io/schema/vega-lite/v6.json",
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
      "$schema" => "https://vega.github.io/schema/vega-lite/v6.json",
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
      |> Map.new(fn {col, val} -> {col, normalize_value(val)} end)
    end)
  end

  # Vega needs Decimals as numbers, not strings, so handle before the general normalizer
  defp normalize_value(%Decimal{} = val) do
    if Decimal.integer?(val), do: Decimal.to_integer(val), else: Decimal.to_float(val)
  end

  defp normalize_value(val), do: Lotus.Normalizer.normalize(val)

  defp chart_mark("bar"), do: %{"type" => "bar"}
  defp chart_mark("line"), do: %{"type" => "line", "point" => true}
  defp chart_mark("area"), do: %{"type" => "area", "line" => true}
  defp chart_mark("scatter"), do: %{"type" => "point"}
  defp chart_mark("bubble"), do: %{"type" => "point"}
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

    base =
      if series_field && series_field != "" do
        Map.put(base, "color", %{
          "field" => series_field,
          "type" => "nominal"
        })
      else
        base
      end

    size_field = config["size_field"]

    if size_field && size_field != "" do
      Map.put(base, "size", %{
        "field" => size_field,
        "type" => "quantitative"
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
      "$schema" => "https://vega.github.io/schema/vega-lite/v6.json",
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
      "$schema" => "https://vega.github.io/schema/vega-lite/v6.json",
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
      "$schema" => "https://vega.github.io/schema/vega-lite/v6.json",
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
      "$schema" => "https://vega.github.io/schema/vega-lite/v6.json",
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
      "$schema" => "https://vega.github.io/schema/vega-lite/v6.json",
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

  # --- Gauge chart ---
  # Semicircular arc showing value within a min/max range
  defp build_gauge(result, config) do
    value_field = config["value_field"]
    kpi_label = config["kpi_label"]
    min_val = parse_number(config["min_value"], 0)
    max_val = parse_number(config["max_value"], 100)
    data = transform_data(result)

    first_row = List.first(data) || %{}
    raw_value = Map.get(first_row, value_field)

    numeric_value =
      case raw_value do
        v when is_number(v) -> v
        _ -> 0
      end

    # Clamp and calculate proportion
    range = max(max_val - min_val, 1)
    proportion = min(max((numeric_value - min_val) / range, 0), 1)

    # Arc angles: -π/2 to π/2 (semicircle)
    start_angle = -:math.pi() / 2
    end_angle = :math.pi() / 2
    value_angle = start_angle + proportion * (end_angle - start_angle)

    label = kpi_label || value_field || ""

    %{
      "$schema" => "https://vega.github.io/schema/vega-lite/v6.json",
      "data" => %{"values" => [%{"_v" => 1}]},
      "layer" => [
        # Background arc
        %{
          "mark" => %{
            "type" => "arc",
            "innerRadius" => 60,
            "outerRadius" => 80,
            "theta" => end_angle,
            "theta2" => start_angle,
            "color" => "#e5e7eb"
          }
        },
        # Foreground arc (value)
        %{
          "mark" => %{
            "type" => "arc",
            "innerRadius" => 60,
            "outerRadius" => 80,
            "theta" => value_angle,
            "theta2" => start_angle,
            "color" => "#ec4899"
          }
        },
        # Value text
        %{
          "mark" => %{
            "type" => "text",
            "fontSize" => 36,
            "fontWeight" => "bold",
            "align" => "center",
            "baseline" => "middle",
            "dy" => -5
          },
          "encoding" => %{
            "text" => %{"value" => format_display_value(numeric_value)}
          }
        },
        # Label text
        %{
          "mark" => %{
            "type" => "text",
            "fontSize" => 14,
            "align" => "center",
            "baseline" => "middle",
            "dy" => 20,
            "color" => "#6b7280"
          },
          "encoding" => %{
            "text" => %{"value" => label}
          }
        }
      ]
    }
  end

  # --- Progress bar chart ---
  # Horizontal bar showing value as proportion of a goal
  defp build_progress(result, config) do
    value_field = config["value_field"]
    kpi_label = config["kpi_label"]
    goal = parse_number(config["goal_value"], 100)
    data = transform_data(result)

    first_row = List.first(data) || %{}
    raw_value = Map.get(first_row, value_field)

    numeric_value =
      case raw_value do
        v when is_number(v) -> v
        _ -> 0
      end

    label = kpi_label || value_field || ""
    pct = if goal > 0, do: Float.round(numeric_value / goal * 100, 1), else: 0

    %{
      "$schema" => "https://vega.github.io/schema/vega-lite/v6.json",
      "data" => %{
        "values" => [
          %{"_type" => "background", "_value" => goal},
          %{"_type" => "value", "_value" => min(numeric_value, goal)}
        ]
      },
      "layer" => [
        # Background bar
        %{
          "mark" => %{"type" => "bar", "height" => 24, "cornerRadius" => 4, "color" => "#e5e7eb"},
          "encoding" => %{
            "x" => %{
              "field" => "_value",
              "type" => "quantitative",
              "scale" => %{"domain" => [0, goal]},
              "axis" => nil
            }
          },
          "transform" => [%{"filter" => "datum._type === 'background'"}]
        },
        # Value bar
        %{
          "mark" => %{
            "type" => "bar",
            "height" => 24,
            "cornerRadius" => 4,
            "color" => "#ec4899"
          },
          "encoding" => %{
            "x" => %{
              "field" => "_value",
              "type" => "quantitative",
              "scale" => %{"domain" => [0, goal]},
              "axis" => nil
            }
          },
          "transform" => [%{"filter" => "datum._type === 'value'"}]
        },
        # Percentage text
        %{
          "mark" => %{
            "type" => "text",
            "fontSize" => 28,
            "fontWeight" => "bold",
            "align" => "center",
            "baseline" => "middle",
            "dy" => -30
          },
          "encoding" => %{
            "text" => %{"value" => "#{pct}%"}
          }
        },
        # Label text
        %{
          "mark" => %{
            "type" => "text",
            "fontSize" => 14,
            "align" => "center",
            "baseline" => "middle",
            "dy" => 30,
            "color" => "#6b7280"
          },
          "encoding" => %{
            "text" => %{"value" => label}
          }
        }
      ]
    }
  end

  # --- Trend indicator ---
  # Shows a large number with comparison delta (arrow + percentage)
  defp build_trend(result, config) do
    value_field = config["value_field"]
    comparison_field = config["comparison_field"]
    kpi_label = config["kpi_label"]
    data = transform_data(result)

    first_row = List.first(data) || %{}
    second_row = Enum.at(data, 1) || %{}

    current_value = extract_numeric(first_row, value_field, 0)
    comparison_value = resolve_comparison(first_row, second_row, value_field, comparison_field)
    label = kpi_label || value_field || ""
    {delta_text, delta_color} = format_delta(current_value, comparison_value)

    %{
      "$schema" => "https://vega.github.io/schema/vega-lite/v6.json",
      "data" => %{"values" => [%{"_v" => 1}]},
      "layer" => [
        %{
          "mark" => %{
            "type" => "text",
            "fontSize" => 48,
            "fontWeight" => "bold",
            "align" => "center",
            "baseline" => "middle",
            "dy" => -20
          },
          "encoding" => %{
            "text" => %{"value" => format_display_value(current_value)}
          }
        },
        %{
          "mark" => %{
            "type" => "text",
            "fontSize" => 14,
            "align" => "center",
            "baseline" => "middle",
            "dy" => 10,
            "color" => "#6b7280"
          },
          "encoding" => %{
            "text" => %{"value" => label}
          }
        },
        %{
          "mark" => %{
            "type" => "text",
            "fontSize" => 16,
            "fontWeight" => "bold",
            "align" => "center",
            "baseline" => "middle",
            "dy" => 35,
            "color" => delta_color
          },
          "encoding" => %{
            "text" => %{"value" => delta_text}
          }
        }
      ]
    }
  end

  defp extract_numeric(row, field, default) do
    case Map.get(row, field) do
      v when is_number(v) -> v
      _ -> default
    end
  end

  defp resolve_comparison(first_row, _second_row, _value_field, comp)
       when is_binary(comp) and comp != "" do
    extract_numeric(first_row, comp, nil)
  end

  defp resolve_comparison(_first_row, second_row, value_field, _comp) do
    extract_numeric(second_row, value_field, nil)
  end

  defp format_delta(_current, nil), do: {"", "#6b7280"}
  defp format_delta(_current, 0), do: {"", "#6b7280"}
  defp format_delta(_current, +0.0), do: {"", "#6b7280"}

  defp format_delta(current, comparison) do
    pct = Float.round((current - comparison) / abs(comparison) * 100, 1)

    if pct >= 0 do
      {"\u25B2 +#{pct}%", "#10b981"}
    else
      {"\u25BC #{pct}%", "#ef4444"}
    end
  end

  # --- Waterfall chart ---
  # Uses window transforms to create cumulative running totals
  defp build_waterfall(result, config) do
    x_field = config["x_field"]
    y_field = config["y_field"]

    %{
      "$schema" => "https://vega.github.io/schema/vega-lite/v6.json",
      "data" => %{"values" => transform_data(result)},
      "transform" => [
        %{
          "window" => [%{"op" => "sum", "field" => y_field, "as" => "_cumulative"}],
          "frame" => [nil, 0]
        },
        %{
          "calculate" => "datum._cumulative - datum['#{y_field}']",
          "as" => "_prev_cumulative"
        },
        %{
          "calculate" => "datum['#{y_field}'] >= 0 ? '#10b981' : '#ef4444'",
          "as" => "_color"
        }
      ],
      "mark" => %{"type" => "bar"},
      "encoding" => %{
        "x" => %{
          "field" => x_field,
          "type" => "nominal",
          "sort" => nil,
          "axis" => build_axis_config(config, :x, x_field)
        },
        "y" => %{
          "field" => "_prev_cumulative",
          "type" => "quantitative",
          "axis" => build_axis_config(config, :y, y_field)
        },
        "y2" => %{"field" => "_cumulative"},
        "color" => %{
          "field" => "_color",
          "type" => "nominal",
          "scale" => nil,
          "legend" => nil
        }
      }
    }
  end

  # --- Combo / dual-axis chart ---
  # Bar layer for y_field + optional line layer for y2_field with independent y scales
  defp build_combo(result, config) do
    x_field = config["x_field"]
    y_field = config["y_field"]
    y2_field = config["y2_field"]
    series_field = config["series_field"]
    y2_axis_title = config["y2_axis_title"]

    data = transform_data(result)

    bar_layer = %{
      "mark" => %{"type" => "bar"},
      "encoding" => %{
        "x" => %{
          "field" => x_field,
          "type" => infer_type(x_field, %{columns: Map.keys(List.first(data) || %{}), rows: []}),
          "axis" => build_axis_config(config, :x, x_field)
        },
        "y" => %{
          "field" => y_field,
          "type" => "quantitative",
          "axis" => build_axis_config(config, :y, y_field)
        }
      }
    }

    bar_layer =
      if series_field && series_field != "" do
        put_in(bar_layer, ["encoding", "color"], %{
          "field" => series_field,
          "type" => "nominal"
        })
      else
        bar_layer
      end

    layers =
      if y2_field && y2_field != "" do
        line_layer = %{
          "mark" => %{"type" => "line", "point" => true, "color" => "#f97316"},
          "encoding" => %{
            "x" => %{
              "field" => x_field,
              "type" =>
                infer_type(x_field, %{
                  columns: Map.keys(List.first(data) || %{}),
                  rows: []
                })
            },
            "y" => %{
              "field" => y2_field,
              "type" => "quantitative",
              "axis" => %{"title" => y2_axis_title || y2_field}
            }
          }
        }

        [bar_layer, line_layer]
      else
        [bar_layer]
      end

    spec = %{
      "$schema" => "https://vega.github.io/schema/vega-lite/v6.json",
      "data" => %{"values" => data},
      "layer" => layers
    }

    if y2_field && y2_field != "" do
      Map.put(spec, "resolve", %{"scale" => %{"y" => "independent"}})
    else
      spec
    end
  end

  defp parse_number(nil, default), do: default
  defp parse_number(val, _default) when is_number(val), do: val

  defp parse_number(val, default) when is_binary(val) do
    case Float.parse(val) do
      {n, _} -> n
      :error -> default
    end
  end

  defp parse_number(_, default), do: default

  defp format_display_value(value) when is_float(value) do
    if value == Float.round(value) do
      value |> round() |> Integer.to_string()
    else
      :erlang.float_to_binary(value, decimals: 1)
    end
  end

  defp format_display_value(value) when is_integer(value), do: Integer.to_string(value)
  defp format_display_value(value), do: to_string(value)

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

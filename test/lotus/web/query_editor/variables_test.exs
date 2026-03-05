defmodule Lotus.Web.QueryEditor.VariablesTest do
  use ExUnit.Case, async: true

  alias Lotus.Storage.QueryVariable
  alias Lotus.Web.QueryEditor.Variables

  defp var(attrs) do
    Map.merge(
      %QueryVariable{
        name: "x",
        type: :text,
        widget: :input,
        label: "X",
        default: nil,
        list: false,
        static_options: [],
        options_query: nil
      },
      Map.new(attrs)
    )
  end

  describe "build_ordered/3" do
    test "returns defaults for unknown names" do
      result = Variables.build_ordered(["status", "name"], [], nil)

      assert [%QueryVariable{name: "status"}, %QueryVariable{name: "name"}] = result
      assert hd(result).widget == :input
      assert hd(result).label == "Status"
    end

    test "preserves existing variables" do
      existing = [var(name: "status", label: "My Status", widget: :select)]

      [result] = Variables.build_ordered(["status"], existing, nil)

      assert result.label == "My Status"
      assert result.widget == :select
    end

    test "AI variables override existing" do
      existing = [var(name: "status", label: "Old", widget: :input)]

      ai = [%{"name" => "status", "type" => "text", "widget" => "select", "label" => "AI Label"}]

      [result] = Variables.build_ordered(["status"], existing, ai)

      assert result.label == "AI Label"
      assert result.widget == :select
    end

    test "preserves order of names" do
      existing = [var(name: "b"), var(name: "a")]
      result = Variables.build_ordered(["a", "b"], existing, nil)

      assert Enum.map(result, & &1.name) == ["a", "b"]
    end

    test "handles nil and empty AI variables" do
      assert Variables.build_ordered(["x"], [], nil) |> length() == 1
      assert Variables.build_ordered(["x"], [], []) |> length() == 1
    end
  end

  describe "normalize_values/2" do
    test "applies defaults when value is empty" do
      variables = [var(name: "status", default: "active")]
      values = %{"status" => ""}

      result = Variables.normalize_values(values, variables)
      assert result["status"] == "active"
    end

    test "applies defaults when value is nil" do
      variables = [var(name: "status", default: "active")]
      values = %{"status" => nil}

      result = Variables.normalize_values(values, variables)
      assert result["status"] == "active"
    end

    test "does not override non-empty values with defaults" do
      variables = [var(name: "status", default: "active")]
      values = %{"status" => "inactive"}

      result = Variables.normalize_values(values, variables)
      assert result["status"] == "inactive"
    end

    test "splits comma-separated string for list variables" do
      variables = [var(name: "tags", list: true)]
      values = %{"tags" => "a, b, c"}

      result = Variables.normalize_values(values, variables)
      assert result["tags"] == ["a", "b", "c"]
    end

    test "does not split non-list variables" do
      variables = [var(name: "name", list: false)]
      values = %{"name" => "a, b"}

      result = Variables.normalize_values(values, variables)
      assert result["name"] == "a, b"
    end

    test "applies default then splits for list variables" do
      variables = [var(name: "tags", list: true, default: "x,y")]
      values = %{"tags" => ""}

      result = Variables.normalize_values(values, variables)
      assert result["tags"] == ["x", "y"]
    end
  end

  describe "clear_values_on_widget_change/3" do
    test "clears value when widget changes" do
      old = [var(name: "status", widget: :input)]
      new = [var(name: "status", widget: :select)]
      values = %{"status" => "active"}

      result = Variables.clear_values_on_widget_change(values, new, old)
      assert result["status"] == nil
    end

    test "preserves value when widget unchanged" do
      old = [var(name: "status", widget: :input)]
      new = [var(name: "status", widget: :input)]
      values = %{"status" => "active"}

      result = Variables.clear_values_on_widget_change(values, new, old)
      assert result["status"] == "active"
    end

    test "clears value when list flag changes" do
      old = [var(name: "tags", widget: :input, list: false)]
      new = [var(name: "tags", widget: :input, list: true)]
      values = %{"tags" => "single"}

      result = Variables.clear_values_on_widget_change(values, new, old)
      assert result["tags"] == nil
    end

    test "does not clear new variables (no old match)" do
      old = []
      new = [var(name: "status", widget: :input)]
      values = %{"status" => "active"}

      result = Variables.clear_values_on_widget_change(values, new, old)
      assert result["status"] == "active"
    end
  end

  describe "clear_values_on_default_change/3" do
    test "clears value when default changes and current value is empty" do
      old = [var(name: "status", default: "old")]
      new = [var(name: "status", default: "new")]
      values = %{"status" => ""}

      result = Variables.clear_values_on_default_change(values, new, old)
      assert result["status"] == nil
    end

    test "clears value when default changes and current matches old default" do
      old = [var(name: "status", default: "old")]
      new = [var(name: "status", default: "new")]
      values = %{"status" => "old"}

      result = Variables.clear_values_on_default_change(values, new, old)
      assert result["status"] == nil
    end

    test "preserves value when default changes but current is user-set" do
      old = [var(name: "status", default: "old")]
      new = [var(name: "status", default: "new")]
      values = %{"status" => "custom"}

      result = Variables.clear_values_on_default_change(values, new, old)
      assert result["status"] == "custom"
    end

    test "does nothing when default is unchanged" do
      old = [var(name: "status", default: "same")]
      new = [var(name: "status", default: "same")]
      values = %{"status" => "same"}

      result = Variables.clear_values_on_default_change(values, new, old)
      assert result["status"] == "same"
    end

    test "handles list value matching comma-separated default" do
      old = [var(name: "tags", default: "a,b")]
      new = [var(name: "tags", default: "c,d")]
      values = %{"tags" => ["a", "b"]}

      result = Variables.clear_values_on_default_change(values, new, old)
      assert result["tags"] == nil
    end
  end

  describe "merge_defaults/2" do
    test "adds defaults for missing keys" do
      vars = [var(name: "status", default: "active"), var(name: "role", default: "admin")]

      result = Variables.merge_defaults(%{}, vars)
      assert result == %{"status" => "active", "role" => "admin"}
    end

    test "preserves existing values" do
      vars = [var(name: "status", default: "active")]

      result = Variables.merge_defaults(%{"status" => "custom"}, vars)
      assert result["status"] == "custom"
    end
  end

  describe "from_ai/2" do
    test "builds variable from AI config" do
      config = %{
        "type" => "number",
        "widget" => "select",
        "label" => "Count",
        "default" => "10",
        "list" => true,
        "options_query" => "SELECT id FROM items"
      }

      result = Variables.from_ai("count", config)

      assert result.name == "count"
      assert result.type == :number
      assert result.widget == :select
      assert result.label == "Count"
      assert result.default == "10"
      assert result.list == true
      assert result.options_query == "SELECT id FROM items"
    end

    test "uses formatted name as label when not provided" do
      result = Variables.from_ai("user_name", %{})

      assert result.label == "User Name"
    end
  end

  describe "format_label/1" do
    test "capitalizes and splits underscores" do
      assert Variables.format_label("user_name") == "User Name"
      assert Variables.format_label("status") == "Status"
      assert Variables.format_label("a_b_c") == "A B C"
    end

    test "passes through non-strings" do
      assert Variables.format_label(123) == 123
    end
  end

  describe "empty_value?/1" do
    test "nil, empty string, empty list are empty" do
      assert Variables.empty_value?(nil)
      assert Variables.empty_value?("")
      assert Variables.empty_value?([])
    end

    test "non-empty values are not empty" do
      refute Variables.empty_value?("x")
      refute Variables.empty_value?(["x"])
      refute Variables.empty_value?(0)
    end
  end

  describe "parse_type/1" do
    test "parses known types" do
      assert Variables.parse_type("number") == :number
      assert Variables.parse_type("date") == :date
    end

    test "defaults to text" do
      assert Variables.parse_type("unknown") == :text
      assert Variables.parse_type(nil) == :text
    end
  end

  describe "parse_widget/1" do
    test "parses select" do
      assert Variables.parse_widget("select") == :select
    end

    test "defaults to input" do
      assert Variables.parse_widget("unknown") == :input
      assert Variables.parse_widget(nil) == :input
    end
  end
end

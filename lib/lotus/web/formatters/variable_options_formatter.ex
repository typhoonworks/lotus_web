defmodule Lotus.Web.Formatters.VariableOptionsFormatter do
  @moduledoc """
  Handles conversion and formatting of variable static options between different formats:

  - Display format: Smart text representation for editing UI
  - Storage format: Maps with value/label keys for Lotus library
  - Legacy format: Simple string arrays for backward compatibility

  ## Display Format Rules

  When all options have the same value and label:
  ```
  "Bob\nAlice\nCharlie"
  ```

  When options have different values and labels:
  ```
  "bob | Bob\nalice | Alice\ncharlie | Charlie"
  ```

  ## Storage Format

  All options are stored as maps with string keys:
  ```
  [
    %{"value" => "bob", "label" => "Bob"},
    %{"value" => "alice", "label" => "Alice"}
  ]
  ```
  """

  @doc """
  Converts storage format options to display format for editing.

  ## Examples

      iex> options = [%{"value" => "bob", "label" => "Bob"}, %{"value" => "alice", "label" => "Alice"}]
      iex> VariableOptionsFormatter.to_display_format(options)
      "bob | Bob\\nalice | Alice"

      iex> options = [%{"value" => "Bob", "label" => "Bob"}, %{"value" => "Alice", "label" => "Alice"}]
      iex> VariableOptionsFormatter.to_display_format(options)
      "Bob\\nAlice"
  """
  @spec to_display_format([map()]) :: String.t()
  def to_display_format(options) when is_list(options) do
    normalized_options = normalize_to_maps(options)

    if all_same_value_label?(normalized_options) do
      normalized_options
      |> Enum.map(& &1["value"])
      |> Enum.join("\n")
    else
      normalized_options
      |> Enum.map(&"#{&1["value"]} | #{&1["label"]}")
      |> Enum.join("\n")
    end
  end

  def to_display_format(_), do: ""

  @doc """
  Converts display format string to storage format.

  ## Examples

      iex> VariableOptionsFormatter.from_display_format("Bob\\nAlice")
      [%{"value" => "Bob", "label" => "Bob"}, %{"value" => "Alice", "label" => "Alice"}]

      iex> VariableOptionsFormatter.from_display_format("bob | Bob\\nalice | Alice")
      [%{"value" => "bob", "label" => "Bob"}, %{"value" => "alice", "label" => "Alice"}]
  """
  @spec from_display_format(String.t()) :: [map()]
  def from_display_format(display_string) when is_binary(display_string) do
    display_string
    |> String.split("\n")
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(&parse_option_line/1)
  end

  def from_display_format(_), do: []

  @doc """
  Normalizes various option formats to the standard storage format.

  Handles:
  - Legacy string arrays: `["Bob", "Alice"]`
  - Storage format: `[%{"value" => "bob", "label" => "Bob"}]`
  - StaticOption structs: `[%{value: "bob", label: "Bob"}]`
  - Mixed formats during migration
  """
  @spec normalize_to_maps([any()]) :: [map()]
  def normalize_to_maps(options) when is_list(options) do
    options
    |> Enum.map(&normalize_single_option/1)
    |> Enum.reject(&is_nil/1)
  end

  def normalize_to_maps(_), do: []

  @doc """
  Converts storage format options to form params format for LiveView forms.
  """
  @spec to_form_params([map()]) :: [map()]
  def to_form_params(options) when is_list(options) do
    normalize_to_maps(options)
  end

  def to_form_params(_), do: []

  @doc """
  Converts StaticOption structs to storage format maps.
  """
  @spec static_options_to_storage([struct()] | [map()]) :: [map()]
  def static_options_to_storage(static_options) when is_list(static_options) do
    static_options
    |> Enum.map(fn
      %{value: value, label: label} -> %{"value" => to_string(value), "label" => to_string(label)}
      option -> normalize_single_option(option)
    end)
    |> Enum.reject(&is_nil/1)
  end

  def static_options_to_storage(_), do: []

  @doc """
  Converts static options to Phoenix select format: [{label, value}, ...].

  ## Examples

      iex> options = [%{"value" => "bob", "label" => "Bob"}, %{"value" => "alice", "label" => "Alice"}]
      iex> VariableOptionsFormatter.to_select_options(options)
      [{"Bob", "bob"}, {"Alice", "alice"}]
      
      iex> VariableOptionsFormatter.to_select_options(nil)
      []
  """
  @spec to_select_options([map()] | nil) :: [{String.t(), String.t()}]
  def to_select_options(nil), do: []

  def to_select_options(static_options) when is_list(static_options) do
    static_options
    |> normalize_to_maps()
    |> Enum.map(fn %{"value" => value, "label" => label} ->
      {label, value}
    end)
  end

  def to_select_options(_), do: []

  @doc """
  Converts Lotus query result to option maps format.

  Handles results with:
  - 1 column: uses value for both value and label
  - 2 columns: first is value, second is label  
  - 3+ columns: uses first two columns

  Values are formatted using Lotus.Value.to_display_string/1 to handle
  UUIDs and other binary data types properly.

  ## Examples

      iex> result = %{columns: ["name"], rows: [["Alice"], ["Bob"]]}
      iex> VariableOptionsFormatter.from_lotus_result(result)
      [%{value: "Alice", label: "Alice"}, %{value: "Bob", label: "Bob"}]
      
      iex> result = %{columns: ["id", "name"], rows: [[1, "Alice"], [2, "Bob"]]}
      iex> VariableOptionsFormatter.from_lotus_result(result)
      [%{value: 1, label: "Alice"}, %{value: 2, label: "Bob"}]
  """
  @spec from_lotus_result(map()) :: [map()]
  def from_lotus_result(%{columns: columns, rows: rows}) do
    column_count = length(columns)

    Enum.map(rows, fn row ->
      case column_count do
        1 ->
          raw_value = List.first(row)
          formatted_value = Lotus.Value.to_display_string(raw_value)
          %{value: formatted_value, label: formatted_value}

        2 ->
          [raw_value, raw_label] = row
          formatted_value = Lotus.Value.to_display_string(raw_value)
          formatted_label = Lotus.Value.to_display_string(raw_label)
          %{value: formatted_value, label: formatted_label}

        _ ->
          [raw_value, raw_label | _] = row
          formatted_value = Lotus.Value.to_display_string(raw_value)
          formatted_label = Lotus.Value.to_display_string(raw_label)
          %{value: formatted_value, label: formatted_label}
      end
    end)
  end

  def from_lotus_result(_), do: []

  defp normalize_single_option(nil), do: nil

  defp normalize_single_option(option) do
    case option do
      # Already in correct storage format
      %{"value" => value, "label" => label} when is_binary(value) and is_binary(label) ->
        option

      # StaticOption struct format
      %{value: value, label: label} ->
        %{"value" => to_string(value), "label" => to_string(label)}

      %Ecto.Changeset{} = changeset ->
        case Ecto.Changeset.apply_changes(changeset) do
          %{value: value, label: label} ->
            %{"value" => to_string(value), "label" => to_string(label)}

          other ->
            string_value = inspect(other)
            %{"value" => string_value, "label" => string_value}
        end

      # String format
      option_string when is_binary(option_string) ->
        parse_option_line(option_string)

      other ->
        string_value =
          cond do
            is_binary(other) -> other
            is_atom(other) -> Atom.to_string(other)
            is_number(other) -> to_string(other)
            true -> inspect(other)
          end

        %{"value" => string_value, "label" => string_value}
    end
  end

  defp parse_option_line(line) do
    case String.split(line, "|", parts: 2) do
      [value, label] ->
        %{"value" => String.trim(value), "label" => String.trim(label)}

      [value] ->
        trimmed_value = String.trim(value)
        %{"value" => trimmed_value, "label" => trimmed_value}
    end
  end

  defp all_same_value_label?(options) do
    Enum.all?(options, fn %{"value" => value, "label" => label} -> value == label end)
  end
end

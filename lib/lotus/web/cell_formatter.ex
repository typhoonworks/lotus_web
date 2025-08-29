defmodule Lotus.Web.CellFormatter do
  @moduledoc "Formats arbitrary DB values for safe display in result tables."

  def format(nil), do: ""

  # Dates & times
  def format(%Date{} = d), do: Date.to_string(d)
  def format(%Time{} = t), do: Time.to_string(t)
  def format(%NaiveDateTime{} = dt), do: NaiveDateTime.to_string(dt)
  def format(%DateTime{} = dt), do: DateTime.to_string(dt)

  # UUID binaries (16 bytes)
  def format(bin) when is_binary(bin) and byte_size(bin) == 16 do
    if String.valid?(bin) do
      bin
    else
      case Ecto.UUID.load(bin) do
        {:ok, uuid} -> uuid
        :error -> "<<binary, 16 bytes>>"
      end
    end
  end

  # Regular binaries
  def format(bin) when is_binary(bin), do: safe_binary(bin)

  # Numbers / booleans
  def format(n) when is_number(n), do: to_string(n)
  def format(b) when is_boolean(b), do: to_string(b)

  # Maps → JSON string (consistent for SQL result cells)
  def format(m) when is_map(m), do: Lotus.JSON.encode!(m)

  # Lists (arrays) → bracketed string
  def format(list) when is_list(list), do: format_list(list)

  # Fallback
  def format(other), do: inspect(other)

  defp safe_binary(bin) do
    if String.valid?(bin), do: bin, else: "<<binary, #{byte_size(bin)} bytes>>"
  end

  defp format_list(list) do
    "[" <>
      (list
       |> Enum.map(&format/1)
       |> Enum.join(", ")) <>
      "]"
  end
end

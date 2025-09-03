defmodule Lotus.Web.CellFormatter do
  @moduledoc "Formats arbitrary DB values for safe display in result tables."

  def format(v), do: Lotus.Value.to_display_string(v)
end

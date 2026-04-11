defmodule Lotus.Web.Pro do
  @moduledoc false

  @pro_web Lotus.Pro.Web

  @doc """
  Returns `true` if `Lotus.Pro.Web` is available at runtime.
  """
  @spec available?() :: boolean()
  def available? do
    Code.ensure_loaded?(@pro_web)
  end

  @doc """
  Returns Pro page descriptors, or `[]` if Pro is not installed.
  """
  @spec extra_pages() :: [map()]
  def extra_pages do
    if available?(), do: apply(@pro_web, :pages, []), else: []
  end

  @doc """
  Returns Pro nav item descriptors for the given assigns, or `[]` if Pro is not installed.
  """
  @spec nav_items(map()) :: [map()]
  def nav_items(assigns) do
    if available?(), do: apply(@pro_web, :nav_items, [assigns]), else: []
  end

  @doc """
  Renders Pro slot content, or `nil` if Pro is not installed.
  """
  @spec render_slot(atom(), map()) :: term() | nil
  def render_slot(name, assigns) do
    if available?(), do: apply(@pro_web, :render_slot, [name, assigns]), else: nil
  end
end

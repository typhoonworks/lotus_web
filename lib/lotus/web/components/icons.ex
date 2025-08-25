defmodule Lotus.Web.Components.Icons do
  use Lotus.Web, :html

  attr(:rest, :global,
    default: %{
      "aria-hidden": "true",
      class: "w-4 h-4",
      fill: "currentColor",
      viewBox: "0 0 16 16"
    }
  )

  slot(:inner_block, required: true)

  defp svg_mini(assigns) do
    ~H"""
    <svg {@rest}>
      {render_slot(@inner_block)}
    </svg>
    """
  end

  attr(:rest, :global,
    default: %{
      "stroke-width": "1.5",
      class: "w-6 h-6",
      fill: "none",
      stroke: "currentColor",
      viewBox: "0 0 24 24"
    }
  )

  slot(:inner_block, required: true)

  defp svg_outline(assigns) do
    ~H"""
    <svg {@rest}>
      {render_slot(@inner_block)}
    </svg>
    """
  end

  attr(:rest, :global,
    default: %{
      "aria-hidden": "true",
      class: "w-6 h-6",
      fill: "currentColor",
      viewBox: "0 0 24 24"
    }
  )

  slot(:inner_block, required: true)

  defp svg_solid(assigns) do
    ~H"""
    <svg xmlns="http://www.w3.org/2000/svg" {@rest}>
      {render_slot(@inner_block)}
    </svg>
    """
  end

  attr(:rest, :global)

  def check(assigns) do
    ~H"""
    <.svg_outline {@rest}>
      <path fill-rule="evenodd" clip-rule="evenodd" d="M16.704 4.153a.75.75 0 0 1 .143 1.052l-8 10.5a.75.75 0 0 1-1.127.075l-4.5-4.5a.75.75 0 1 1 1.06-1.06l3.894 3.893 7.48-9.817a.75.75 0 0 1 1.05-.143Z" />
    </.svg_outline>
    """
  end

  attr(:rest, :global)

  def database(assigns) do
    ~H"""
    <.svg_outline {@rest}>
      <path stroke-linecap="round" stroke-linejoin="round" d="M20.25 6.375c0 2.278-3.694 4.125-8.25 4.125S3.75 8.653 3.75 6.375m16.5 0c0-2.278-3.694-4.125-8.25-4.125S3.75 4.097 3.75 6.375m16.5 0v11.25c0 2.278-3.694 4.125-8.25 4.125s-8.25-1.847-8.25-4.125V6.375m16.5 0v3.75m-16.5-3.75v3.75m16.5 0v3.75C20.25 16.153 16.556 18 12 18s-8.25-1.847-8.25-4.125v-3.75m16.5 0c0 2.278-3.694 4.125-8.25 4.125s-8.25-1.847-8.25-4.125" />
    </.svg_outline>
    """
  end

  attr(:rest, :global)

  def maximize(assigns) do
    ~H"""
    <.svg_outline {@rest}>
      <path d="M15 3h6v6"/>
      <path d="m21 3-7 7"/>
      <path d="m3 21 7-7"/>
      <path d="M9 21H3v-6"/>
    </.svg_outline>
    """
  end

  attr(:rest, :global)

  def minimize(assigns) do
    ~H"""
    <.svg_outline {@rest}>
      <path d="m14 10 7-7"/>
      <path d="M20 10h-6V4"/>
      <path d="m3 21 7-7"/>
      <path d="M4 14h6v6"/>
    </.svg_outline>
    """
  end

  attr(:rest, :global)

  def play(assigns) do
    ~H"""
    <.svg_solid {@rest}>
      <path d="M8 5v14l11-7z"/>
    </.svg_solid>
    """
  end

  attr(:rest, :global)

  def tables(assigns) do
    ~H"""
    <.svg_outline {@rest}>
      <path d="M9 3H5a2 2 0 0 0-2 2v4m6-6h10a2 2 0 0 1 2 2v4M9 3v18m0 0h10a2 2 0 0 0 2-2V9M9 21H5a2 2 0 0 1-2-2V9m0 0h18"/>
    </.svg_outline>
    """
  end

  attr(:rest, :global)

  def terminal(assigns) do
    ~H"""
    <.svg_outline {@rest}>
      <path d="M12 19h8"/>
      <path d="m4 17 6-6-6-6"/>
    </.svg_outline>
    """
  end

  attr(:rest, :global)

  def x_mark(assigns) do
    ~H"""
    <.svg_outline {@rest}>
      <path d="M18 6 6 18"/><path d="m6 6 12 12"/>
    </.svg_outline>
    """
  end

  # Column type icons for schema explorer
  attr(:rest, :global)

  def key(assigns) do
    ~H"""
    <.svg_outline {@rest}>
      <path d="M21 2l-2 2m-7.61 7.61a5.5 5.5 0 1 1-7.778 7.778 5.5 5.5 0 0 1 7.777-7.777zm0 0L15.5 7.5m0 0l3 3L22 7l-3-3m-3.5 3.5L19 4"/>
    </.svg_outline>
    """
  end

  attr(:rest, :global)

  def text_type(assigns) do
    ~H"""
    <.svg_outline {@rest}>
      <path d="m15 16 2.536-7.328a1.02 1.02 1 0 1 1.928 0L22 16"/>
      <path d="M15.697 14h5.606"/>
      <path d="m2 16 4.039-9.69a.5.5 0 0 1 .923 0L11 16"/>
      <path d="M3.304 13h6.392"/>
    </.svg_outline>
    """
  end

  attr(:rest, :global)

  def file_digit(assigns) do
    ~H"""
    <.svg_outline {@rest}>
      <path d="M4 22h14a2 2 0 0 0 2-2V7l-5-5H6a2 2 0 0 0-2 2v4"/>
      <path d="M14 2v4a2 2 0 0 0 2 2h4"/>
      <rect width="4" height="6" x="2" y="12" rx="2"/>
      <path d="M10 12h2v6"/>
      <path d="M10 18h4"/>
    </.svg_outline>
    """
  end

  attr(:rest, :global)

  def decimals(assigns) do
    ~H"""
    <.svg_outline {@rest}>
      <path d="M10 18h10"/>
      <path d="m17 21 3-3-3-3"/>
      <path d="M3 11h.01"/>
      <rect x="15" y="3" width="5" height="8" rx="2.5"/>
      <rect x="6" y="3" width="5" height="8" rx="2.5"/>
    </.svg_outline>
    """
  end

  attr(:rest, :global)

  def calendar(assigns) do
    ~H"""
    <.svg_outline {@rest}>
      <rect x="3" y="4" width="18" height="18" rx="2" ry="2"/>
      <line x1="16" y1="2" x2="16" y2="6"/>
      <line x1="8" y1="2" x2="8" y2="6"/>
      <line x1="3" y1="10" x2="21" y2="10"/>
    </.svg_outline>
    """
  end

  attr(:rest, :global)

  def toggle_boolean(assigns) do
    ~H"""
    <.svg_outline {@rest}>
      <circle cx="9" cy="12" r="3"/>
      <rect width="20" height="14" x="2" y="5" rx="7"/>
    </.svg_outline>
    """
  end

  attr(:rest, :global)

  def list_bullet(assigns) do
    ~H"""
    <.svg_outline {@rest}>
      <line x1="8" y1="6" x2="21" y2="6"/>
      <line x1="8" y1="12" x2="21" y2="12"/>
      <line x1="8" y1="18" x2="21" y2="18"/>
      <line x1="3" y1="6" x2="3.01" y2="6"/>
      <line x1="3" y1="12" x2="3.01" y2="12"/>
      <line x1="3" y1="18" x2="3.01" y2="18"/>
    </.svg_outline>
    """
  end

  attr(:rest, :global)

  def chevron_left(assigns) do
    ~H"""
    <.svg_outline {@rest}>
      <polyline points="15,18 9,12 15,6"/>
    </.svg_outline>
    """
  end
end

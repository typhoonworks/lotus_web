defmodule Lotus.Web.Components.Icons do
  @moduledoc false

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

  def variable(assigns) do
    ~H"""
    <.svg_outline {@rest}>
      <path d="M8 3H7a2 2 0 0 0-2 2v5a2 2 0 0 1-2 2 2 2 0 0 1 2 2v5c0 1.1.9 2 2 2h1"/>
      <path d="M16 21h1a2 2 0 0 0 2-2v-5c0-1.1.9-2 2-2a2 2 0 0 1-2-2V5a2 2 0 0 0-2-2h-1"/>
      <g fill="currentColor" transform="translate(12,12) scale(0.45) translate(-12,-12)">
        <path clip-rule="evenodd" d="m9.06548 18.4761c-1.34638 1.6493-3.00206 3.0239-5.06548 3.0239-.55228 0-1-.4477-1-1s.44772-1 1-1c1.12026 0 2.2605-.7504 3.51616-2.2886 1.23641-1.5146 2.39737-3.5576 3.61384-5.7044l.0283-.05c1.1832-2.08816 2.4214-4.2735 3.7762-5.93313 1.3464-1.64931 3.0021-3.02387 5.0655-3.02387.5523 0 1 .44772 1 1 0 .55229-.4477 1-1 1-1.1203 0-2.2605.75044-3.5162 2.28863-1.2364 1.51461-2.3973 3.55757-3.6138 5.70437l-.0283.05c-1.1832 2.0882-2.4214 4.2735-3.77622 5.9331z" fill-rule="evenodd"/>
        <path d="m6.81813 4.53893c-.43622-.03805-.9922-.03893-1.81813-.03893-.55228 0-1-.44771-1-1 0-.55228.44772-1 1-1h.04234c.7728-.00001 1.41629-.00003 1.94962.0465.56129.04897 1.07052.15372 1.56437.40124.50398.2526.95613.60246 1.33717 1.02764.3669.4094.6233.87922.8565 1.42743.2254.53005.4529 1.19311.7332 2.0099l2.9135 8.49089c.295.8596.4997 1.4545.6938 1.9108.1895.4456.343.6942.5054.8754.2203.2458.4733.4388.7439.5745.188.0942.4241.1603.8421.1968.4362.038.9922.0389 1.8181.0389.5523 0 1 .4477 1 1s-.4477 1-1 1h-.0423c-.7728 0-1.4163 0-1.9497-.0465-.5612-.049-1.0705-.1537-1.5643-.4012-.504-.2526-.9562-.6025-1.3372-1.0277-.3669-.4094-.6233-.8792-.8565-1.4274-.2254-.5301-.4529-1.1931-.7332-2.0099l-2.9135-8.49089c-.29497-.85961-.49974-1.45455-.69381-1.91084-.18951-.4456-.34296-.69416-.50538-.87539-.2203-.24581-.47332-.43881-.74394-.57445-.18797-.09421-.42406-.16033-.84204-.1968z"/>
      </g>
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

  attr(:rest, :global)

  def layers(assigns) do
    ~H"""
    <.svg_outline {@rest}>
      <path d="M12.83 2.18a2 2 0 0 0-1.66 0L2.6 6.08a1 1 0 0 0 0 1.83l8.58 3.91a2 2 0 0 0 1.66 0l8.58-3.9a1 1 0 0 0 0-1.83z"/>
      <path d="M2 12a1 1 0 0 0 .58.91l8.6 3.91a2 2 0 0 0 1.65 0l8.58-3.9A1 1 0 0 0 22 12"/>
      <path d="M2 17a1 1 0 0 0 .58.91l8.6 3.91a2 2 0 0 0 1.65 0l8.58-3.9A1 1 0 0 0 22 17"/>
    </.svg_outline>
    """
  end

  attr(:rest, :global)

  def search(assigns) do
    ~H"""
    <.svg_outline {@rest}>
      <path d="m21 21-4.34-4.34"/>
      <circle cx="11" cy="11" r="8"/>
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
      <path d="M12 4v16"/>
      <path d="M4 7V5a1 1 0 0 1 1-1h14a1 1 0 0 1 1 1v2"/>
      <path d="M9 20h6"/>
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

  def command(assigns) do
    ~H"""
    <.svg_outline {@rest}>
      <path d="M15 6v12a3 3 0 1 0 3-3H6a3 3 0 1 0 3 3V6a3 3 0 1 0-3 3h12a3 3 0 1 0-3-3"/>
    </.svg_outline>
    """
  end

  attr(:rest, :global)

  def calendar(assigns) do
    ~H"""
    <.svg_outline {@rest}>
      <path d="M8 2v4"/>
      <path d="M16 2v4"/>
      <rect width="18" height="18" x="3" y="4" rx="2"/>
      <path d="M3 10h18"/>
      <path d="M8 14h.01"/>
      <path d="M12 14h.01"/>
      <path d="M16 14h.01"/>
      <path d="M8 18h.01"/>
      <path d="M12 18h.01"/>
      <path d="M16 18h.01"/>
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
      <path d="m15 18-6-6 6-6"/>
    </.svg_outline>
    """
  end

  attr(:rest, :global)

  def chevron_right(assigns) do
    ~H"""
    <.svg_outline {@rest}>
      <path d="m9 18 6-6-6-6"/>
    </.svg_outline>
    """
  end

  attr(:rest, :global)

  def sun(assigns) do
    ~H"""
    <.svg_outline {@rest}>
      <circle cx="12" cy="12" r="4"/>
      <path d="M12 2v2"/>
      <path d="M12 20v2"/>
      <path d="m4.93 4.93 1.41 1.41"/>
      <path d="m17.66 17.66 1.41 1.41"/>
      <path d="M2 12h2"/>
      <path d="M20 12h2"/>
      <path d="m6.34 17.66-1.41 1.41"/>
      <path d="m19.07 4.93-1.41 1.41"/>
    </.svg_outline>
    """
  end

  attr(:rest, :global)

  def moon(assigns) do
    ~H"""
    <.svg_outline {@rest}>
      <path d="M20.985 12.486a9 9 0 1 1-9.473-9.472c.405-.022.617.46.402.803a6 6 0 0 0 8.268 8.268c.344-.215.825-.004.803.401"/>
    </.svg_outline>
    """
  end

  attr(:rest, :global)

  def monitor(assigns) do
    ~H"""
    <.svg_outline {@rest}>
      <rect width="20" height="14" x="2" y="3" rx="2"/>
      <line x1="8" x2="16" y1="21" y2="21"/>
      <line x1="12" x2="12" y1="17" y2="21"/>
    </.svg_outline>
    """
  end

  attr(:rest, :global)

  def download(assigns) do
    ~H"""
    <.svg_outline {@rest}>
      <path d="M12 15V3"/>
      <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/>
      <path d="m7 10 5 5 5-5"/>
    </.svg_outline>
    """
  end

  attr(:rest, :global)

  def clipboard_copy(assigns) do
    ~H"""
    <.svg_outline {@rest}>
      <rect width="8" height="4" x="8" y="2" rx="1" ry="1"/>
      <path d="M8 4H6a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2v-2"/>
      <path d="M16 4h2a2 2 0 0 1 2 2v4"/>
      <path d="M21 14H11"/>
      <path d="m15 10-4 4 4 4"/>
    </.svg_outline>
    """
  end

  attr(:rest, :global)

  def information_circle(assigns) do
    ~H"""
    <.svg_solid {@rest}>
      <path d="M18 10a8 8 0 1 1-16 0 8 8 0 0 1 16 0Zm-7-4a1 1 0 1 1-2 0 1 1 0 0 1 2 0ZM9 9a.75.75 0 0 0 0 1.5h.253a.25.25 0 0 1 .244.304l-.459 2.066A1.75 1.75 0 0 0 10.747 15H11a.75.75 0 0 0 0-1.5h-.253a.25.25 0 0 1-.244-.304l.459-2.066A1.75 1.75 0 0 0 9.253 9H9Z" clip-rule="evenodd" fill-rule="evenodd" />
    </.svg_solid>
    """
  end

  attr(:rest, :global)

  def exclamation_triangle(assigns) do
    ~H"""
    <.svg_solid {@rest}>
      <path d="M8.485 2.495c.673-1.167 2.357-1.167 3.03 0l6.28 10.875c.673 1.167-.17 2.625-1.516 2.625H3.72c-1.347 0-2.189-1.458-1.515-2.625L8.485 2.495ZM10 5a.75.75 0 0 1 .75.75v3.5a.75.75 0 0 1-1.5 0v-3.5A.75.75 0 0 1 10 5Zm0 9a1 1 0 1 0 0-2 1 1 0 0 0 0 2Z" clip-rule="evenodd" fill-rule="evenodd" />
    </.svg_solid>
    """
  end
end

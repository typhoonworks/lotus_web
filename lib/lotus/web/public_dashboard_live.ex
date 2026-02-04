defmodule Lotus.Web.PublicDashboardLive do
  @moduledoc """
  LiveView for public (shared) dashboards.
  Does not require authentication.
  """

  use Lotus.Web, :live_view

  alias Lotus.Web.PublicDashboardPage

  @impl Phoenix.LiveView
  def mount(params, session, socket) do
    %{"prefix" => prefix} = session
    %{"live_path" => live_path, "live_transport" => live_transport} = session
    %{"csp_nonces" => csp_nonces} = session

    token = params["token"]
    page = %{name: :public_dashboard, comp: PublicDashboardPage, token: token}

    put_router_prefix(socket, prefix)

    socket =
      socket
      |> assign(params: params, page: page)
      |> assign(live_path: live_path, live_transport: live_transport)
      |> assign(:page_title, "Public Dashboard")
      |> assign(:csp_nonces, csp_nonces)
      |> assign(:resolver, nil)
      |> assign(:user, nil)
      |> assign(:access, :read_only)
      |> assign(:features, [])
      |> page.comp.handle_mount()

    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    assigns =
      assigns
      |> Map.put(:id, "page")
      |> Map.drop(~w(csp_nonces flash live_path live_transport refresh socket timer)a)

    ~H"""
    <.live_component id="page" module={@page.comp} {assigns} />
    """
  end

  @impl Phoenix.LiveView
  def handle_params(params, uri, socket) do
    socket.assigns.page.comp.handle_params(params, uri, socket)
  end

  @impl Phoenix.LiveView
  def handle_event("platform_info", %{"os" => os, "ua" => ua}, socket) do
    os_atom =
      case os do
        "mac" -> :mac
        "windows" -> :windows
        "linux" -> :linux
        _ -> :unknown
      end

    {:noreply, assign(socket, os: os_atom, ua: ua)}
  end

  @impl Phoenix.LiveView
  def handle_info({:put_flash, [type, message]}, socket) do
    {:noreply, put_flash(socket, type, message)}
  end

  def handle_info(message, socket) do
    socket.assigns.page.comp.handle_info(message, socket)
  end

  @impl Phoenix.LiveView
  def handle_async(name, async_fun_result, socket) do
    socket.assigns.page.comp.handle_async(name, async_fun_result, socket)
  end
end

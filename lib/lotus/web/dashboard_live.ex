defmodule Lotus.Web.DashboardLive do
  use Phoenix.LiveView, layout: {Lotus.Web.Layouts, :live}

  alias Lotus.Web.{QueriesPage, QueryEditorPage}

  @impl Phoenix.LiveView
  def mount(params, session, socket) do
    %{"prefix" => prefix} = session
    %{"live_path" => live_path, "live_transport" => live_transport} = session
    %{"csp_nonces" => csp_nonces} = session

    page = resolve_page(params)

    Process.put(:routing, {socket, prefix})

    socket =
      socket
      |> assign(params: params, page: page)
      |> assign(live_path: live_path, live_transport: live_transport)
      |> assign(:page_title, "Lotus Dashboard")
      |> assign(:csp_nonces, csp_nonces)
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
  def handle_info(message, socket) do
    socket.assigns.page.comp.handle_info(message, socket)
  end

  ## Render Helpers

  defp resolve_page(%{"page" => "queries", "id" => "new"}),
    do: %{name: :query_new, comp: QueryEditorPage, mode: :new}

  defp resolve_page(%{"page" => "queries", "id" => id}),
    do: %{name: :query_edit, comp: QueryEditorPage, mode: :edit, id: id}

  defp resolve_page(%{"page" => "queries"}), do: %{name: :queries, comp: QueriesPage}

  defp resolve_page(_params), do: %{name: :queries, comp: QueriesPage}
end

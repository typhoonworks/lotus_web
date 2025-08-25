defmodule Lotus.Web.Pages.QueriesPageTest do
  use Lotus.Web.Case

  import Phoenix.LiveViewTest

  setup do
    query1 = query_fixture(%{name: "All users"})
    query2 = query_fixture(%{name: "Active customers"})

    {:ok, live, _html} = live(build_conn(), "/lotus")

    {:ok, live: live, query1: query1, query2: query2}
  end

  test "lists saved queries", %{live: live, query1: query1, query2: query2} do
    assert has_query?(live, query1.name)
    assert has_query?(live, query2.name)
  end

  test "navigating to a saved query", %{live: live, query1: query1} do
    {:ok, query_live, _html} =
      live
      |> element("a", query1.name)
      |> render_click()
      |> follow_redirect(build_conn())

    assert render(query_live) =~ query1.name
    assert render(query_live) =~ query1.statement
  end

  defp has_query?(live, query_name) do
    has_element?(live, "#queries-table", query_name)
  end
end

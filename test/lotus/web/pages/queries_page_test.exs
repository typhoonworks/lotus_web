defmodule Lotus.Web.Pages.QueriesPageTest do
  use Lotus.Web.Case

  import Phoenix.LiveViewTest

  describe "navbar" do
    test "shows New button on protected routes" do
      {:ok, live, _html} = live(build_conn(), "/lotus")

      assert has_element?(live, "#new-item-dropdown button", "New")
    end
  end

  describe "empty state" do
    test "shows message when no queries exist" do
      {:ok, _live, html} = live(build_conn(), "/lotus")

      assert html =~ "No saved queries yet."
    end
  end

  describe "with queries" do
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
  end

  describe "dashboards tab" do
    test "preloads :cards so card counts render without triggering NotLoaded" do
      dashboard1 = dashboard_fixture(%{name: "Sales"})
      dashboard_card_fixture(dashboard1, %{position: 0})
      dashboard_card_fixture(dashboard1, %{position: 1})

      dashboard2 = dashboard_fixture(%{name: "Marketing"})
      dashboard_card_fixture(dashboard2, %{position: 0})

      {:ok, live, _html} = live(build_conn(), "/lotus?tab=dashboards")

      # The card count column renders `length(dashboard.cards)` — if `:cards`
      # were still `%Ecto.Association.NotLoaded{}`, render would raise and
      # the `{:ok, live, _}` match above would blow up. Asserting on the
      # actual counts also pins the preload to returning loaded data (not,
      # say, an accidentally-empty list).
      assert has_element?(live, ~s|#dashboards-table tr|, "Sales")
      assert has_element?(live, ~s|#dashboards-table tr|, "Marketing")

      html = render(live)
      assert html =~ "Sales"
      assert html =~ "Marketing"
      # Both dashboards' card-count cells are present.
      assert html =~ ~r/Sales.*?\b2\b/s
      assert html =~ ~r/Marketing.*?\b1\b/s
    end
  end

  defp has_query?(live, query_name) do
    has_element?(live, "#queries-table", query_name)
  end
end

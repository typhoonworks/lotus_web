defmodule Lotus.Web.ProIntegrationTest do
  use Lotus.Web.Case

  import Phoenix.LiveViewTest

  describe "DashboardLive resolve_page/1 regression" do
    test "queries page still resolves" do
      {:ok, _live, html} = live(build_conn(), "/lotus/queries")

      assert html =~ "No saved queries yet."
    end

    test "unknown page slug falls back to home" do
      {:ok, _live, html} = live(build_conn(), "/lotus/nonexistent")

      assert html =~ "No saved queries yet."
    end
  end

  describe "layout nav without Pro" do
    test "does not render Pro nav items" do
      {:ok, live, _html} = live(build_conn(), "/lotus")

      # Only built-in nav elements should be present
      assert has_element?(live, "#new-item-dropdown button", "New")
      # No Pro nav links in the nav bar
      refute has_element?(live, "nav a[data-pro-nav]")
    end
  end
end

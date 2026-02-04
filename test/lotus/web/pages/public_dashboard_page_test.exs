defmodule Lotus.Web.Pages.PublicDashboardPageTest do
  use Lotus.Web.Case

  import Phoenix.LiveViewTest

  describe "invalid token" do
    test "shows error for invalid token" do
      {:ok, _live, html} = live(build_conn(), "/lotus/public/invalid-token-123")

      assert html =~ "Dashboard not found"
    end
  end

  describe "valid token access" do
    setup do
      dashboard =
        public_dashboard_fixture(%{name: "Public Dashboard", description: "Shared view"})

      {:ok, dashboard: dashboard}
    end

    test "loads dashboard with valid public token", %{dashboard: dashboard} do
      {:ok, _live, html} = live(build_conn(), "/lotus/public/#{dashboard.public_token}")

      assert html =~ "Public Dashboard"
      assert html =~ "Shared view"
    end

    test "does not show edit controls (Save button)", %{dashboard: dashboard} do
      {:ok, live, _html} = live(build_conn(), "/lotus/public/#{dashboard.public_token}")

      # Verify Save button is not present
      refute has_element?(live, "button", "Save")
    end

    test "does not show New button on public routes", %{dashboard: dashboard} do
      {:ok, live, _html} = live(build_conn(), "/lotus/public/#{dashboard.public_token}")

      refute has_element?(live, "#new-item-dropdown")
    end

    test "shows footer with Lotus branding", %{dashboard: dashboard} do
      {:ok, _live, html} = live(build_conn(), "/lotus/public/#{dashboard.public_token}")

      assert html =~ "Powered by"
      assert html =~ "Lotus"
    end
  end

  describe "empty dashboard" do
    setup do
      dashboard = public_dashboard_fixture(%{name: "Empty Dashboard"})
      {:ok, dashboard: dashboard}
    end

    test "shows empty state message", %{dashboard: dashboard} do
      {:ok, _live, html} = live(build_conn(), "/lotus/public/#{dashboard.public_token}")

      assert html =~ "This dashboard has no cards"
    end
  end

  describe "dashboard with query card" do
    setup do
      create_test_users()
      dashboard = public_dashboard_fixture(%{name: "Dashboard with Content"})

      query =
        query_fixture(%{
          name: "Users Query",
          statement: "SELECT name, email FROM test_users ORDER BY name"
        })

      _card = query_card_fixture(dashboard, query, %{title: "Users"})
      {:ok, dashboard: dashboard}
    end

    test "displays query card title", %{dashboard: dashboard} do
      {:ok, _live, html} = live(build_conn(), "/lotus/public/#{dashboard.public_token}")

      # Query cards show their title in the header
      assert html =~ "Users"
    end
  end

  describe "query execution" do
    setup do
      create_test_users()
      dashboard = public_dashboard_fixture(%{name: "Query Dashboard"})

      query =
        query_fixture(%{
          name: "Users List",
          statement: "SELECT name, email FROM test_users ORDER BY name"
        })

      _card = query_card_fixture(dashboard, query, %{title: "Users"})
      {:ok, dashboard: dashboard}
    end

    test "executes query cards on load", %{dashboard: dashboard} do
      {:ok, live, _html} = live(build_conn(), "/lotus/public/#{dashboard.public_token}")

      # Wait for async query execution
      Process.sleep(100)

      html = render(live)

      # Should show query results
      assert html =~ "Alice"
      assert html =~ "Bob"
      assert html =~ "Charlie"
    end
  end
end

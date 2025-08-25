defmodule Lotus.Web.Pages.QueryEditorPageTest do
  use Lotus.Web.Case

  import Phoenix.LiveViewTest

  describe "query editor page" do
    test "loads the new query page" do
      {:ok, _live, html} = live(build_conn(), "/lotus/queries/new")

      # Verify the page loads with expected elements
      assert html =~ "New Query"
      assert html =~ "Save"

      # Verify the editor component is present
      assert html =~ "query-editor-page"
      assert html =~ "editor"
    end

    test "loads an existing query and auto-runs it" do
      create_test_users()

      query =
        query_fixture(%{
          name: "Test Users Query",
          statement: "SELECT name, email FROM test_users WHERE active = true ORDER BY name",
          description: "A test query for users"
        })

      {:ok, live, html} = live(build_conn(), "/lotus/queries/#{query.id}")

      assert html =~ "Test Users Query"
      assert html =~ "SELECT name, email FROM test_users"

      # Verify the query auto-ran and shows results
      # Should see the active users (Alice and Charlie)
      assert render(live) =~ "Alice"
      assert render(live) =~ "alice@test.com"
      assert render(live) =~ "Charlie"
      assert render(live) =~ "charlie@test.com"

      # Should NOT see inactive user (Bob)
      refute render(live) =~ "bob@test.com"
    end

    test "new query page loads" do
      {:ok, _live, html} = live(build_conn(), "/lotus/queries/new")

      assert html =~ "New Query"
      assert html =~ "Save"
      assert html =~ "disabled"

      assert html =~ "To run your query, click on the Run button"
    end
  end
end

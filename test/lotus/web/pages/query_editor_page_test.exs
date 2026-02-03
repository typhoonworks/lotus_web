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

  describe "query timeout selector (enabled via features: [:timeout_options])" do
    test "renders the timeout selector with default value of 5s" do
      {:ok, _live, html} = live(build_conn(), "/lotus/queries/new")

      assert html =~ "timeout-selector-tippy"
      assert html =~ ~s(name="query_timeout")
      assert html =~ ~s(value="5000" selected)
      assert html =~ ~s(value="15000")
      assert html =~ ~s(value="30000")
      assert html =~ ~s(value="60000")
      assert html =~ ~s(value="120000")
      assert html =~ ~s(value="300000")
      assert html =~ ~s(value="0")
    end

    test "changing the timeout value updates the selector" do
      {:ok, live, _html} = live(build_conn(), "/lotus/queries/new")

      html =
        live
        |> element(~s(form[phx-submit="run_query"]))
        |> render_change(%{"query_timeout" => "30000", "query" => %{"statement" => ""}})

      assert html =~ ~s(value="30000" selected)
      refute html =~ ~s(value="5000" selected)
    end

    test "submits a query with custom timeout" do
      {:ok, live, _html} = live(build_conn(), "/lotus/queries/new")

      # Set timeout to 60s and provide the statement
      live
      |> element(~s(form[phx-submit="run_query"]))
      |> render_change(%{
        "query_timeout" => "60000",
        "query" => %{"statement" => "SELECT 1 as result"}
      })

      # Run the query - verify submission doesn't error
      html =
        live
        |> element(~s(form[phx-submit="run_query"]))
        |> render_submit(%{
          "query" => %{
            "statement" => "SELECT 1 as result"
          }
        })

      # Verify the timeout selector still shows 60s after submission
      assert html =~ ~s(value="60000" selected)
      # Query should be running (no error about empty statement)
      refute html =~ "Please enter a SQL statement"
    end

    test "timeout selector persists value across form changes" do
      {:ok, live, _html} = live(build_conn(), "/lotus/queries/new")

      # Set timeout to 2 minutes
      live
      |> element(~s(form[phx-submit="run_query"]))
      |> render_change(%{"query_timeout" => "120000", "query" => %{"statement" => ""}})

      # Make another form change (e.g. typing in the editor)
      html =
        live
        |> element(~s(form[phx-submit="run_query"]))
        |> render_change(%{"query" => %{"statement" => "SELECT 1"}})

      # Timeout should still be 2m
      assert html =~ ~s(value="120000" selected)
    end
  end
end

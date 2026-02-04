defmodule Lotus.Web.Fixtures do
  @moduledoc """
  Test fixtures for database tests.
  """

  alias Lotus.Web.TestRepo

  @doc """
  Creates a query fixture for testing.

  ## Examples

      query = query_fixture()
      query = query_fixture(%{name: "Custom Query"})

  """
  def query_fixture(attrs \\ %{}) do
    defaults = %{
      name: "Test Query #{System.unique_integer([:positive])}",
      description: "A test query for automated testing",
      statement: "SELECT 1 as result"
    }

    attrs = Map.merge(defaults, attrs)

    {:ok, query} = Lotus.create_query(attrs)
    query
  end

  @doc """
  Creates test users in the database for query testing.

  ## Examples

      create_test_users()
      # Creates 3 users in the database
  """
  def create_test_users do
    users = [
      %{name: "Alice", email: "alice@test.com", active: true, age: 30},
      %{name: "Bob", email: "bob@test.com", active: false, age: 25},
      %{name: "Charlie", email: "charlie@test.com", active: true, age: 35}
    ]

    for user <- users do
      TestRepo.query!(
        """
          INSERT INTO test_users (name, email, active, age, inserted_at, updated_at)
          VALUES ($1, $2, $3, $4, NOW(), NOW())
        """,
        [user.name, user.email, user.active, user.age]
      )
    end

    :ok
  end

  @doc """
  Creates test posts in the database for query testing.
  """
  def create_test_posts do
    # First get user IDs
    %{rows: user_rows} = TestRepo.query!("SELECT id FROM test_users ORDER BY id LIMIT 3")
    [user1_id, user2_id, _user3_id] = Enum.map(user_rows, fn [id] -> id end)

    posts = [
      %{title: "First Post", content: "Hello World", user_id: user1_id, published: true},
      %{title: "Draft Post", content: "Work in progress", user_id: user1_id, published: false},
      %{title: "Another Post", content: "More content", user_id: user2_id, published: true}
    ]

    for post <- posts do
      TestRepo.query!(
        """
          INSERT INTO test_posts (title, content, user_id, published, inserted_at, updated_at)
          VALUES ($1, $2, $3, $4, NOW(), NOW())
        """,
        [post.title, post.content, post.user_id, post.published]
      )
    end

    :ok
  end

  @doc """
  Creates a dashboard fixture for testing.

  ## Examples

      dashboard = dashboard_fixture()
      dashboard = dashboard_fixture(%{name: "Custom Dashboard"})

  """
  def dashboard_fixture(attrs \\ %{}) do
    defaults = %{
      name: "Test Dashboard #{System.unique_integer([:positive])}",
      description: "A test dashboard for automated testing"
    }

    attrs = Map.merge(defaults, attrs)

    {:ok, dashboard} = Lotus.create_dashboard(attrs)
    dashboard
  end

  @doc """
  Creates a dashboard with public sharing enabled.

  ## Examples

      dashboard = public_dashboard_fixture()
      dashboard = public_dashboard_fixture(%{name: "Public Dashboard"})

  """
  def public_dashboard_fixture(attrs \\ %{}) do
    dashboard = dashboard_fixture(attrs)
    {:ok, dashboard} = Lotus.enable_public_sharing(dashboard)
    dashboard
  end

  @doc """
  Creates a dashboard card fixture for testing.

  ## Examples

      card = dashboard_card_fixture(dashboard)
      card = dashboard_card_fixture(dashboard, %{title: "My Card", card_type: :text})

  """
  def dashboard_card_fixture(dashboard, attrs \\ %{}) do
    defaults = %{
      card_type: :text,
      title: "Test Card",
      position: 0,
      layout: %{x: 0, y: 0, w: 6, h: 4},
      content: %{"text" => "Test content"}
    }

    attrs = Map.merge(defaults, attrs)

    {:ok, card} = Lotus.create_dashboard_card(dashboard.id, attrs)
    card
  end

  @doc """
  Creates a query card fixture for testing.

  Links a card to a query for displaying query results.

  ## Examples

      card = query_card_fixture(dashboard)
      card = query_card_fixture(dashboard, query)
      card = query_card_fixture(dashboard, query, %{title: "Revenue Chart"})

  """
  def query_card_fixture(dashboard, query \\ nil, attrs \\ %{}) do
    query = query || query_fixture()

    defaults = %{
      card_type: :query,
      query_id: query.id,
      title: "Query Card",
      position: 0,
      layout: %{x: 0, y: 0, w: 6, h: 4}
    }

    attrs = Map.merge(defaults, attrs)

    {:ok, card} = Lotus.create_dashboard_card(dashboard.id, attrs)
    card
  end
end

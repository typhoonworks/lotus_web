# Installation

This guide walks you through setting up LotusWeb in your Phoenix application.

## Requirements

- **Elixir 1.16+** and **OTP 25+**
- **Phoenix 1.7+** for LiveView compatibility
- **[Lotus 0.11+](https://hex.pm/packages/lotus)** configured in your application

> **Version Compatibility**: LotusWeb 0.10+ requires Lotus 0.11 or later.

## Step 1: Add Dependency

Add `lotus_web` to your dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:lotus_web, "~> 0.11.0"}
  ]
end
```

Run `mix deps.get` to fetch the dependency.

## Step 2: Configure Lotus (if not already done)

LotusWeb requires Lotus to be configured. Add to your `config/config.exs`:

```elixir
config :lotus,
  ecto_repo: MyApp.Repo,
  default_repo: "main",         # Default repository for query execution
  data_repos: %{
    "main" => MyApp.Repo,
    "analytics" => MyApp.AnalyticsRepo  # Optional: multiple databases
  },
  # Recommended: Enable caching for better dashboard performance
  cache: %{
    adapter: Lotus.Cache.ETS,
    namespace: "myapp_lotus"
    # Lotus includes built-in profiles that work great with LotusWeb:
    # - :results (60s TTL) - User query results  
    # - :schema (1h TTL) - Table introspection (used by dashboard)
    # - :options (5m TTL) - Dropdown options and reference data
  }
```

## Step 3: Run Lotus Migration (if not already done)

```bash
mix ecto.gen.migration create_lotus_tables
```

Add the migration content:

```elixir
defmodule MyApp.Repo.Migrations.CreateLotusTables do
  use Ecto.Migration

  def up do
    Lotus.Migrations.up()
  end

  def down do
    Lotus.Migrations.down()
  end
end
```

Run the migration:

```bash
mix ecto.migrate
```

## Step 4: Add Lotus to Supervision Tree (Required for Caching)

For caching to work, Lotus must be started as part of your application's supervision tree. Add Lotus to your application supervisor:

```elixir
# lib/my_app/application.ex
def start(_type, _args) do
  children = [
    MyApp.Repo,
    # Add Lotus for caching support (required for optimal dashboard performance)
    Lotus,
    MyAppWeb.Endpoint
  ]
  
  opts = [strategy: :one_for_one, name: MyApp.Supervisor]
  Supervisor.start_link(children, opts)
end
```

**Note**: Without this step, caching will be disabled and dashboard performance may be slower due to repeated database introspection queries.

## Step 5: Mount LotusWeb Dashboard

Add to your router:

```elixir
defmodule MyAppWeb.Router do
  use MyAppWeb, :router
  import Lotus.Web.Router

  # ... other routes

  scope "/", MyAppWeb do
    pipe_through [:browser, :require_authenticated_user] # ⚠️ Add auth!

    lotus_dashboard "/lotus"
  end
end
```

**⚠️ Security Warning**: Always mount behind authentication in production.

**Note**: Your `:browser` pipeline must include `fetch_session` and `fetch_flash` plugs for LotusWeb to work correctly. Most Phoenix apps have these by default.

### Optional Features

You can enable additional features by passing the `features` option:

```elixir
lotus_dashboard "/lotus",
  features: [:timeout_options]
```

| Feature | Description |
|---------|-------------|
| `:timeout_options` | Adds a per-query timeout selector to the query editor toolbar, allowing users to override the default 5-second query timeout for long-running queries. |

## Step 6: Visit the Dashboard

Start your Phoenix server and visit `/lotus` to access the dashboard.

## Next Steps

Continue with the [Getting Started](getting-started.md) guide to learn how to use LotusWeb.

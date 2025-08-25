# Installation

This guide walks you through setting up LotusWeb in your Phoenix application.

## Requirements

- Elixir 1.16 or later
- Phoenix 1.7 or later
- [Lotus](https://hex.pm/packages/lotus) configured in your application

## Step 1: Add Dependency

Add `lotus_web` to your dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:lotus_web, "~> 0.1.0"}
  ]
end
```

Run `mix deps.get` to fetch the dependency.

## Step 2: Configure Lotus (if not already done)

LotusWeb requires Lotus to be configured. Add to your `config/config.exs`:

```elixir
config :lotus,
  ecto_repo: MyApp.Repo,
  data_repos: %{
    "main" => MyApp.Repo,
    "analytics" => MyApp.AnalyticsRepo  # Optional: multiple databases
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

## Step 4: Mount LotusWeb Dashboard

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

## Step 5: Visit the Dashboard

Start your Phoenix server and visit `/lotus` to access the dashboard.

## Next Steps

Continue with the [Getting Started](getting-started.md) guide to learn how to use LotusWeb.
# Development server for Lotus Web

# Repos

defmodule WebDev.Repo do
  use Ecto.Repo, otp_app: :lotus_web, adapter: Ecto.Adapters.Postgres
end

defmodule WebDev.ReportingRepo do
  use Ecto.Repo, otp_app: :lotus_web, adapter: Ecto.Adapters.Postgres
end

defmodule WebDev.Migration0 do
  use Ecto.Migration

  def change do
    # Create sample tables for demonstration
    create table(:users) do
      add :name, :string, null: false
      add :email, :string, null: false
      add :status, :string, default: "active"
      add :age, :integer
      timestamps(type: :utc_datetime)
    end

    create table(:posts) do
      add :title, :string, null: false
      add :content, :text
      add :published, :boolean, default: false
      add :user_id, references(:users, on_delete: :delete_all), null: false
      timestamps(type: :utc_datetime)
    end

    create table(:orders) do
      add :total_amount, :decimal, precision: 10, scale: 2
      add :status, :string, default: "pending"
      add :user_id, references(:users, on_delete: :delete_all), null: false
      timestamps(type: :utc_datetime)
    end

    create index(:users, [:email])
    create index(:posts, [:user_id])
    create index(:posts, [:published])
    create index(:orders, [:user_id])
    create index(:orders, [:status])
  end
end

defmodule WebDev.Migration1 do
  use Ecto.Migration

  def change do
    execute(
      "CREATE SCHEMA IF NOT EXISTS reporting",
      "DROP SCHEMA IF EXISTS reporting CASCADE"
    )

    create table(:customers, prefix: "reporting") do
      add :name, :string, null: false
      add :email, :string, null: false
      add :active, :boolean, default: true
      timestamps(type: :utc_datetime)
    end

    create unique_index(:customers, [:email], prefix: "reporting")

    create table(:invoices, prefix: "reporting") do
      add :customer_id, references(:customers, on_delete: :delete_all, prefix: "reporting"),
        null: false
      add :total_amount, :decimal, precision: 10, scale: 2
      add :status, :string, default: "open"
      timestamps(type: :utc_datetime)
    end

    create index(:invoices, [:customer_id], prefix: "reporting")

    execute(
      "COMMENT ON TABLE reporting.customers IS 'Reporting demo table'",
      "COMMENT ON TABLE reporting.customers IS NULL"
    )
  end
end

defmodule WebDev.Migration2 do
  use Ecto.Migration

  def up do
    Lotus.Migrations.up()
  end

  def down do
    Lotus.Migrations.down()
  end
end

# Phoenix

defmodule WebDev.Router do
  use Phoenix.Router, helpers: false

  import Lotus.Web.Router

  pipeline :browser do
    plug(:fetch_session)
  end

  scope "/" do
    pipe_through(:browser)

    lotus_dashboard("/lotus")
  end
end

defmodule WebDev.Endpoint do
  use Phoenix.Endpoint, otp_app: :lotus_web

  socket("/live", Phoenix.LiveView.Socket)
  socket("/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket)

  plug(Phoenix.LiveReloader)
  plug(Phoenix.CodeReloader)

  plug(Plug.Static,
    at: "/",
    from: :lotus_web,
    only: ~w(app.css app.js fonts images favicon.ico robots.txt)
  )

  plug(Plug.Session,
    store: :cookie,
    key: "_lotus_web_key",
    signing_salt: "GB8lUrg7Zv8Pkt"
  )

  plug(WebDev.Router)
end

defmodule WebDev.ErrorHTML do
  use Phoenix.Component

  def render(template, _assigns) do
    Phoenix.Controller.status_message_from_template(template)
  end
end

# Configuration

port = "PORT" |> System.get_env("4000") |> String.to_integer()

Application.put_env(:lotus_web, WebDev.Endpoint,
  adapter: Bandit.PhoenixAdapter,
  check_origin: false,
  debug_errors: true,
  http: [port: port],
  live_view: [signing_salt: "UuMMKJSRnB6z91GJflEeqpp2M4lVgFc4"],
  pubsub_server: WebDev.PubSub,
  render_errors: [formats: [html: WebDev.ErrorHTML], layout: false],
  secret_key_base: "HYusO/Y1jNCOL7KxqmWuDTL74SasPCN2D7tbh2dLyKemStwCg2GhqINb4JFt1DFj",
  url: [host: "localhost"],
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:default, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:default, ~w(--watch=always)]},
  ],
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"lib/lotus/web/(pages|live|components)/.*(ex|heex)$"
    ]
  ]
)

Application.put_env(:lotus_web, WebDev.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  port: 2346,
  database: "lotus_web_dev"
)

Application.put_env(:lotus_web, WebDev.ReportingRepo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  port: 2346,
  database: "lotus_web_dev",
  parameters: [search_path: "reporting"]
)

Application.put_env(:phoenix, :serve_endpoints, true)
Application.put_env(:phoenix, :persistent, true)

# Configure Lotus with the development repos
Application.put_env(:lotus, :ecto_repo, WebDev.Repo)
Application.put_env(:lotus, :data_repos, %{
  "public"    => WebDev.Repo,
  "reporting" => WebDev.ReportingRepo
})

Task.async(fn ->
  children = [
    {Phoenix.PubSub, [name: WebDev.PubSub, adapter: Phoenix.PubSub.PG2]},
    {WebDev.Repo, []},
    {WebDev.ReportingRepo, []},
    {WebDev.Endpoint, []}
  ]

  Ecto.Adapters.Postgres.storage_up(WebDev.Repo.config())

  {:ok, _} = Supervisor.start_link(children, strategy: :one_for_one)

  Ecto.Migrator.run(
    WebDev.Repo,
    [
      {0, WebDev.Migration0},         # public.users/posts/orders
      {1, WebDev.Migration1},         # reporting.customers/invoices
      {2, WebDev.Migration2}          # Lotus.Migrations.up()
    ],
    :up,
    all: true
  )

  # --- DESTROY ALL EXISTING DATA ---

  WebDev.Repo.query!("TRUNCATE TABLE users, posts, orders RESTART IDENTITY CASCADE")
  WebDev.ReportingRepo.query!("TRUNCATE TABLE reporting.customers, reporting.invoices RESTART IDENTITY CASCADE")

  # --- USERS ---
  WebDev.Repo.query!("INSERT INTO users (name, email, age, status, inserted_at, updated_at) VALUES
    ('Alice', 'alice@example.com', 30, 'active', now(), now()),
    ('Bob',   'bob@example.com',   25, 'inactive', now(), now()),
    ('Charlie','charlie@example.com', 40, 'active', now(), now()),
    ('Diana', 'diana@example.com', 35, 'active', now(), now()),
    ('Eve',   'eve@example.com',   28, 'active', now(), now())
  ")

  # --- POSTS ---
  WebDev.Repo.query!("INSERT INTO posts (title, content, user_id, published, inserted_at, updated_at) VALUES
    ('Hello World',     'First post!', 1, true,  now(), now()),
    ('Draft Thoughts',  'Unpublished idea', 1, false, now(), now()),
    ('Bob’s Adventures','Exploring Elixir', 2, true,  now(), now()),
    ('Security Notes',  'Eve on crypto', 5, true,  now(), now()),
    ('Cooking with SQL','Charlie’s recipe', 3, false, now(), now())
  ")

  # --- ORDERS ---
  WebDev.Repo.query!("INSERT INTO orders (total_amount, status, user_id, inserted_at, updated_at) VALUES
    (49.99,  'pending',  1, now(), now()),
    (19.50,  'completed',2, now(), now()),
    (200.00, 'completed',3, now(), now()),
    (75.25,  'pending',  1, now(), now()),
    (300.10, 'shipped',  4, now(), now())
  ")

  # --- REPORTING.CUSTOMERS ---
  WebDev.ReportingRepo.query!("INSERT INTO customers (name, email, active, inserted_at, updated_at) VALUES
    ('Acme Corp',       'contact@acme.com',       true,  now(), now()),
    ('Globex Inc',      'info@globex.com',        true,  now(), now()),
    ('Initech',         'hello@initech.com',      false, now(), now()),
    ('Umbrella Corp',   'support@umbrella.com',   true,  now(), now())
  ")

  # --- REPORTING.INVOICES ---
  WebDev.ReportingRepo.query!("INSERT INTO invoices (customer_id, total_amount, status, inserted_at, updated_at) VALUES
    (1, 199.99, 'open',     now(), now()),
    (1, 500.00, 'paid',     now(), now()),
    (2, 250.00, 'overdue',  now(), now()),
    (3, 1000.00,'paid',     now(), now()),
    (4, 75.00,  'open',     now(), now())
  ")

  Process.sleep(:infinity)
end)

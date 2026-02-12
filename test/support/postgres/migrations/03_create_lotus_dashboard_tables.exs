defmodule Lotus.Test.Repo.Migrations.CreateLotusDashboardTables do
  use Ecto.Migration

  def up do
    Lotus.Migrations.up()
  end

  def down do
    Lotus.Migrations.down()
  end
end

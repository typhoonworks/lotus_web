defmodule Lotus.Web.Case do
  @moduledoc """
  This module defines the setup for tests requiring
  access to the application's data layer.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      import Plug.Conn
      import Phoenix.ConnTest
      import Phoenix.LiveViewTest

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import Lotus.Web.Case
      import Lotus.Web.Fixtures

      alias Lotus.Web.TestRepo
      alias Lotus.Web.Test.Router

      @endpoint Lotus.Web.Endpoint
    end
  end

  setup context do
    pid1 = Ecto.Adapters.SQL.Sandbox.start_owner!(Lotus.Web.TestRepo, shared: not context[:async])
    on_exit(fn -> Ecto.Adapters.SQL.Sandbox.stop_owner(pid1) end)

    :ok
  end
end

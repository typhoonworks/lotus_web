defmodule Lotus.Web do
  @moduledoc false

  def html do
    quote do
      @moduledoc false

      import Phoenix.Controller, only: [get_csrf_token: 0, view_module: 1, view_template: 1]

      unquote(html_helpers())
    end
  end

  def live_view do
    quote do
      @moduledoc false

      use Phoenix.LiveView, layout: {Lotus.Web.Layouts, :live}

      unquote(html_helpers())
    end
  end

  def live_component do
    quote do
      @moduledoc false

      use Phoenix.LiveComponent

      unquote(html_helpers())
    end
  end

  defp html_helpers do
    quote do
      use Phoenix.Component

      import Lotus.Web.Helpers
      import Phoenix.HTML
      import Phoenix.LiveView.Helpers
      import Lotus.Web.CoreComponents

      alias Phoenix.LiveView.JS
      alias Lotus.Web.Components.Icons
    end
  end

  @doc false
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end

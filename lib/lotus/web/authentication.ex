defmodule Lotus.Web.Authentication do
  @moduledoc false

  import Phoenix.Component
  import Phoenix.LiveView

  def on_mount(:default, _params, session, socket) do
    resolver = Map.get(session, "resolver")
    user = Map.get(session, "user")
    access = Map.get(session, "access", :all)
    
    socket = assign(socket, resolver: resolver, user: user, access: access)

    case access do
      {:forbidden, path} ->
        socket =
          socket
          |> put_flash(:error, "Access forbidden")
          |> push_navigate(to: path)

        {:halt, socket}

      :forbidden ->
        socket =
          socket
          |> put_flash(:error, "Access forbidden")
          |> push_navigate(to: "/")

        {:halt, socket}

      _ ->
        {:cont, socket}
    end
  end
end
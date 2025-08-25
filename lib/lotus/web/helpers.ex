defmodule Lotus.Web.Helpers do
  @moduledoc false

  alias Phoenix.{LiveView, VerifiedRoutes}

  # Routing Helpers

  @doc """
  Construct a path to a dashboard page with optional params.

  Routing is based on a socket and prefix tuple stored in the process dictionary. Proper routing
  can be disabled for testing by setting the value to `:nowhere`.
  """
  def lotus_path(route, params \\ %{})

  def lotus_path(route, params) when is_list(route) do
    route
    |> Enum.join("/")
    |> lotus_path(params)
  end

  def lotus_path(route, params) do
    params =
      params
      |> Enum.sort()
      |> encode_params()

    case Process.get(:routing) do
      {socket, prefix} ->
        VerifiedRoutes.unverified_path(socket, socket.router, "#{prefix}/#{route}", params)

      :nowhere ->
        "/"

      nil ->
        raise RuntimeError, "nothing stored in the :routing key"
    end
  end

  @doc """
  Prepare parsed params for URI encoding.
  """
  def encode_params(params) do
    for {key, val} <- params, val != nil, val != "" do
      case val do
        [path, frag] when is_list(path) ->
          {key, Enum.join(path, ",") <> "++" <> frag}

        [_ | _] ->
          {key, Enum.join(val, ",")}

        _ ->
          {key, val}
      end
    end
  end

  @doc """
  Restore params from URI encoding.
  """
  def decode_params(params) do
    Map.new(params, fn
      {"limit", val} ->
        {:limit, String.to_integer(val)}

      {key, val} when key in ~w(args meta) ->
        val =
          val
          |> String.split("++")
          |> List.update_at(0, &String.split(&1, ","))

        {String.to_existing_atom(key), val}

      {key, val} when key in ~w(ids modes nodes priorities queues stats tags workers) ->
        {String.to_existing_atom(key), String.split(val, ",")}

      {key, val} ->
        {String.to_existing_atom(key), val}
    end)
  end

  @doc """
  """
  def active_filter?(params, :state, value) do
    params[:state] == value or (is_nil(params[:state]) and value == "executing")
  end

  def active_filter?(params, key, value) do
    params
    |> Map.get(key, [])
    |> List.wrap()
    |> Enum.member?(to_string(value))
  end

  @doc """
  Put a flash message that will clear automatically after a timeout.
  """
  def put_flash_with_clear(socket, mode, message, timing \\ 5_000) do
    Process.send_after(self(), :clear_flash, timing)

    LiveView.put_flash(socket, mode, message)
  end
end

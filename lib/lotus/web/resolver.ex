defmodule Lotus.Web.Resolver do
  @moduledoc """
  Behavior for customizing Lotus Web dashboard access and functionality.
  """

  @type user :: nil | map() | struct()

  @type access_level ::
          :all
          | :read_only
          | :forbidden
          | {:forbidden, String.t()}

  @doc """
  Extract the current user from a Plug.Conn when the dashboard mounts.

  This callback is invoked when the Lotus dashboard is accessed. The returned
  user value will be passed to other callbacks for access control decisions.
  """
  @callback resolve_user(conn :: Plug.Conn.t()) :: user()

  @doc """
  Determine the access level for a user.

  Based on the user returned from `resolve_user/1`, this callback determines
  what operations the user can perform in the Lotus dashboard.

  ## Return Values

  - `:all` - Full access to all Lotus features
  - `:read_only` - Can only view and run queries, no modifications
  - `:forbidden` - No access
  - `{:forbidden, path}` - Redirect to the given path
  """
  @callback resolve_access(user :: user()) :: access_level()

  @optional_callbacks resolve_user: 1, resolve_access: 1

  @doc false
  def call_with_fallback(resolver, fun, args) when is_atom(fun) and is_list(args) do
    resolver = if function_exported?(resolver, fun, length(args)), do: resolver, else: __MODULE__

    apply(resolver, fun, args)
  end

  @doc false
  def resolve_user(_conn), do: nil

  @doc false
  def resolve_access(_user), do: :all
end

defmodule Lotus.Web.ResolverTest do
  use ExUnit.Case, async: true

  alias Lotus.Web.Resolver

  defmodule FullImpl do
    @behaviour Resolver

    def resolve_user(_conn), do: %{id: 123}
    def resolve_access(_user), do: :read_only
  end

  defmodule PartialImpl do
    @behaviour Resolver

    def resolve_user(_conn), do: :only_user
  end

  describe "defaults" do
    test "resolve_user/1 returns nil by default" do
      assert Resolver.resolve_user(%Plug.Conn{}) == nil
    end

    test "resolve_access/1 returns :all by default" do
      assert Resolver.resolve_access(%{}) == :all
    end
  end

  describe "call_with_fallback/3" do
    test "uses the implementation when function is exported" do
      assert %{id: 123} = Resolver.call_with_fallback(FullImpl, :resolve_user, [%Plug.Conn{}])
      assert :read_only == Resolver.call_with_fallback(FullImpl, :resolve_access, [%{}])
    end

    test "falls back to default when function isn't exported" do
      # PartialImpl doesn't implement resolve_access/1, so it should fallback
      assert :all == Resolver.call_with_fallback(PartialImpl, :resolve_access, [%{}])
      # But it does implement resolve_user/1
      assert :only_user == Resolver.call_with_fallback(PartialImpl, :resolve_user, [%Plug.Conn{}])
    end
  end
end

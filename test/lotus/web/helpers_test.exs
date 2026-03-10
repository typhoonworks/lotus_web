defmodule Lotus.Web.HelpersTest do
  use ExUnit.Case, async: true

  alias Lotus.Web.Helpers

  describe "safe_json_encode/1" do
    test "returns {:ok, json} for encodable data" do
      assert {:ok, json} = Helpers.safe_json_encode(%{key: "value"})
      assert Lotus.JSON.decode!(json) == %{"key" => "value"}
    end

    test "returns {:ok, json} for a list" do
      assert {:ok, json} = Helpers.safe_json_encode([1, 2, 3])
      assert Lotus.JSON.decode!(json) == [1, 2, 3]
    end

    test "returns {:error, :encoding_failed} for non-encodable binary" do
      {:ok, uuid_binary} = Ecto.UUID.dump("550e8400-e29b-41d4-a716-446655440000")
      assert {:error, :encoding_failed} = Helpers.safe_json_encode(%{id: uuid_binary})
    end

    test "returns {:error, :encoding_failed} for non-UTF-8 binary" do
      assert {:error, :encoding_failed} = Helpers.safe_json_encode(%{data: <<255, 254, 253>>})
    end
  end

  describe "safe_json_encode_or_empty/1" do
    test "returns JSON string for encodable data" do
      json = Helpers.safe_json_encode_or_empty(%{key: "value"})
      assert Lotus.JSON.decode!(json) == %{"key" => "value"}
    end

    test "returns empty object for non-encodable data" do
      {:ok, uuid_binary} = Ecto.UUID.dump("550e8400-e29b-41d4-a716-446655440000")
      assert "{}" == Helpers.safe_json_encode_or_empty(%{id: uuid_binary})
    end

    test "returns empty object for non-UTF-8 binary" do
      assert "{}" == Helpers.safe_json_encode_or_empty(%{data: <<255, 254, 253>>})
    end
  end
end

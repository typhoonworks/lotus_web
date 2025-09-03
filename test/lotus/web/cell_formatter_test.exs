defmodule Lotus.Web.CellFormatterTest do
  use ExUnit.Case, async: true

  alias Lotus.Web.CellFormatter

  describe "format/1" do
    test "formats nil as empty string" do
      assert CellFormatter.format(nil) == ""
    end

    test "formats Date" do
      date = ~D[2024-01-15]
      assert CellFormatter.format(date) == "2024-01-15"
    end

    test "formats Time" do
      time = ~T[14:30:45]
      assert CellFormatter.format(time) == "14:30:45"
    end

    test "formats NaiveDateTime" do
      naive_dt = ~N[2024-01-15 14:30:45]
      assert CellFormatter.format(naive_dt) == "2024-01-15T14:30:45"
    end

    test "formats DateTime" do
      {:ok, dt, _} = DateTime.from_iso8601("2024-01-15T14:30:45Z")
      assert CellFormatter.format(dt) == "2024-01-15T14:30:45Z"
    end

    test "formats UUID binary (16 bytes)" do
      uuid_string = "0198dee6-40aa-7b93-9f13-0d83a3bc9c7f"
      {:ok, uuid_binary} = Ecto.UUID.dump(uuid_string)

      assert CellFormatter.format(uuid_binary) == uuid_string
    end

    test "formats 16-byte UTF-8 string as regular string, not UUID" do
      sixteen_byte_string = "charlie@test.com"
      assert byte_size(sixteen_byte_string) == 16
      assert CellFormatter.format(sixteen_byte_string) == "charlie@test.com"

      another_16_byte = "exactly16bytes!!"
      assert byte_size(another_16_byte) == 16
      assert CellFormatter.format(another_16_byte) == "exactly16bytes!!"
    end

    test "formats valid UTF-8 string" do
      assert CellFormatter.format("hello world") == "hello world"
      assert CellFormatter.format("with special chars: 你好") == "with special chars: 你好"
    end

    test "formats invalid UTF-8 binary as Base64" do
      invalid_binary = <<0xFF, 0xFE, 0xFD>>

      assert CellFormatter.format(invalid_binary) == Base.encode64(invalid_binary)
    end

    test "formats integers" do
      assert CellFormatter.format(42) == "42"
      assert CellFormatter.format(-100) == "-100"
      assert CellFormatter.format(0) == "0"
    end

    test "formats floats" do
      assert CellFormatter.format(3.14) == "3.14"
      assert CellFormatter.format(-2.5) == "-2.5"
      assert CellFormatter.format(0.0) == "0.0"
    end

    test "formats booleans" do
      assert CellFormatter.format(true) == "true"
      assert CellFormatter.format(false) == "false"
    end

    test "formats maps as JSON" do
      map = %{name: "John", age: 30}
      result = CellFormatter.format(map)

      # JSON key order is not guaranteed, so we decode and compare
      decoded = Jason.decode!(result)
      assert decoded == %{"name" => "John", "age" => 30}
    end

    test "formats nested maps as JSON" do
      nested_map = %{
        user: %{
          name: "Alice",
          metadata: %{
            role: "admin"
          }
        }
      }

      result = CellFormatter.format(nested_map)
      decoded = Jason.decode!(result)

      assert decoded["user"]["name"] == "Alice"
      assert decoded["user"]["metadata"]["role"] == "admin"
    end

    test "formats list of primitives" do
      assert CellFormatter.format([1, 2, 3]) == "[1,2,3]"
      assert CellFormatter.format(["a", "b", "c"]) == "[\"a\",\"b\",\"c\"]"
      assert CellFormatter.format([true, false]) == "[true,false]"
    end

    test "formats list with mixed types" do
      mixed_list = [1, "hello", true, nil]
      assert CellFormatter.format(mixed_list) == "[1,\"hello\",true,null]"
    end

    test "formats nested lists" do
      nested_list = [[1, 2], [3, 4]]
      assert CellFormatter.format(nested_list) == "[[1,2],[3,4]]"
    end

    test "formats list with maps" do
      list_with_maps = [%{a: 1}, %{b: 2}]
      result = CellFormatter.format(list_with_maps)

      assert result == ~s([{"a":1},{"b":2}])
    end

    test "formats list with dates" do
      list_with_dates = [~D[2024-01-01], ~D[2024-01-02]]
      assert CellFormatter.format(list_with_dates) == ~s(["2024-01-01","2024-01-02"])
    end

    test "formats atoms as strings" do
      assert CellFormatter.format(:atom) == "atom"
      assert CellFormatter.format(:hello_world) == "hello_world"
    end

    test "formats tuples using inspect" do
      assert CellFormatter.format({1, 2, 3}) == "{1, 2, 3}"
      assert CellFormatter.format({:ok, "result"}) == ~s({:ok, "result"})
    end
  end
end

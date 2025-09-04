defmodule Lotus.Web.Formatters.VariableOptionsFormatterTest do
  use ExUnit.Case, async: true
  
  alias Lotus.Web.Formatters.VariableOptionsFormatter, as: OptionsFormatter
  
  describe "to_display_format/1" do
    test "converts simple options with same value and label to simple list" do
      options = [
        %{"value" => "Bob", "label" => "Bob"},
        %{"value" => "Alice", "label" => "Alice"},
        %{"value" => "Charlie", "label" => "Charlie"}
      ]
      
      result = OptionsFormatter.to_display_format(options)
      assert result == "Bob\nAlice\nCharlie"
    end
    
    test "converts options with different values and labels to value | label format" do
      options = [
        %{"value" => "bob", "label" => "Bob Smith"},
        %{"value" => "alice", "label" => "Alice Jones"},
        %{"value" => "charlie", "label" => "Charlie Brown"}
      ]
      
      result = OptionsFormatter.to_display_format(options)
      assert result == "bob | Bob Smith\nalice | Alice Jones\ncharlie | Charlie Brown"
    end
    
    test "handles mixed same/different value-label combinations correctly" do
      options = [
        %{"value" => "admin", "label" => "Administrator"},
        %{"value" => "user", "label" => "user"}
      ]
      
      result = OptionsFormatter.to_display_format(options)
      assert result == "admin | Administrator\nuser | user"
    end
    
    test "handles empty list" do
      assert OptionsFormatter.to_display_format([]) == ""
    end
    
    test "handles nil input" do
      assert OptionsFormatter.to_display_format(nil) == ""
    end
    
    test "handles non-list input" do
      assert OptionsFormatter.to_display_format("invalid") == ""
    end
  end
  
  describe "from_display_format/1" do
    test "converts simple list format to maps" do
      display_string = "Bob\nAlice\nCharlie"
      
      result = OptionsFormatter.from_display_format(display_string)
      expected = [
        %{"value" => "Bob", "label" => "Bob"},
        %{"value" => "Alice", "label" => "Alice"},
        %{"value" => "Charlie", "label" => "Charlie"}
      ]
      
      assert result == expected
    end
    
    test "converts value | label format to maps" do
      display_string = "bob | Bob Smith\nalice | Alice Jones\ncharlie | Charlie Brown"
      
      result = OptionsFormatter.from_display_format(display_string)
      expected = [
        %{"value" => "bob", "label" => "Bob Smith"},
        %{"value" => "alice", "label" => "Alice Jones"},
        %{"value" => "charlie", "label" => "Charlie Brown"}
      ]
      
      assert result == expected
    end
    
    test "handles mixed formats within same input" do
      display_string = "Simple\nbob | Bob Smith\nAnother"
      
      result = OptionsFormatter.from_display_format(display_string)
      expected = [
        %{"value" => "Simple", "label" => "Simple"},
        %{"value" => "bob", "label" => "Bob Smith"},
        %{"value" => "Another", "label" => "Another"}
      ]
      
      assert result == expected
    end
    
    test "trims whitespace from values and labels" do
      display_string = "  bob  |  Bob Smith  \n  alice  |  Alice Jones  "
      
      result = OptionsFormatter.from_display_format(display_string)
      expected = [
        %{"value" => "bob", "label" => "Bob Smith"},
        %{"value" => "alice", "label" => "Alice Jones"}
      ]
      
      assert result == expected
    end
    
    test "ignores empty lines" do
      display_string = "Bob\n\n\nAlice\n  \nCharlie"
      
      result = OptionsFormatter.from_display_format(display_string)
      expected = [
        %{"value" => "Bob", "label" => "Bob"},
        %{"value" => "Alice", "label" => "Alice"},
        %{"value" => "Charlie", "label" => "Charlie"}
      ]
      
      assert result == expected
    end
    
    test "handles empty string" do
      assert OptionsFormatter.from_display_format("") == []
    end
    
    test "handles nil input" do
      assert OptionsFormatter.from_display_format(nil) == []
    end
  end
  
  describe "normalize_to_maps/1" do
    test "normalizes legacy string array format" do
      legacy_options = ["Bob", "Alice", "Charlie"]
      
      result = OptionsFormatter.normalize_to_maps(legacy_options)
      expected = [
        %{"value" => "Bob", "label" => "Bob"},
        %{"value" => "Alice", "label" => "Alice"},
        %{"value" => "Charlie", "label" => "Charlie"}
      ]
      
      assert result == expected
    end
    
    test "normalizes StaticOption struct format" do
      struct_options = [
        %{value: "bob", label: "Bob Smith"},
        %{value: "alice", label: "Alice Jones"}
      ]
      
      result = OptionsFormatter.normalize_to_maps(struct_options)
      expected = [
        %{"value" => "bob", "label" => "Bob Smith"},
        %{"value" => "alice", "label" => "Alice Jones"}
      ]
      
      assert result == expected
    end
    
    test "handles already normalized map format" do
      map_options = [
        %{"value" => "bob", "label" => "Bob Smith"},
        %{"value" => "alice", "label" => "Alice Jones"}
      ]
      
      result = OptionsFormatter.normalize_to_maps(map_options)
      assert result == map_options
    end
    
    test "handles mixed legacy string with pipe format" do
      mixed_options = ["Simple", "bob | Bob Smith", "alice | Alice Jones"]
      
      result = OptionsFormatter.normalize_to_maps(mixed_options)
      expected = [
        %{"value" => "Simple", "label" => "Simple"},
        %{"value" => "bob", "label" => "Bob Smith"},
        %{"value" => "alice", "label" => "Alice Jones"}
      ]
      
      assert result == expected
    end
    
    test "handles non-string values by converting to string" do
      mixed_options = [123, :atom, {"tuple", "value"}]
      
      result = OptionsFormatter.normalize_to_maps(mixed_options)
      expected = [
        %{"value" => "123", "label" => "123"},
        %{"value" => "atom", "label" => "atom"},
        %{"value" => "{\"tuple\", \"value\"}", "label" => "{\"tuple\", \"value\"}"}
      ]
      
      assert result == expected
    end
    
    test "filters out nil values" do
      options_with_nil = [
        %{"value" => "bob", "label" => "Bob"},
        nil,
        %{"value" => "alice", "label" => "Alice"}
      ]
      
      result = OptionsFormatter.normalize_to_maps(options_with_nil)
      expected = [
        %{"value" => "bob", "label" => "Bob"},
        %{"value" => "alice", "label" => "Alice"}
      ]
      
      assert result == expected
    end
    
    test "handles empty list" do
      assert OptionsFormatter.normalize_to_maps([]) == []
    end
    
    test "handles nil input" do
      assert OptionsFormatter.normalize_to_maps(nil) == []
    end
    
    test "handles non-list input" do
      assert OptionsFormatter.normalize_to_maps("not a list") == []
    end
  end
  
  describe "static_options_to_storage/1" do
    test "converts StaticOption structs to storage format" do
      static_options = [
        %{value: "bob", label: "Bob Smith"},
        %{value: "alice", label: "Alice Jones"}
      ]
      
      result = OptionsFormatter.static_options_to_storage(static_options)
      expected = [
        %{"value" => "bob", "label" => "Bob Smith"},
        %{"value" => "alice", "label" => "Alice Jones"}
      ]
      
      assert result == expected
    end
    
    test "converts non-string values to strings" do
      static_options = [
        %{value: 123, label: :admin},
        %{value: true, label: false}
      ]
      
      result = OptionsFormatter.static_options_to_storage(static_options)
      expected = [
        %{"value" => "123", "label" => "admin"},
        %{"value" => "true", "label" => "false"}
      ]
      
      assert result == expected
    end
    
    test "handles mixed formats" do
      mixed_options = [
        %{value: "struct", label: "Struct Format"},
        %{"value" => "map", "label" => "Map Format"},
        "Simple String"
      ]
      
      result = OptionsFormatter.static_options_to_storage(mixed_options)
      expected = [
        %{"value" => "struct", "label" => "Struct Format"},
        %{"value" => "map", "label" => "Map Format"},
        %{"value" => "Simple String", "label" => "Simple String"}
      ]
      
      assert result == expected
    end
    
    test "handles nil input" do
      assert OptionsFormatter.static_options_to_storage(nil) == []
    end
    
    test "handles non-list input" do
      assert OptionsFormatter.static_options_to_storage("not a list") == []
    end
  end
  
  describe "roundtrip conversion" do
    test "simple format maintains consistency" do
      original_options = [
        %{"value" => "Bob", "label" => "Bob"},
        %{"value" => "Alice", "label" => "Alice"}
      ]
      
      display_format = OptionsFormatter.to_display_format(original_options)
      assert display_format == "Bob\nAlice"
      
      converted_back = OptionsFormatter.from_display_format(display_format)
      assert converted_back == original_options
    end
    
    test "complex format maintains consistency" do
      original_options = [
        %{"value" => "bob", "label" => "Bob Smith"},
        %{"value" => "alice", "label" => "Alice Jones"}
      ]
      
      display_format = OptionsFormatter.to_display_format(original_options)
      assert display_format == "bob | Bob Smith\nalice | Alice Jones"
      
      converted_back = OptionsFormatter.from_display_format(display_format)
      assert converted_back == original_options
    end
  end
end
defmodule Lotus.Web.SchemaBuilderTest do
  use Lotus.Web.Case, async: true

  alias Lotus.Web.SchemaBuilder

  describe "build/1" do
    test "returns schema for public schema tables" do
      result = SchemaBuilder.build(Lotus.Web.TestRepo)

      assert {:ok, schema} = result
      assert Map.has_key?(schema, "test_users")
      assert Map.has_key?(schema, "test_posts")

      assert "name" in schema["test_users"]
      assert "email" in schema["test_users"]
      assert "age" in schema["test_users"]
      assert "active" in schema["test_users"]
      assert "metadata" in schema["test_users"]
      assert "inserted_at" in schema["test_users"]
      assert "updated_at" in schema["test_users"]

      assert "title" in schema["test_posts"]
      assert "content" in schema["test_posts"]
      assert "user_id" in schema["test_posts"]
      assert "published" in schema["test_posts"]
      assert "view_count" in schema["test_posts"]
      assert "tags" in schema["test_posts"]
    end

    test "returns schema for reporting schema tables" do
      result = SchemaBuilder.build(Lotus.Web.ReportingTestRepo)

      assert {:ok, schema} = result
      assert Map.has_key?(schema, "customers")
      assert Map.has_key?(schema, "orders")

      assert "name" in schema["customers"]
      assert "email" in schema["customers"]
      assert "active" in schema["customers"]

      assert "order_number" in schema["orders"]
      assert "customer_id" in schema["orders"]
      assert "total_amount" in schema["orders"]
      assert "status" in schema["orders"]
    end

    test "returns all columns including id and timestamps" do
      result = SchemaBuilder.build(Lotus.Web.TestRepo)

      assert {:ok, schema} = result

      assert "id" in schema["test_users"]
      assert "id" in schema["test_posts"]

      assert "inserted_at" in schema["test_users"]
      assert "updated_at" in schema["test_users"]
      assert "inserted_at" in schema["test_posts"]
      assert "updated_at" in schema["test_posts"]
    end

    test "schema contains only allowed tables based on visibility rules" do
      result = SchemaBuilder.build(Lotus.Web.TestRepo)

      assert {:ok, schema} = result

      refute Map.has_key?(schema, "schema_migrations")
      refute Map.has_key?(schema, "lotus_queries")

      assert Map.has_key?(schema, "test_users")
      assert Map.has_key?(schema, "test_posts")
    end
  end
end

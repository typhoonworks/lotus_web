defmodule Lotus.Web.MarkdownTest do
  use ExUnit.Case, async: true

  alias Lotus.Web.Markdown

  defp render(text) do
    text
    |> Markdown.to_safe_html()
    |> Phoenix.HTML.safe_to_string()
  end

  describe "to_safe_html/1" do
    test "renders basic markdown formatting" do
      html = render("**bold** and _italic_")
      assert html =~ "<strong>bold</strong>"
      assert html =~ "<em>italic</em>"
    end

    test "preserves safe links" do
      html = render("[link](https://example.com)")
      assert html =~ ~s(<a href="https://example.com")
    end

    test "strips script tags" do
      html = render("<script>window.x=1</script>\n\nhello")
      refute html =~ "<script"
    end

    test "strips inline event handlers" do
      html = render(~S(<p onclick="boom">click</p>))
      refute html =~ "onclick"
    end

    test "strips javascript scheme URLs in links" do
      scheme = "javascript" <> ":"
      input = "[click](" <> scheme <> "boom)"
      html = render(input)
      refute html =~ scheme
    end

    test "strips img onerror handlers" do
      html = render(~S(<img src="x" onerror="boom">))
      refute html =~ "onerror"
    end

    test "returns empty string for non-binary input" do
      assert Markdown.to_safe_html(nil) == ""
      assert Markdown.to_safe_html(123) == ""
    end

    test "returns empty string for empty binary" do
      assert render("") == ""
    end
  end
end

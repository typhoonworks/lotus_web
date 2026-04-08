defmodule Lotus.Web.Markdown do
  @moduledoc """
  Safe markdown rendering helpers.

  Renders markdown to HTML via Earmark and sanitizes the output with
  `HtmlSanitizeEx.markdown_html/1` so that untrusted input (AI responses,
  user-entered dashboard text) cannot inject `<script>` tags, inline event
  handlers, or `javascript:` URLs.
  """

  @doc """
  Renders a markdown string to sanitized HTML, wrapped in `Phoenix.HTML.raw/1`.

  Returns an empty string for non-binary input, and the original (escaped) text
  if Earmark fails to parse it.
  """
  def to_safe_html(text) when is_binary(text) do
    case Earmark.as_html(text) do
      {:ok, html, _warnings} ->
        html
        |> HtmlSanitizeEx.markdown_html()
        |> Phoenix.HTML.raw()

      {:error, _html, _errors} ->
        text
    end
  end

  def to_safe_html(_), do: ""
end

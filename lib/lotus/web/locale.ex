defmodule Lotus.Web.Locale do
  @moduledoc false

  import Phoenix.Component, only: [assign: 3]

  def on_mount(:default, _params, session, socket) do
    session
    |> Map.get("lotus_locale")
    |> normalize_locale()
    |> case do
      nil ->
        {:cont, socket}

      locale ->
        Gettext.put_locale(Lotus.Web.Gettext, locale)
        {:cont, assign(socket, :lotus_locale, locale)}
    end
  end

  def on_mount(_hook, _params, _session, socket), do: {:cont, socket}

  defp normalize_locale(locale) when is_binary(locale) do
    locale
    |> String.trim()
    |> case do
      "" -> nil
      trimmed -> trimmed
    end
  end

  defp normalize_locale(_locale), do: nil
end

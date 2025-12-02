defmodule Lotus.Web.LocaleTest do
  use ExUnit.Case, async: true

  alias Gettext
  alias Lotus.Web.Locale
  alias Phoenix.LiveView.Socket

  setup do
    Gettext.put_locale(Lotus.Web.Gettext, "en")
    :ok
  end

  test "sets the locale from the session" do
    {:cont, socket} =
      Locale.on_mount(:default, %{}, %{"locale" => "fr"}, %Socket{assigns: %{__changed__: %{}}})

    assert Gettext.get_locale(Lotus.Web.Gettext) == "fr"
    assert socket.assigns.lotus_locale == "fr"
  end

  test "is a no-op when locale is missing" do
    socket = %Socket{assigns: %{existing: true, __changed__: %{}}}

    assert {:cont, ^socket} = Locale.on_mount(:default, %{}, %{}, socket)
    assert Gettext.get_locale(Lotus.Web.Gettext) == "en"
  end
end

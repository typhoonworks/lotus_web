defmodule Lotus.Web.Gettext do
  @moduledoc """
  Provides translation helpers for Lotus Web components.

  This backend uses the `"lotus"` domain and ships with translations for the
  supported locales in `priv/gettext/<locale>/LC_MESSAGES/lotus.po`. Updates to
  these translations (or additional locales) should be contributed via pull
  requests so that every host application benefits from the same strings.
  """

  use Gettext.Backend, otp_app: :lotus_web
end

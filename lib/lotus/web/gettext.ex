defmodule Lotus.Web.Gettext do
  @moduledoc """
  Provides translation helpers for Lotus Web components.

  This backend uses the `"lotus"` domain by default so applications that depend
  on `lotus_web` can provide their own `priv/gettext/<locale>/LC_MESSAGES/lotus.po`
  files to translate the UI strings exposed by this library.
  """

  use Gettext.Backend,
    otp_app: :lotus_web,
    default_domain: "lotus"
end

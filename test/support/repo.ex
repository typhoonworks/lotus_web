defmodule Lotus.Web.TestRepo do
  @moduledoc false

  use Ecto.Repo, otp_app: :lotus_web, adapter: Ecto.Adapters.Postgres
end

defmodule Lotus.Web.ReportingTestRepo do
  @moduledoc false

  use Ecto.Repo, otp_app: :lotus_web, adapter: Ecto.Adapters.Postgres
end

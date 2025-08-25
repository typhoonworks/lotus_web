defmodule Lotus.Web.TestRepo do
  use Ecto.Repo, otp_app: :lotus_web, adapter: Ecto.Adapters.Postgres
end

defmodule Lotus.Web.ReportingTestRepo do
  use Ecto.Repo, otp_app: :lotus_web, adapter: Ecto.Adapters.Postgres
end

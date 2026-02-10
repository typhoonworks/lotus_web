defmodule Mix.Tasks.Lotus.Gen.Dev.Secret do
  @shortdoc "Generates dev.secret.exs from template"
  @moduledoc """
  Generates dev.secret.exs from template.

  ## Examples

      $ mix lotus.gen.dev.secret           # Creates new file if it doesn't exist
      $ mix lotus.gen.dev.secret --force   # Creates new file, overwriting if it exists

  This will create a new dev.secret.exs file in the config directory
  using the template from priv/mix/templates/gen.dev.secret.ex.eex.

  ## Command line options

    * `--force` - Forces creation even if the file already exists
  """

  use Mix.Task

  @template_path "priv/mix/templates/gen.dev.secret.ex.eex"
  @output_path "config/dev.secret.exs"

  @impl Mix.Task
  def run(args) do
    {opts, _} = OptionParser.parse!(args, strict: [force: :boolean])

    cond do
      opts[:force] ->
        create_file(true)

      File.exists?(@output_path) ->
        Mix.shell().info([
          :yellow,
          "* dev.secret.exs already exists, skipping (use --force to override)"
        ])

      true ->
        create_file()
    end
  end

  defp create_file(overwrite \\ false) do
    case File.read(@template_path) do
      {:ok, template} ->
        Mix.Generator.create_file(@output_path, template, force: overwrite)
        Mix.shell().info([:green, "* created #{@output_path}"])

        Mix.shell().info([
          :cyan,
          "\nNext steps:",
          "\n  1. Edit config/dev.secret.exs with your API keys",
          "\n  2. Uncomment the AI provider you want to use",
          "\n  3. Make sure to never commit this file to git!\n"
        ])

      {:error, reason} ->
        Mix.raise("Failed to read template: #{inspect(reason)}")
    end
  end
end

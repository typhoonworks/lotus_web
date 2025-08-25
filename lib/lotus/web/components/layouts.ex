defmodule Lotus.Web.Layouts do
  @moduledoc false

  use Lotus.Web, :html

  phoenix_js_paths =
    for app <- ~w(phoenix phoenix_html phoenix_live_view)a do
      path = Application.app_dir(app, ["priv", "static", "#{app}.js"])
      Module.put_attribute(__MODULE__, :external_resource, path)
      path
    end

  @static_path Application.app_dir(:lotus_web, ["priv", "static"])

  @external_resource css_path = Path.join(@static_path, "app.css")
  @external_resource js_path = Path.join(@static_path, "app.js")

  @css File.read!(css_path)

  @js """
  #{for path <- phoenix_js_paths, do: path |> File.read!() |> String.replace("//# sourceMappingURL=", "// ")}
  #{File.read!(js_path)}
  """

  def render("app.css"), do: @css
  def render("app.js"), do: @js

  embed_templates("layouts/*")

  def logo(assigns) do
    ~H"""
    <a href={lotus_path("")} title="Lotus Web">
      <svg class="h-10 w-auto" viewBox="0 0 512 512"
      >
        <path d="M367.495 286.598C392.721 234.99 399.155 180.51 389.208 134.687C388.029 129.258 382.178 126.398 377.17 128.803C334.902 149.103 295.864 187.646 270.637 239.253C243.524 294.72 238.12 353.505 251.43 401.294C297.315 382.44 340.382 342.065 367.495 286.598Z" fill="#FFCBCE"/>
        <path d="M144.67 286.598C119.444 234.99 113.01 180.51 122.957 134.687C124.136 129.258 129.987 126.398 134.995 128.803C177.263 149.103 216.301 187.646 241.528 239.253C268.641 294.72 274.045 353.505 260.735 401.294C214.85 382.44 171.783 342.065 144.67 286.598Z" fill="#FFCBCE"/>
        <path d="M267.99 96.219L257.75 95.75C225.942 135.495 209 185.837 209 248.312C209 314.89 221.147 374.403 256.673 414.399C292.199 374.403 314.803 314.89 314.803 248.312C314.803 189.11 296.93 135.494 267.99 96.219Z" fill="#FFB3B7"/>
        <path d="M220.912 248.312C220.912 189.115 239.056 135.493 267.991 96.219C266.388 94.044 264.76 91.924 263.091 89.838C259.84 85.776 253.506 85.776 250.255 89.838C218.447 129.582 198.543 185.837 198.543 248.312C198.543 314.89 221.147 374.403 256.673 414.399C260.571 410.01 264.284 405.347 267.858 400.505C238.859 361.219 220.912 307.585 220.912 248.312Z" fill="#FF9A9F"/>
        <path d="M402.289 410.57C450.548 392.747 488.504 361.56 510.687 325.81C513.656 321.025 511.374 314.846 506.008 313.14C465.913 300.391 416.797 301.361 368.538 319.183C316.204 338.511 275.986 373.555 254.86 413.092C296.613 429.406 349.955 429.898 402.289 410.57Z" fill="#FF8086"/>
        <path d="M109.711 410.57C61.452 392.747 23.496 361.56 1.313 325.81C-1.656 321.025 0.625998 314.846 5.992 313.14C46.087 300.391 95.203 301.361 143.462 319.183C195.796 338.511 236.014 373.555 257.14 413.092C215.387 429.406 162.045 429.898 109.711 410.57Z" fill="#FF8086"/>
        <path d="M332.419 259.226C376.596 215.049 430.448 189.346 481.043 183.734C486.214 183.16 490.693 187.639 490.119 192.81C484.507 243.405 458.804 297.257 414.627 341.434C367.549 388.512 309.484 414.61 256.081 417.771L249.811 404.936L255.999 396.426C255.999 396.426 259.238 392.442 259.258 392.337C267.954 346.41 292.732 298.914 332.419 259.226Z" fill="#FF9A9F"/>
        <path d="M179.746 259.227C138.936 218.417 89.87 193.372 42.742 185.368L34.5 194C40.112 244.595 61.323 289.323 105.5 333.5C152.578 380.578 196.598 408.256 250 411.417L253.612 396.428C245.643 349.24 220.611 300.092 179.746 259.227Z" fill="#FF9A9F"/>
        <path d="M256 396.427C208.811 388.459 157.279 363.427 116.411 322.56C75.603 281.753 50.747 232.493 42.741 185.367C38.85 184.706 34.98 184.162 31.121 183.734C25.95 183.16 21.471 187.639 22.045 192.81C27.657 243.406 53.36 297.258 97.537 341.435C144.615 388.513 202.68 414.611 256.082 417.772L256 396.427Z" fill="#FF8086"/>
      </svg>
    </a>
    """
  end

  def footer(assigns) do
    assigns =
      assign(assigns,
        oss_version: Application.spec(:lotus, :vsn),
        web_version: Application.spec(:lotus_web, :vsn)
      )

    ~H"""
    <footer class="flex flex-col px-3 pb-3 text-sm justify-center items-center md:flex-row">
      <.version name="Lotus" version={@oss_version} />
      <.version name="Lotus.Web" version={@web_version} />
    </footer>
    """
  end

  attr(:name, :string)
  attr(:version, :string)

  defp version(assigns) do
    ~H"""
    <span class="text-gray-600 tabular mr-0 mb-1 md:mr-3 md:mb-0">
      {@name} {if @version, do: "v#{@version}", else: "–"}
    </span>
    """
  end
end

#  Run this script with `mix run priv/codegen/generate_codesheet.exs
in_prod = Mix.env() in [:dev, :test]

defmodule GenerateCodesheet do
  def make_one() do
    {:ok, drop} = CodeHunt.Hunting.create_code_drop()

    # TODO: make it a url with _url helper
    drop.secret_id
    |> Base.url_encode64()
    |> EQRCode.encode()
    |> EQRCode.svg(width: 175)
  end
end

template_path = Path.dirname(__ENV__.file) <> "/codesheet.html.eex"
template = File.read!(template_path)

svgs =
  Stream.repeatedly(&GenerateCodesheet.make_one/0)
  |> Enum.take(30)

EEx.eval_string(template, svgs: svgs)
|> IO.puts

#  Run this script with `mix run priv/codegen/generate_codesheet.exs

defmodule GenerateCodesheet do
  def make_one() do
    :crypto.strong_rand_bytes(33)
    |> Base.url_encode64()
    |> EQRCode.encode()
    |> EQRCode.svg(width: 175)
    # TODO: add to the database
  end
end

template_path = Path.dirname(__ENV__.file) <> "/codesheet.html.eex"
template = File.read!(template_path)

svgs =
  Stream.repeatedly(&GenerateCodesheet.make_one/0)
  |> Enum.take(30)

EEx.eval_string(template, svgs: svgs)
|> IO.puts

#  Run this script with `mix run priv/codegen/generate_codesheet.exs`

defmodule GenerateCodesheet do
  def make_one() do
    drop = CodeHunt.Hunting.create_code_drop!()

    encoded = Base.url_encode64(drop.secret_id)

    CodeHuntWeb.Router.Helpers.code_drop_url(CodeHuntWeb.Endpoint, :claim, encoded)
    |> IO.inspect()
    |> EQRCode.encode()
    |> EQRCode.svg(width: 175)
  end
end

dir = Path.dirname(__ENV__.file)
output_file = dir <> "/sheet.html"
false = File.exists?(output_file)
template_path = dir <> "/codesheet.html.eex"
template = File.read!(template_path)

svgs =
  Stream.repeatedly(&GenerateCodesheet.make_one/0)
  |> Enum.take(30)

generated = EEx.eval_string(template, svgs: svgs)
File.write!(output_file, generated)

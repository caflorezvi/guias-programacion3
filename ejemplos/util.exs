defmodule Util do

  def leer(mensaje, :string) do
    IO.gets(mensaje)
    |> String.trim()
  end

  def leer(mensaje, :integer) do
    leer_con_parser(mensaje, fn valor -> Integer.parse(valor) end)
  end

  def leer(mensaje, :float) do
    leer_con_parser(mensaje, &Float.parse/1)
  end

  defp leer_con_parser(mensaje, parser) do
    valor = IO.gets(mensaje)
    |> String.trim()
    |> parser.()

    case valor do
      {numero, _} -> numero
      :error ->
        imprimir_error("El valor ingresado no es válido.")
        leer_con_parser(mensaje, parser)
    end
  end

  def imprimir_error(mensaje) do
    IO.puts(:standard_error, mensaje)
  end

  def imprimir(mensaje) do
    IO.puts(mensaje)
  end

end

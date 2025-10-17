defmodule Cadenas do

  def invertir(""), do: ""

  def invertir(cadena) do
    cadena_restante = String.slice(cadena, 0..-2//1) # Obtener la cadena sin el último carácter
    |> invertir()

     String.last(cadena) <> cadena_restante # Concatenar el último carácter con la cadena invertida
  end

  def main do
    invertir("hola a todos")
    |> IO.puts()
  end
end

Cadenas.main()

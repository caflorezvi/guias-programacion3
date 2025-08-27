defmodule Cadenas do

  def invertir(""), do: ""

  def invertir(cadena) do
    ultimo_caracter = String.at(cadena, -1) # Obtener el último carácter
    cadena_restante = String.slice(cadena, 0..-2//1) # Obtener la cadena sin el último carácter
    |> invertir()

    ultimo_caracter <> cadena_restante # Concatenar el último carácter con la cadena invertida
  end
end

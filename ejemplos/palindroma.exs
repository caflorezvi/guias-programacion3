defmodule Palindroma do

  def main do
    Util.leer("Ingrese una cadena: ", :string)
    |> es_palindroma_v2?()
    |> generar_mensaje()
    |> Util.imprimir_mensaje()

  end

  def es_palindroma?(cadena) do
    cadena
    |> String.replace(" ", "")
    |> String.downcase()
    |> then(fn cadena -> cadena == String.reverse(cadena) end )
  end

  def es_palindroma_v2?(cadena) do
    cadena
    |> String.replace(" ", "")
    |> String.downcase()
    |> then(&(&1 == String.reverse(&1)))
  end

  def generar_mensaje(es_palindroma) do
    if es_palindroma do
      "La cadena es palíndroma"
    else
      "La cadena no es palíndroma"
    end
  end

end

Palindroma.main

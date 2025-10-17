defmodule Palindroma do
  @moduledoc """
  Módulo para verificar si una cadena es un palíndromo. Se presentan
  varias versiones de la función es_palindroma?/1.
  - autor: Carlos Andrés Florez V
  - fecha: Agosto 2025
  """

  def main do
    Util.leer("Ingrese una cadena: ", :string)
    |> es_palindroma_v2?()
    |> generar_mensaje()
    |> Util.imprimir()

  end

  @doc """
  Verifica si una cadena de texto es un palíndromo o no. La función
  es_palindroma_v1?/1 utiliza un enfoque imperativo.
  """
  defp es_palindroma_v1?(cadena_texto) do
    cadena_tratada = String.downcase(cadena_texto) # Convierte a minúsculas
    |> String.replace(" ", "") # Elimina espacios

    String.reverse(cadena_tratada) == cadena_tratada # Compara la cadena original con la invertida
  end

  @doc """
  Verifica si una cadena de texto es un palíndromo o no. La función
  es_palindroma_v2?/1 utiliza un enfoque funcional ya que se basa en
  la composición de funciones usando pipes.
  """
  defp es_palindroma_v2?(cadena) do
    cadena
    |> String.replace(" ", "") # Elimina espacios
    |> String.downcase() # Convierte a minúsculas
    |> then(fn cadena -> cadena == String.reverse(cadena) end ) # Compara la cadena original con la invertida
  end

  @doc """
  Verifica si una cadena de texto es un palíndromo o no. La función
  es_palindroma_v3?/1 utiliza un enfoque funcional más conciso.
  """
  defp es_palindroma_v3?(cadena) do
    cadena
    |> String.replace(" ", "")
    |> String.downcase()
    |> then(&(&1 == String.reverse(&1))) # Compara la cadena original con la invertida
  end

  defp generar_mensaje(es_palindroma) do
    if es_palindroma do
      "La cadena es palíndroma"
    else
      "La cadena no es palíndroma"
    end
  end

end

Palindroma.main()

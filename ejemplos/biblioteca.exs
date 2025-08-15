defmodule Biblioteca do
  def main do
    leer_nombre()
    |> saludar()
    |> imprimir_mensaje()
  end

  defp saludar(nombre) do
    "Hola #{nombre}, Bienvenido al sistema de la Biblioteca Central"
  end

  defp imprimir_mensaje(mensaje) do
    IO.puts(mensaje)
  end

  defp leer_nombre do
    IO.gets("Por favor, ingrese su nombre: ")
    |> String.trim()
  end
end

Biblioteca.main()

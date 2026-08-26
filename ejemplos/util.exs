defmodule Util do

  def leer(mensaje, :string) do
    IO.gets(mensaje)
    |> String.trim()
  end

  def leer(mensaje, :integer) do
    leer_con_parser(mensaje, &Integer.parse/1) # Se pasa la función de parseo
  end

  def leer(mensaje, :float) do
    leer_con_parser(mensaje, &Float.parse/1)
  end

  defp leer_con_parser(mensaje, funcion) do
    valor = IO.gets(mensaje)
    |> String.trim()
    |> funcion.() # Se ejecuta la función de parseo

    case valor do
      {numero, _} -> numero
      :error ->
        imprimir_error("El valor ingresado no es válido.")
        leer_con_parser(mensaje, funcion) # Se vuelve a preguntar hasta recibir un valor válido
    end
  end

  def imprimir_error(mensaje) do
    IO.puts(:standard_error, mensaje)
  end

  def imprimir_mensaje(mensaje) do
    IO.puts(mensaje)
  end

end

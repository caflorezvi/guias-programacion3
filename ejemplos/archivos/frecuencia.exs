defmodule Frecuencia do
  @moduledoc """
  Lee un archivo de texto, cuenta la frecuencia de cada palabra y escribe los resultados en otro archivo.
  - Autor: Carlos Andres Florez
  - Fecha: Octubre 2025
  """

  @input Path.join(__DIR__, "data.txt")
  @output Path.join(__DIR__, "frecuencia.txt")

  def main do
    File.read(@input)
    |> contar_frecuencia()
    |> escribir(@output)
    |> mostrar_resultado()
  end

  defp contar_frecuencia({:ok, contenido}) do
    respuesta = String.downcase(contenido)
    |> String.split()
    |> Enum.frequencies()
    |> Enum.map_join("\n", fn {palabra, frecuencia} -> "#{palabra}: #{frecuencia}" end)

    {:ok, respuesta}
  end

  defp contar_frecuencia({:error, razon}), do: {:error, "Error al leer el archivo: #{razon}"}

  defp escribir({:ok, contenido}, archivo) do
    case File.write(archivo, contenido) do
      :ok -> {:ok, "Frecuencia escrita en #{archivo}"}
      {:error, razon} -> {:error, "Error al escribir en #{archivo}: #{razon}"}
    end
  end

  defp escribir({:error, mensaje}, _archivo), do: {:error, mensaje}

  defp mostrar_resultado({:ok, mensaje}), do: IO.puts(mensaje)
  defp mostrar_resultado({:error, mensaje}), do: IO.puts(:standard_error, mensaje)

end

Frecuencia.main()

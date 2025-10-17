defmodule Frecuencia do
  @moduledoc """
  Lee un archivo de texto, cuenta la frecuencia de cada palabra y escribe los resultados en otro archivo.
  - Autor: Carlos Andres Florez
  - Fecha: Octubre 2025
  """

  @input "data.txt"
  @output "frecuencia.txt"

  def main do
    File.read(@input)
    |> contar_frecuencia()
    |> escribir(@output)
    |> IO.puts()
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
      :ok -> "Frecuencia escrita en #{archivo}"
      {:error, razon} -> "Error al escribir en #{archivo}: #{razon}"
    end
  end

  defp escribir({:error, contenido}, _archivo), do: contenido

end

Frecuencia.main()

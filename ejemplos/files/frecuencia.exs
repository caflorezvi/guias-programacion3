defmodule Frecuencia do

  @input "data.txt"
  @output "frecuencia.txt"

  def main do
    File.read(@input)
    |> contar_frecuencia()
    |> escribir(@output)
    |> IO.puts()

  end

  def contar_frecuencia({:ok, contenido}) do
    respuesta = String.downcase(contenido)
    |> String.split()
    |> Enum.frequencies()
    |> Enum.map( fn {palabra, frecuencia} -> "#{palabra}: #{frecuencia}" end)
    |> Enum.join("\n")
    {:ok, respuesta}
  end

  def contar_frecuencia({:error, razon}), do: {:error, "Error al leer el archivo: #{razon}"}

  def escribir({:ok, contenido}, archivo) do
    case File.write(archivo, contenido) do
      :ok -> "Frecuencia escrita en #{archivo}"
      {:error, razon} -> "Error al escribir en #{archivo}: #{razon}"
    end
  end

  def escribir({:error, contenido}, _archivo), do: contenido

end

Frecuencia.main()

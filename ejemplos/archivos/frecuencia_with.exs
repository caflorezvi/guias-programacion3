defmodule Frecuencia do
  @input "data.txt"
  @output "frecuencia.txt"

  def main do
    # with para manejar múltiples operaciones que pueden fallar
    with {:ok, contenido} <- File.read(@input),
         {:ok, resultado} <- contar_frecuencia(contenido),
         :ok <- File.write(@output, resultado) do
      IO.puts("Frecuencia escrita en #{@output}")
    else
      {:error, razon} ->
        IO.puts("Error: #{razon}")
    end
  end

  def contar_frecuencia(contenido) when is_binary(contenido) do
    resultado = String.downcase() # Convertir a minúsculas
    |> String.split() # Dividir en palabras
    |> Enum.frequencies() # Contar frecuencias
    |> Enum.map_join("\n", fn {palabra, frecuencia} -> "#{palabra}: #{frecuencia}" end) # Formatear resultado y unir en una cadena de texto

    {:ok, resultado}
  end
end

Frecuencia.main()

defmodule Frecuencia do
  @input "data.txt"
  @output "frecuencia.txt"

  def main do
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
    resultado =
      contenido
      |> String.downcase()
      |> String.split()
      |> Enum.frequencies()
      |> Enum.map_join("\n", fn {palabra, frecuencia} ->
        "#{palabra}: #{frecuencia}"
      end)

    {:ok, resultado}
  end
end

Frecuencia.main()

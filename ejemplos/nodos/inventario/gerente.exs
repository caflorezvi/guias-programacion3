defmodule Gerente do
  @sedes [:sede_armenia@localhost, :sede_pereira@localhost, :sede_manizales@localhost]

  def main do
    case Node.start(:gerente@localhost, :shortnames) do
      {:ok, _} ->
        IO.gets("Producto: ")
        |> String.trim()
        |> String.downcase()
        |> consultar_sedes()

      {:error, _} ->
        IO.puts("No se pudo iniciar el nodo. Verifique que epmd esté corriendo y que el nombre no esté en uso")
    end
  end

  # Llama a Sede.consultar/1 en todas las sedes a la vez
  defp consultar_sedes(producto) do
    {resultados, sedes_caidas} = :rpc.multicall(@sedes, Sede, :consultar, [producto])

    IO.puts("\nExistencias de #{producto}:")
    Enum.each(resultados, fn {sede, cantidad} -> IO.puts("  #{sede}: #{cantidad}") end)
    Enum.each(sedes_caidas, fn sede -> IO.puts("  #{sede}: sin respuesta") end)

    IO.puts("Total: #{total(resultados)} unidades")
  end

  # Solo suman los resultados que trajeron un número
  defp total(resultados) do
    resultados
    |> Enum.map(fn {_sede, cantidad} -> cantidad end)
    |> Enum.filter(&is_integer/1)
    |> Enum.sum()
  end
end

Gerente.main()

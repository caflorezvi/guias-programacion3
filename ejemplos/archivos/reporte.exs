defmodule Reporte do
  @log Path.join(__DIR__, "servidor.log")
  @salida Path.join(__DIR__, "reporte.txt")

  def main do
    analizar(@log, @salida)
    |> mostrar_resultado()
  end

  defp analizar(ruta_log, ruta_reporte) do
    if File.exists?(ruta_log) do
      ruta_log
      |> contar_por_nivel()
      |> generar_texto()
      |> guardar(ruta_reporte)
    else
      {:error, :enoent}
    end
  end

  defp contar_por_nivel(ruta) do
    ruta
    |> File.stream!()                  # Produce las líneas una por una
    |> Enum.frequencies_by(&nivel/1)   # Cuenta cuántas hay de cada nivel
  end

  # Función pura: recibe el conteo y devuelve el texto del reporte
  defp generar_texto(conteo) do
    lineas =
      conteo
      |> Enum.map(fn {nivel, cantidad} -> "#{nivel}: #{cantidad}" end)
      |> Enum.join("\n")

    """
    === Eventos por nivel ===
    #{lineas}
    """
  end

  # El nivel de severidad es la tercera palabra de la línea, después de la fecha y la hora
  defp nivel(linea) do
    linea
    |> String.split()
    |> Enum.at(2)
  end

  # Efecto secundario aislado: escribir en disco
  defp guardar(texto, ruta) do
    case File.write(ruta, texto) do
      :ok -> {:ok, "Reporte generado en #{ruta}"}
      {:error, razon} -> {:error, razon}
    end
  end

  defp mostrar_resultado({:ok, mensaje}), do: IO.puts(mensaje)
  defp mostrar_resultado({:error, razon}), do: IO.puts("Error: #{razon}")
end

Reporte.main()

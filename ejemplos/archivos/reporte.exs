defmodule Reporte do
  @log Path.join(__DIR__, "servidor.log")
  @salida Path.join(__DIR__, "reporte.txt")

  def main do
    analizar(@log, @salida)
    |> mostrar_resultado()
  end

  defp analizar(ruta_log, ruta_reporte) do
    if File.exists?(ruta_log) do
      fecha = fecha_actual()

      ruta_log
      |> File.stream!()        # Produce las líneas una por una
      |> contar_por_nivel()
      |> generar_texto(fecha)
      |> guardar(ruta_reporte)
    else
      {:error, :enoent}
    end
  end

  # Recibe las líneas, sin importar si vienen de una lista o de un stream
  defp contar_por_nivel(lineas) do
    Enum.frequencies_by(lineas, &nivel/1)   # Cuenta cuántas hay de cada nivel
  end

  # Función impura: cada llamada devuelve un valor distinto
  defp fecha_actual do
    DateTime.utc_now()
    |> DateTime.add(-5 * 60 * 60, :second)   # Hora de Colombia (UTC-5)
    |> Calendar.strftime("%A %d/%m/%Y %H:%M:%S")
  end

  # Función pura: recibe el conteo y la fecha, y devuelve el texto del reporte
  defp generar_texto(conteo, fecha) do
    total = conteo |> Map.values() |> Enum.sum()   # Suma las cantidades de todos los niveles

    detalle =
      conteo
      |> Enum.map(fn {nivel, cantidad} -> "#{nivel}: #{cantidad}" end)
      |> Enum.join("\n")

    """
    === Eventos por nivel ===
    Generado: #{fecha}
    Líneas totales: #{total}
    #{detalle}
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
  defp mostrar_resultado({:error, razon}), do: IO.puts(:standard_error, "Error: #{razon}")
end

Reporte.main()

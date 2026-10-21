defmodule Anonimizador do
  @carpeta __DIR__
  @salida Path.join(__DIR__, "publicos")

  def main do
    case File.mkdir_p(@salida) do   # Crea la carpeta destino si no existe
      :ok -> anonimizar_carpeta(@carpeta)
      {:error, razon} -> IO.puts("No se pudo crear la carpeta publicos: #{razon}")
    end
  end

  defp anonimizar_carpeta(carpeta) do
    carpeta
    |> listar_logs()
    |> Enum.each(&anonimizar_archivo/1)
  end

  defp listar_logs(carpeta) do
    carpeta
    |> File.ls!()
    |> Enum.filter(&(Path.extname(&1) == ".log"))   # Solo los archivos .log
    |> Enum.sort()
  end

  defp anonimizar_archivo(nombre) do
    @carpeta
    |> Path.join(nombre)
    |> anonimizar(Path.join(@salida, nombre))
    |> mostrar_resultado(nombre)
  end

  defp anonimizar(entrada, salida) do
    if File.exists?(entrada) do
      entrada
      |> File.stream!()                                  # Lee línea por línea
      |> Stream.map(&ocultar_usuarios/1)                 # Transforma cada línea
      |> Enum.into(File.stream!(salida, [:write]))       # Escribe línea por línea

      :ok
    else
      {:error, "el archivo no existe"}
    end
  end

  defp ocultar_usuarios(linea) do
    String.replace(linea, ~r/Usuario \w+/, "Usuario ***")
  end

  defp mostrar_resultado(:ok, nombre), do: IO.puts("Anonimizado: #{nombre} -> publicos/#{nombre}")
  defp mostrar_resultado({:error, motivo}, nombre), do: IO.puts("No se pudo anonimizar #{nombre}: #{motivo}")
end

Anonimizador.main()

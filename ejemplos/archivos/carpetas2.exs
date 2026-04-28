defmodule InformeDirectorio do
  def generar(ruta) do
    archivos = File.ls!(ruta)

    detalles =
      Enum.map(archivos, fn nombre ->
        path = Path.join(ruta, nombre)
        stat = File.stat!(path)

        cond do
          stat.type == :directory ->
            %{tipo: :dir, nombre: nombre <> "/", tam: 0}

          stat.type == :regular ->
            %{tipo: :file, nombre: nombre, tam: stat.size}

          true ->
            %{tipo: :otro, nombre: nombre, tam: 0}
        end
      end)

    total_archivos = Enum.count(detalles, &(&1.tipo == :file))
    total_dirs = Enum.count(detalles, &(&1.tipo == :dir))
    tam_total = Enum.reduce(detalles, 0, fn d, acc -> acc + d.tam end)

    fecha =
      DateTime.utc_now()
      |> DateTime.to_string()

    contenido =
      [
        "=== Informe del Directorio #{ruta} ===",
        "Generado: #{fecha}",
        ""
        | Enum.map(detalles, fn d ->
            case d.tipo do
              :dir ->
                "[DIR]  #{d.nombre}"

              :file ->
                "[FILE] #{String.pad_trailing(d.nombre, 15)} (#{d.tam} bytes)"

              _ ->
                "[OTHER] #{d.nombre}"
            end
          end)
      ]
      |> Enum.join("\n")

    contenido =
      contenido <>
        "\n\nTotal: #{total_archivos} archivos, #{total_dirs} directorios\n" <>
        "Tamaño total: #{tam_total} bytes\n"

    File.write!("informe.txt", contenido)

    IO.puts("Informe generado correctamente en informe.txt")
  end
end

InformeDirectorio.generar("../archivos")

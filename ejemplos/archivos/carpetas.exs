defmodule Carpetas do
  def main do
    # Lista los archivos y carpetas en el directorio actual
    {_, lista} = File.ls(".")

    info =
      Enum.map(lista, fn nombre_archivo ->
        # Obtiene la información del archivo usando File.stat (que tine el tamaño y tipo del archivo)
        {_, %File.Stat{size: size, type: type}} = File.stat(nombre_archivo)
        # Retorna una tupla con el nombre, tipo y tamaño
        {nombre_archivo, type, size}
      end)
      |> Enum.filter(fn {_nombre, type, _size} -> type == :regular end) # Filtra solo los archivos regulares (no carpetas)

    # Imprimimos para ver el resultado
    IO.inspect(info)
  end
end

Carpetas.main()

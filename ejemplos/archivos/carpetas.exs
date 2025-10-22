defmodule Carpetas do
  def main do
    {_, lista} = File.ls(".")

    info =
      Enum.map(lista, fn nombre_archivo ->
        {_, %File.Stat{size: size, type: type}} = File.stat(nombre_archivo)
        {nombre_archivo, type, size}
      end)
      |> Enum.filter(fn {_nombre, type, _size} -> type == :regular end)

    IO.inspect(info)
  end
end

Carpetas.main()

defmodule Inventario do
  @moduledoc """
  Módulo para procesar un inventario de productos desde un archivo CSV.
  Calcula el valor total del inventario multiplicando el precio por la cantidad de cada producto
  y sumando estos valores. El archivo CSV debe tener el formato: nombre,precio,cantidad.
  - Autor: Carlos Andres Florez
  - Fecha: Octubre 2025
  """

  @input "productos.csv"

  def main do
    File.stream!(@input) # Abrir el archivo como un stream
    |> Stream.drop(1) # Omitir la primera línea (encabezado), sigue siendo un stream
    |> Stream.map( &(convertir_linea(&1)) ) # Convertir cada línea a un mapa de producto, sigue siendo un stream
    |> Enum.reduce(0, fn %{precio: precio, cantidad: cantidad}, acc -> precio*cantidad + acc end) # Calcular el valor total, se procesa línea por línea
    |> IO.puts()
  end

  defp convertir_linea(linea) do
    [nombre, precio, cantidad] = String.trim(linea) |> String.split(",")

    {precio_num, _} = Integer.parse(precio)
    {cantidad_num, _} = Integer.parse(cantidad)

    %{nombre: nombre, precio: precio_num, cantidad: cantidad_num }
  end

end

Inventario.main()

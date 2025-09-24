defmodule Tienda do
  @moduledoc """
  Ejemplos de operaciones con listas y mapas en Elixir - Tienda
  """

  def main do

    lista = [
      %{id: 1, nombre: "TV", precio: 150000, stock: 1, categoria: "Tecnología"},
      %{id: 2, nombre: "PC", precio: 250000, stock: 5, categoria: "Tecnología"},
      %{id: 3, nombre: "Agua", precio: 2000, stock: 0, categoria: "Otro"},
      %{id: 4, nombre: "Reloj caro", precio: 3000, stock: 2, categoria: "Accesorios"},
      %{id: 5, nombre: "Reloj barato", precio: 2000, stock: 5, categoria: "Accesorios"}
    ]

    #Total del inventario
    total = calcular_inventario_total(lista)
    Util.imprimir("La suma total es #{total}")

    #Lista productos sin stock
    sin_stock = listar_productos_sin_stock(lista)
    Util.imprimir("Los productos sin stock son #{Enum.join(sin_stock, ", ")}")

    #Lista productos por categoria (Accesorios) ordenados por precio
    productos_accesorios = listar_productos_categoria(lista, "Accesorios")
    IO.inspect(productos_accesorios)

    #Producto más caro y más barato
    { mas_barato, mas_caro } = obtener_producto_caro_barato(lista)
    IO.inspect(mas_barato)
    IO.inspect(mas_caro)

    #Agrupar productos por categoría
    agrupados = agrupar_por_categoria(lista)
    IO.inspect(agrupados)

    #Contar productos por categoría
    conteo = contar_por_categoria(lista)
    IO.inspect(conteo)

    #Promedio de precio por categoría
    promedios = obtener_promedio_precio_categorias(lista)
    IO.inspect(promedios)

  end

  defp calcular_inventario_total(lista), do: Enum.reduce(lista, 0, fn a, b -> a.precio*a.stock + b end )

  defp listar_productos_sin_stock(lista) do
    Enum.filter(lista, &(&1.stock == 0))
    |> Enum.map(&(&1.nombre)) # Solo nos interesa el nombre de cada producto
  end

  defp listar_productos_categoria(lista, categoria) do
    Enum.filter(lista, &(&1.categoria == categoria))
    |> Enum.sort_by(&(&1.precio)) # Ordenamos por precio (por defecto ascendente)
  end

  defp obtener_producto_caro_barato([primer | resto]) do
    {min, max} =
      Enum.reduce(resto, {primer, primer}, fn prod, {min, max} -> # Inicializamos min y max con el primer producto
        nuevo_min = if prod.precio < min.precio, do: prod, else: min # Comparamos y actualizamos min
        nuevo_max = if prod.precio > max.precio, do: prod, else: max # Comparamos y actualizamos max
        {nuevo_min, nuevo_max} # Devolvemos la nueva tupla {min, max}
      end)

    tupla_barato = {:mas_barato, min.nombre, min.precio}
    tupla_caro = {:mas_caro, max.nombre, max.precio}

    {tupla_barato, tupla_caro}
  end

  defp agrupar_por_categoria(lista), do: Enum.group_by(lista, &(&1.categoria))

  defp contar_por_categoria(lista) do
    Enum.group_by(lista, &(&1.categoria)) # Agrupamos por categoría
    |> Enum.map( fn {cat, lista} -> {cat, Enum.count(lista)} end ) # Contamos los elementos de cada categoría
    |> Enum.into(%{}) # Convertimos la lista de tuplas en un mapa
  end

  defp obtener_promedio_precio_categorias(lista) do
    lista
    |> Enum.group_by(& &1.categoria, & &1.precio) # Agrupamos por categoría, pero solo obtenemos los precios
    |> Enum.map(fn {cat, precios} ->
      {suma, count} = Enum.reduce(precios, {0, 0}, fn p, {suma, count} -> {suma + p, count + 1} end) # Sumamos y contamos los precios
      {cat, suma / count} # Calculamos el promedio
    end)
    |> Enum.into(%{})
  end

end

Tienda.main()

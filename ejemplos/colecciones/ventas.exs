defmodule Ventas do
  def main do
    ventas = ventas_del_dia()

    IO.puts("Ingreso del día: #{calcular_ingreso_total(ventas)}")

    obtener_categorias_unicas(ventas) |> IO.inspect(label: "Categorías")
    agrupar_productos_por_categoria(ventas) |> IO.inspect(label: "Productos por categoría")
    contar_ventas_por_categoria(ventas) |> IO.inspect(label: "Ventas por categoría")
    calcular_ingreso_por_categoria(ventas) |> IO.inspect(label: "Ingreso por categoría")

    IO.puts("¿Alguna venta de más de 4 unidades? #{hay_venta_alta?(ventas)}")
    IO.puts("¿Todas las ventas son válidas? #{ventas_validas?(ventas)}")

    buscar_primera_venta_categoria(ventas, "Bebidas")
    |> IO.inspect(label: "Primera venta de Bebidas")

    buscar_primera_venta_categoria(ventas, "Lácteos")
    |> IO.inspect(label: "Primera venta de Lácteos")
  end

  # Se separan los datos de la lógica: main no necesita saber de dónde salen las ventas
  defp ventas_del_dia do
    [
      %{producto: "Café", categoria: "Bebidas", cantidad: 3, precio: 4000},
      %{producto: "Té", categoria: "Bebidas", cantidad: 1, precio: 3500},
      %{producto: "Jugo", categoria: "Bebidas", cantidad: 6, precio: 5000},
      %{producto: "Pan", categoria: "Panadería", cantidad: 5, precio: 2000},
      %{producto: "Croissant", categoria: "Panadería", cantidad: 2, precio: 4500},
      %{producto: "Torta", categoria: "Panadería", cantidad: 1, precio: 25000},
      %{producto: "Galleta", categoria: "Panadería", cantidad: 3, precio: 1500}
    ]
  end

  # El acumulador inicia en 0 y en cada paso se le suma el valor de la venta actual
  defp calcular_ingreso_total(ventas) do
    Enum.reduce(ventas, 0, fn venta, acc -> acc + venta.cantidad * venta.precio end)
  end

  # Categorías sin repetir (Enum.uniq elimina los repetidos conservando el orden)
  defp obtener_categorias_unicas(ventas) do
    ventas
    |> Enum.map(fn venta -> venta.categoria end)
    |> Enum.uniq()
  end

  # El tercer argumento indica qué guardar en cada grupo (el producto, no el mapa completo)
  defp agrupar_productos_por_categoria(ventas) do
    Enum.group_by(ventas, fn venta -> venta.categoria end, fn venta -> venta.producto end)
  end

  defp contar_ventas_por_categoria(ventas) do
    Enum.frequencies_by(ventas, fn venta -> venta.categoria end)
  end

  # Enum.reduce junto con Map.update/4 es el patrón habitual para acumular dentro de un mapa
  defp calcular_ingreso_por_categoria(ventas) do
    Enum.reduce(ventas, %{}, fn venta, acc ->
      valor = venta.cantidad * venta.precio
      Map.update(acc, venta.categoria, valor, fn total -> total + valor end)
    end)
  end

  defp hay_venta_alta?(ventas) do
    Enum.any?(ventas, fn venta -> venta.cantidad > 4 end)
  end

  defp ventas_validas?(ventas) do
    Enum.all?(ventas, fn venta -> venta.cantidad > 0 end)
  end

  # Enum.find devuelve nil si ninguna venta coincide
  defp buscar_primera_venta_categoria(ventas, categoria) do
    Enum.find(ventas, fn venta -> venta.categoria == categoria end)
  end
end

Ventas.main()

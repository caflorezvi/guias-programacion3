defmodule Producto do
  defstruct [:nombre, :precio, :cantidad]
end

defmodule Inventario do
  def main do
    productos = %{}

    productos = agregar_producto(productos, "A1A72727", "Manzanas", 1.5, 100)
    productos = agregar_producto(productos, "B2B83838", "Bananas", 0.8, 150)
    productos = agregar_producto(productos, "AT929NBM", "tVT1", 2.5, 150)
    productos = agregar_producto(productos, "98222HAH", "tVT2", 1.8, 150)
    productos = agregar_producto(productos, "HAGL9821", "tVT3", 250000, 150)

    filtrar_nombre_vocales(productos)
    |> IO.inspect()

    filtrar_nombre_letra(productos)
    |> IO.inspect()

    listar_tres_caros(productos)
    |> IO.inspect()

    filtrar_productos_rango(productos, 0, 3)
    |> IO.puts()

    crear_reporte(productos)
    |> IO.inspect()

  end

  def agregar_producto(productos, codigo, nombre, precio, cantidad) do

    errores = [
      if(Map.has_key?(productos, codigo), do: "Ya existe un producto con el código #{codigo}", else: nil),
      if(String.length(codigo) < 5, do: "El código debe tener al menos 5 caracteres", else: nil),
      if(cantidad < 0 or not is_integer(cantidad), do: "La cantidad debe ser un número entero no negativo", else: nil),
      if(precio < 0, do: "El precio debe ser un número no negativo", else: nil)
    ]
    |> Enum.filter(& &1) # Eliminar los nil

    # Si la lista de errores está vacía, agregamos el producto
    case errores do
      [] ->
        producto = %Producto{nombre: nombre, precio: precio, cantidad: cantidad}
        Map.put(productos, codigo, producto)
      _ ->
        {:error, Enum.join(errores, ", ")}
    end

  end

  def filtrar_nombre_vocales(productos) do
    Enum.filter(productos, fn {_key, %Producto{nombre: nombre}} ->
      String.downcase(nombre)
      |> String.graphemes()
      |> Enum.filter(fn char -> char in ["a", "e", "i", "o", "u"] end)
      |> length()
      |> then( fn total -> total>2 end)
    end)
    |> Enum.map( fn {key, %Producto{nombre: nombre}} -> {key, nombre} end )
  end

  def filtrar_nombre_letra(productos) do
    Enum.filter(productos, fn {_key, %Producto{nombre: nombre}} ->
      String.downcase(nombre)
      |> then( fn n -> String.first(n) == String.last(n) end )
    end)
  end

  def listar_tres_caros(productos) do
    Enum.sort_by(productos, fn {_key, %Producto{precio: precio}} -> precio end, :desc )
    |> Enum.take(3)
  end

  def filtrar_productos_max(productos, precio_max) do
    Enum.filter(productos, fn {_key, prod} -> prod.precio < precio_max end)
  end

  def filtrar_productos_rango(productos, precio_min, precio_max) do
    Enum.filter(productos, fn {_key, prod} -> prod.precio > precio_min and prod.precio < precio_max end)
    |> Enum.map(fn {_key, prod} -> "Nombre: #{prod.nombre} precio: #{prod.precio}" end)
    |> Enum.join(", ")
  end

  def crear_reporte(productos) do

    Enum.reduce(productos, {[], [], []}, fn {_key, prod}, {lista1, lista2, lista3} ->
      cond do
        prod.precio < 50000 -> {[prod | lista1], lista2, lista3}
        prod.precio <= 100000 -> {lista1, [prod | lista2], lista3}
        true -> {lista1, lista2, [prod | lista3]}
      end
    end )


  end

end

Inventario.main()

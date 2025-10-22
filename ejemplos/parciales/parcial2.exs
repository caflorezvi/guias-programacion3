defmodule Vehiculo do
  defstruct [:marca, :modelo, :kilometraje, :servicios]
end

defmodule Taller do
  def main do
    inventario = %{
      "ABC123" => %Vehiculo{
        marca: "Toyota",
        modelo: 2020,
        kilometraje: 50000,
        servicios: [{"Cambio de aceite", 150_000}, {"Frenos", 300_000}, {"Llantas", 900_000}]
      },
      "XYZ789" => %Vehiculo{
        marca: "Mazda",
        modelo: 2018,
        kilometraje: 120_000,
        servicios: [{"Llantas", 900_000}]
      },
      "MNO621" => %Vehiculo{marca: "Honda", modelo: 2025, kilometraje: 8000, servicios: []}
    }

    IO.inspect(obtener_por_mantenimiento(inventario))
    IO.inspect(agregar_servicio(inventario, "MNO", "Bateria", 500_000))
    IO.inspect(agrupar_rango_km(inventario))
    IO.inspect(obtener_servicios_comunes(inventario))
  end

  def agregar_servicio(inventario, placa, nombre_servicio, precio_servicio) do
    case Map.get(inventario, placa) do
      nil ->
        {:error, "Vehículo no encontrado"}
      %Vehiculo{} = vehiculo ->
        actualizado = %Vehiculo{vehiculo | servicios: [{nombre_servicio, precio_servicio} | vehiculo.servicios] }
        Map.put(inventario, placa, actualizado)
    end
  end

  def obtener_por_mantenimiento(inventario) do
    Enum.map(inventario, fn {placa, %Vehiculo{servicios: lista}} ->
      {placa, Enum.sum_by(lista, fn {_nombre, precio} -> precio end)}
    end)
    |> Enum.sort_by(fn {_placa, total} -> total end, :desc)
    |> Enum.take(3)
    |> Enum.map(fn {placa, total} ->
      "Placa: #{placa} - Total: #{total}"
    end)
    |> Enum.join(", ")
  end

  def agrupar_rango_km(productos) do
    {menores, intermedio, mayores} =
      Enum.reduce(productos, {%{}, %{}, %{}}, fn {placa, vehiculo}, {m1, m2, m3} ->
        cond do
          vehiculo.kilometraje < 50_000 -> {Map.put(m1, placa, vehiculo), m2, m3}
          vehiculo.kilometraje <= 100_000 -> {m1, Map.put(m2, placa, vehiculo), m3}
          true -> {m1, m2, Map.put(m3, placa, vehiculo)}
        end
      end)

    %{"menores" => menores, "intermedio" => intermedio, "mayores" => mayores}
  end

  def obtener_servicios_comunes(inventario) do
    Enum.flat_map(inventario, fn {_placa, %Vehiculo{servicios: servicios}} -> servicios end)
    |> Enum.frequencies_by(fn {nombre, _precio} -> nombre end)
    |> Enum.sort_by(fn {_servicio, cantidad} -> cantidad end, :desc)
  end

end

defmodule ListaSinVocales do
  # Función principal. Recorre cada palabra de la lista y crea una nueva
  def crear_lista([]), do: []

  def crear_lista([head | tail]) do
    [eliminar_vocal(head) | crear_lista(tail)]
  end

  # Elimina las vocales en posiciones pares
  def eliminar_vocal(palabra), do: eliminar_vocal_aux(palabra, 0, "")

  def eliminar_vocal_aux("", _, respuesta), do: respuesta

  def eliminar_vocal_aux(palabra, i, respuesta) do
    restante = String.slice(palabra, 1..-1//1)
    primera = String.first(palabra)

    if rem(i, 2) == 0 and primera in ["a", "e", "i", "o", "u"] do
      eliminar_vocal_aux(restante, i + 1, respuesta)
    else
      eliminar_vocal_aux(restante, i + 1, respuesta <> primera)
    end
  end
end

defmodule Numeros do
  # Función principal
  def es_reversible?(n) when is_integer(n) and n > 0 do
    rev = invertir(n)
    suma = n + rev
    solo_impares?(suma)
  end

  # Si no es válido
  def es_reversible?(_), do: false

  # Invertir un número
  defp invertir(n), do: invertir_aux(n, 0)

  defp invertir_aux(0, acc), do: acc

  defp invertir_aux(n, acc) do
    invertir_aux(div(n, 10), acc * 10 + rem(n, 10))
  end

  # Verificar si todos los dígitos son impares
  defp solo_impares?(0), do: true

  defp solo_impares?(n) do
    dig = rem(n, 10)

    if rem(dig, 2) == 0 do
      false
    else
      solo_impares?(div(n, 10))
    end
  end
end

defmodule Listas do
  # Función principal
  def contiene?(lista1, lista2), do: buscar(lista1, lista2, lista2)

  # Caso base: sublista vacía, si llegamos aquí es porque es una sublista
  defp buscar(_, [], _), do: true
  # Caso base: lista1 vacía y aún quedan elementos es porque no es sublista
  defp buscar([], _, _), do: false

  defp buscar([h1 | t1], [h2 | t2], original_sublista) do
    cond do
      # Coinciden los elementos, seguir con el resto de ambas listas
      h1 == h2 ->
        buscar(t1, t2, original_sublista)

      # Si no coinciden pero el actual h1 podría ser el comienzo de una nueva coincidencia
      h1 == hd(original_sublista) ->
        buscar(t1, tl(original_sublista), original_sublista)

      # Si no coincide en absoluto se reinicia la búsqueda con la sublista original
      true ->
        buscar(t1, original_sublista, original_sublista)
    end
  end
end

#IO.inspect(Listas.contiene?([2, 4, 7, 7, 10, 8, 41, 2], [7, 10, 8]))
#IO.inspect(ListaSinVocales.crear_lista(["ventana", "elefante", "avion", "umbrella"]))

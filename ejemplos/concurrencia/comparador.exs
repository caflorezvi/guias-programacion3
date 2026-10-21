defmodule Comparador do
  def main do
    tiendas = tiendas_disponibles()

    lanzar_consultas(tiendas)
    |> esperar_precios()
    |> mostrar_mas_barata()
  end

  defp tiendas_disponibles do
    [{"Tienda A", 1}, {"Tienda B", 2}, {"Tienda C", 3}, {"Tienda D", 4}, {"Tienda E", 5}]
  end

  # Lanza las cinco consultas al mismo tiempo
  defp lanzar_consultas(tiendas) do
    Enum.map(tiendas, fn {tienda, segundos} ->
      Task.async(fn -> consultar_precio(tienda, segundos) end)
    end)
  end

  # Espera el precio de cada consulta
  defp esperar_precios(tareas) do
    Enum.map(tareas, fn tarea -> Task.await(tarea) end)
  end

  defp consultar_precio(tienda, segundos) do
    IO.puts("Consultando #{tienda}...")
    :timer.sleep(segundos * 1000)
    precio = :rand.uniform(100) * 1000
    IO.puts("#{tienda} respondió: $#{precio}")
    {tienda, precio}
  end

  defp mostrar_mas_barata(precios) do
    {tienda, precio} = Enum.min_by(precios, fn {_tienda, precio} -> precio end)
    IO.puts("La más barata es #{tienda} con $#{precio}")
  end
end

Comparador.main()

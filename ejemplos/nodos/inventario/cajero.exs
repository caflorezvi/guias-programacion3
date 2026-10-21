defmodule Cajero do
  # El cajero solo conoce la sede de su ciudad
  @sede_local :sede_armenia@localhost
  @timeout 10000

  def main do
    case Node.start(crear_nombre_nodo(), :shortnames) do
      {:ok, _} ->
        IO.puts("Cajero iniciado en #{node()}")
        conectar(Node.connect(@sede_local))

      {:error, _} ->
        IO.puts("No se pudo iniciar el nodo. Verifique que epmd esté corriendo y que el nombre no esté en uso")
    end
  end

  defp crear_nombre_nodo do
    sufijo = :crypto.strong_rand_bytes(4) |> Base.encode16(case: :lower)
    String.to_atom("cajero_#{sufijo}@localhost")
  end

  defp conectar(true) do
    # Espera a que la tabla de nombres globales termine de sincronizarse con el clúster
    :global.sync()

    ciudad = IO.gets("Ciudad de la sede: ") |> String.trim() |> String.downcase()
    producto = IO.gets("Producto: ") |> String.trim() |> String.downcase()
    consultar(ciudad, producto)
  end

  defp conectar(false), do: IO.puts("No se pudo conectar con la sede #{@sede_local}")

  # Busca el inventario de la ciudad por su nombre global, sin saber en qué nodo está
  defp consultar(ciudad, producto) do
    case :global.whereis_name(String.to_atom("inventario_#{ciudad}")) do
      :undefined ->
        IO.puts("No hay una sede activa en #{ciudad}")

      pid ->
        send(pid, {:existencias, self(), producto})
        esperar_respuesta(ciudad)
    end
  end

  defp esperar_respuesta(ciudad) do
    receive do
      {:existencias, producto, cantidad} ->
        IO.puts("En #{ciudad} hay #{cantidad} unidades de #{producto}")

      {:error, :producto_no_existe} ->
        IO.puts("Ese producto no existe en la sede de #{ciudad}")
    after
      @timeout ->
        IO.puts("La sede no respondió en #{@timeout} ms")
    end
  end
end

Cajero.main()

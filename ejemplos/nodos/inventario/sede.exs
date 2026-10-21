defmodule Sede do
  @sedes %{
    "armenia" => :sede_armenia@localhost,
    "pereira" => :sede_pereira@localhost,
    "manizales" => :sede_manizales@localhost
  }

  def main do
    # System.argv() devuelve la lista de argumentos escritos después del nombre del archivo
    case System.argv() do
      [ciudad] -> iniciar_sede(ciudad, Map.get(@sedes, ciudad))
      _ -> IO.puts("Indique la ciudad de la sede, por ejemplo: elixir sede.exs armenia")
    end
  end

  defp iniciar_sede(ciudad, nil) do
    IO.puts("No existe una sede en #{ciudad}")
  end

  defp iniciar_sede(ciudad, nodo) do
    case Node.start(nodo, :shortnames) do
      {:ok, _} ->
        Process.register(self(), :inventario) # Se registra el proceso de inventario con un nombre local
        :global.register_name(String.to_atom("inventario_#{ciudad}"), self()) # Y con un nombre global, visible en todo el clúster
        conectar_con_otras_sedes()

        IO.puts("Sede iniciada en #{node()}")
        IO.puts("Esperando consultas...\n")
        loop(inventario_inicial(ciudad))

      {:error, _} ->
        IO.puts("No se pudo iniciar la sede de #{ciudad}. Verifique que epmd esté corriendo y que la sede no esté activa en otra terminal")
    end
  end

  # Se conecta con las sedes que ya estén encendidas. Las que no, se ignoran
  defp conectar_con_otras_sedes do
    Enum.each(@sedes, fn {_ciudad, nodo} -> Node.connect(nodo) end)
  end

  defp inventario_inicial("armenia"), do: %{"arroz" => 12, "panela" => 30, "frijol" => 8}
  defp inventario_inicial("pereira"), do: %{"arroz" => 5, "panela" => 14, "frijol" => 20}
  defp inventario_inicial("manizales"), do: %{"arroz" => 9, "panela" => 0, "frijol" => 15}

  defp loop(inventario) do
    receive do
      {:existencias, pid, producto} ->
        IO.puts("[#{hora_actual()}] Consulta de #{producto}")
        send(pid, consultar_inventario(inventario, producto))
        loop(inventario)

      {:vender, pid, producto, cantidad} ->
        IO.puts("[#{hora_actual()}] Venta de #{cantidad} #{producto}")
        {respuesta, nuevo_inventario} = vender(inventario, producto, cantidad)
        send(pid, respuesta)
        loop(nuevo_inventario)

      {:reporte, pid} ->
        IO.puts("[#{hora_actual()}] Reporte solicitado")
        spawn(fn -> send(pid, {:reporte, generar_reporte(inventario)}) end)
        loop(inventario)
    end
  end

  # Función pública para consultar la sede con :rpc.
  # Se ejecuta en el nodo de la sede, así que :inventario y node() se refieren a esa sede
  def consultar(producto) do
    send(:inventario, {:existencias, self(), producto})

    receive do
      {:existencias, _producto, cantidad} -> {node(), cantidad}
      {:error, :producto_no_existe} -> {node(), 0}
    after
      5000 -> {node(), :sin_respuesta}
    end
  end

  defp consultar_inventario(inventario, producto) do
    case Map.get(inventario, producto) do
      nil -> {:error, :producto_no_existe}
      cantidad -> {:existencias, producto, cantidad}
    end
  end

  defp vender(inventario, producto, cantidad) do
    case Map.get(inventario, producto) do
      nil ->
        { {:error, :producto_no_existe}, inventario }

      disponibles when disponibles >= cantidad ->
        restantes = disponibles - cantidad
        { {:venta_ok, producto, restantes}, Map.put(inventario, producto, restantes) }

      _ ->
        { {:error, :sin_existencias}, inventario }
    end
  end

  defp generar_reporte(inventario) do
    :timer.sleep(5000)

    inventario
    |> Enum.map(fn {producto, cantidad} -> "#{producto}: #{cantidad}" end)
    |> Enum.join("\n")
  end

  defp hora_actual do
    NaiveDateTime.local_now() |> NaiveDateTime.to_time() |> Time.to_string()
  end
end

Sede.main()

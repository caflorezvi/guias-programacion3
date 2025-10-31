defmodule Servidor do
  def main do
    Node.start(:servidor@localhost, :shortnames)
    Node.set_cookie(:cookie)
    Process.register(self(), :principal)

    IO.puts("Servidor iniciado en #{node()}")
    IO.puts("Esperando conexiones...\n")

    loop()
  end

  def loop do
    receive do
      {:procesar_lista, pid, lista} ->
        IO.puts("[#{timestamp()}] Petición: procesar_lista")
        resultado = generar_respuesta(lista)
        send(pid, {:lista_procesada, resultado})

      {:filtrar_pares, pid, lista} ->
        IO.puts("[#{timestamp()}] Petición: filtrar_pares")
        resultado = filtrar_pares(lista)
        send(pid, {:lista_filtrada, resultado})

      {:tarea_costosa, pid} ->
        IO.puts("[#{timestamp()}] Petición: tarea_costosa (50s)")

        spawn(fn ->
            :timer.sleep(50000)
            send(pid, :tarea_completada)
            IO.puts("[#{timestamp()}] Tarea costosa completada")
        end)

      {:opcion_invalida, pid} ->
        IO.puts("[#{timestamp()}] Petición inválida recibida")
        send(pid, :opcion_invalida)

      mensaje ->
        IO.puts("[#{timestamp()}] Mensaje desconocido: #{inspect(mensaje)}")
    end

    loop()
  end

  defp filtrar_pares(lista), do: Enum.filter(lista, fn el -> rem(el, 2) == 0 end)

  defp generar_respuesta([]), do: :error
  defp generar_respuesta(lista) do
    suma = Enum.sum(lista)
    promedio = suma / length(lista)
    {suma, promedio}
  end

  defp timestamp do
    Time.utc_now() |> Time.to_string() |> String.slice(0..7)
  end
end

Servidor.main()

defmodule Servidor do
  # Inicia el nodo servidor y espera peticiones
  def main do
    Node.start(:servidor@localhost, :shortnames)
    Node.set_cookie(:cookie)
    Process.register(self(), :principal) # Registrar el proceso principal con un nombre global

    IO.puts("Servidor iniciado en #{node()}")
    IO.puts("Esperando conexiones...\n")

    loop() # Iniciar el bucle de recepción de mensajes
  end

  def loop do
    # Se reciben los diferentes tipos de mensajes posibles y se responde adecuadamente
    receive do
      {:sumar_numeros, pid, lista} ->
        IO.puts("[#{timestamp()}] Petición: sumar_numeros")
        resultado = sumar_numeros(lista)
        send(pid, {:resultado_suma, resultado})

      {:calcular_promedio, pid, lista} ->
        IO.puts("[#{timestamp()}] Petición: calcular_promedio")
        resultado = calcular_promedio(lista)
        send(pid, {:resultado_promedio, resultado})

      {:filtrar_pares, pid, lista} ->
        IO.puts("[#{timestamp()}] Petición: filtrar_pares")
        resultado = filtrar_pares(lista)
        send(pid, {:lista_filtrada, resultado})

      {:tarea_costosa, pid} ->
        IO.puts("[#{timestamp()}] Petición: tarea_costosa (50s)")

        # Se crea un proceso separado para no bloquear el proceso principal del servidor
        spawn(fn ->
            hacer_tarea_costosa()
            send(pid, :tarea_completada)
            IO.puts("[#{timestamp()}] Tarea costosa completada")
        end)

      mensaje ->
        IO.puts("[#{timestamp()}] Mensaje desconocido: #{inspect(mensaje)}")
    end

    loop()
  end

  defp filtrar_pares(lista), do: Enum.filter(lista, fn el -> rem(el, 2) == 0 end)
  defp sumar_numeros(lista), do: Enum.sum(lista)
  defp calcular_promedio([]), do: :error
  defp calcular_promedio(lista), do: Enum.sum(lista) / length(lista)
  def hacer_tarea_costosa(), do: :timer.sleep(50000)

  defp timestamp do
    Time.utc_now() |> Time.to_string() |> String.slice(0..7)
  end
end

Servidor.main()

defmodule Servidor do
  use GenServer

  def main do
    Node.start(:servidor@localhost, :shortnames)
    Node.set_cookie(:cookie)
    start_link()

    IO.puts("Servidor iniciado.")
    IO.puts("Esperando mensajes.....")

    :timer.sleep(:infinity)
  end

  def start_link do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(init_arg) do
    {:ok, init_arg}
  end

  # Petición síncrona (el servidor espera responderle al usuario con algo en la mayoría de los casos)
  def handle_call({:sumar_numeros, lista}, _from, state) do
    IO.puts("[#{timestamp()}] Petición: sumar_numeros")
    respuesta = sumar_numeros(lista)
    {:reply, respuesta, state}
  end

  def handle_call({:calcular_promedio, lista}, _from, state) do
    IO.puts("[#{timestamp()}] Petición: calcular_promedio")
    respuesta = calcular_promedio(lista)
    {:reply, respuesta, state}
  end

  def handle_call({:filtar_pares, lista}, _from, state) do
    IO.puts("[#{timestamp()}] Petición: filtrar_pares")
    respuesta = filtrar_pares(lista)
    {:reply, respuesta, state}
  end

  def handle_call(:tarea_costosa, from, state) do
    IO.puts("[#{timestamp()}] Petición: tarea_costosa")
    # Se inicia una tarea asíncrona para no bloquear el servidor mientras se realiza la tarea costosa
    Task.start(fn ->
      :timer.sleep(50000)
      GenServer.reply(from, :ok)
    end )
    {:noreply, state}
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

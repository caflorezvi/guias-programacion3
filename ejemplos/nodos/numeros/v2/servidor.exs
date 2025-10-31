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
  def handle_call({:procesar_lista, lista}, _from, state) do
    respuesta = generar_respuesta(lista)
    {:reply, respuesta, state}
  end

  def handle_call({:filtar_pares, lista}, _from, state) do
    respuesta = filtrar_pares(lista)
    {:reply, respuesta, state}
  end

  def handle_call(:tarea_costosa, from, state) do
    Task.start(fn ->
      :timer.sleep(50000)
      GenServer.reply(from, :ok)
    end )
    {:noreply, state}
  end

  # Peticiones asíncronas (el servidor NO espera respoderle al usuario)
  #def handle_cast(request, state) do
  #end

  def filtrar_pares(lista), do: Enum.filter(lista, fn el -> rem(el, 2) == 0 end )

  def generar_respuesta([]), do: :error
  def generar_respuesta(lista) do
    suma = Enum.sum(lista)
    { suma, suma / length(lista) }
  end

end

Servidor.main()

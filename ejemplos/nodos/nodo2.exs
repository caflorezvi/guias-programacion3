defmodule Servidor do
  def main do
    # Inicia el nodo en modo distribuido con un nombre corto
    {:ok, _} = Node.start(:nodo2@localhost, :shortnames)

    # Establece la cookie para la autenticación entre nodos
    Node.set_cookie(:mi_cookie)

    # Crear un proceso que escuche mensajes
    pid = spawn(fn -> loop() end)

    # Registrar el proceso con un nombre global en este nodo. Esto permite que otros nodos lo encuentren
    Process.register(pid, :proceso_en_nodo2)

    IO.puts("Nodo iniciado correctamente: #{Node.self()}")
    IO.puts("Esperando mensajes...")

    # Mantener el nodo activo
    :timer.sleep(:infinity)
  end

  # Función recursiva para recibir mensajes indefinidamente
  defp loop do
    receive do
      {:mensaje, msg} ->
        IO.puts("Recibido en nodo 2: #{msg}")
        loop()
    end
  end
end

Servidor.main()

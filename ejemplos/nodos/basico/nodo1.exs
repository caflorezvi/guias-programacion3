defmodule Cliente do
  def main do
    # Inicia el nodo en modo distribuido con un nombre corto
    {:ok, _} = Node.start(:nodo1@localhost, :shortnames)

    # Establece la cookie (debe coincidir con la del nodo2)
    Node.set_cookie(:mi_cookie)

    # Intentar conectarse al nodo2
    if Node.connect(:nodo2@localhost) do
      IO.puts("Conectado a nodo2@localhost correctamente")
    else
      IO.puts("No se pudo conectar a nodo2@localhost")
    end

    # Enviar mensaje al proceso remoto
    send({:proceso_en_nodo2, :nodo2@localhost}, {:mensaje, "Hola desde nodo1"})

    IO.puts("Mensaje enviado a nodo2")
  end
end

Cliente.main()

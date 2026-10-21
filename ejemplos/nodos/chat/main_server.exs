# main_server.exs
Code.require_file("chat_room.exs", __DIR__)
Code.require_file("chat_server.exs", __DIR__)

defmodule MainServer do
  def start do
    # Iniciar el nodo del servidor
    {:ok, _} = Node.start(:servidor_chat@localhost, :shortnames)
    Node.set_cookie(:mi_cookie)

    # Iniciar el ChatServer
    {:ok, _pid} = ChatServer.start_link()
    IO.puts("🚀 Servidor de chat iniciado en #{inspect(Node.self())}")

    # Crear algunas salas por defecto
    ChatServer.create_room("general")
    ChatServer.create_room("soporte")

    IO.puts("📜 Salas disponibles: #{inspect(ChatServer.list_rooms())}")

    # Mantener el proceso corriendo
    Process.sleep(:infinity)
  end
end

MainServer.start()

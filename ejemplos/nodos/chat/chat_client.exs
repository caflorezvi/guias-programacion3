defmodule ChatClient do
  def start(username) do
    # Iniciar un proceso para el cliente que maneje la recepción de mensajes y la interacción con el servidor
    spawn(fn -> loop(username, %{}) end)
  end

  defp loop(username, joined_rooms) do
    receive do
      {:chat, room, msg} ->
        # Recibir un mensaje de una sala de chat y mostrarlo en la consola
        IO.puts("[#{room}] #{msg}")
        loop(username, joined_rooms)

      {:join, _server_pid, room_name} ->
        # Unirse a una sala de chat específica solicitando el pid de la sala al servidor
        case ChatServer.get_room_pid(room_name) do
          nil ->
            IO.puts("La sala #{room_name} no existe")
            loop(username, joined_rooms)

          room_pid ->
            # Unirse a la sala de chat enviando un mensaje al proceso de la sala, indicando el pid del cliente y su nombre de usuario
            ChatRoom.join(room_pid, self(), username)
            loop(username, Map.put(joined_rooms, room_name, room_pid))
        end

      {:send, room_name, msg} ->
        # Enviar un mensaje a una sala de chat específica
        case Map.get(joined_rooms, room_name) do
          nil -> IO.puts("No estás en la sala #{room_name}")
          room_pid -> ChatRoom.send_message(room_pid, self(), msg)
        end
        loop(username, joined_rooms)

      {:leave, room_name} ->
        # Salir de una sala de chat
        case Map.pop(joined_rooms, room_name) do
          {nil, _} ->
            IO.puts("No estás en #{room_name}")
            loop(username, joined_rooms)   # Sin esta llamada el cliente terminaría

          {pid, rest} ->
            ChatRoom.leave(pid, self())
            loop(username, rest)
        end
    end
  end
end

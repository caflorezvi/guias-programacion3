defmodule ChatClient do
  def start(username) do
    spawn(fn -> loop(username, %{}) end)
  end

  defp loop(username, joined_rooms) do
    receive do
      {:chat, room, msg} ->
        IO.puts("[#{room}] #{msg}")
        loop(username, joined_rooms)

      {:join, server_pid, room_name} ->
        case ChatServer.get_room_pid(room_name) do
          nil ->
            IO.puts("La sala #{room_name} no existe")
            loop(username, joined_rooms)

          room_pid ->
            ChatRoom.join(room_pid, self(), username)
            loop(username, Map.put(joined_rooms, room_name, room_pid))
        end

      {:send, room_name, msg} ->
        case Map.get(joined_rooms, room_name) do
          nil -> IO.puts("No estás en la sala #{room_name}")
          room_pid -> ChatRoom.send_message(room_pid, self(), msg)
        end
        loop(username, joined_rooms)

      {:leave, room_name} ->
        case Map.pop(joined_rooms, room_name) do
          {nil, _} -> IO.puts("No estás en #{room_name}")
          {pid, rest} -> ChatRoom.leave(pid, self()); loop(username, rest)
        end
    end
  end
end

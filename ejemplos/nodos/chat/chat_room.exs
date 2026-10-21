defmodule ChatRoom do
  use GenServer

  # Estado: %{name: String, users: %{pid => username}, messages: [String]}

  ## --- API pública ---

  def start_link(name) do
    GenServer.start_link(__MODULE__, %{name: name, users: %{}, messages: []})
  end

  def join(pid, user_pid, username), do: GenServer.cast(pid, {:join, user_pid, username})
  def leave(pid, user_pid), do: GenServer.cast(pid, {:leave, user_pid})
  def send_message(pid, user_pid, msg), do: GenServer.cast(pid, {:message, user_pid, msg})

  ## Callbacks

  @impl true
  def init(state), do: {:ok, state}

  @impl true
  def handle_cast({:join, pid, username}, state) do
    # Monitorear el proceso del usuario para detectar desconexiones
    Process.monitor(pid)
    IO.puts("#{username} se unió a #{state.name}")
    # Se agrega el usuario al estado de la sala, su pid es la clave y su nombre es el valor
    {:noreply, %{state | users: Map.put(state.users, pid, username)}}
  end

  @impl true
  def handle_cast({:leave, pid}, state) do
    # Eliminar al usuario dado su pid
    {username, users} = Map.pop(state.users, pid) 
    IO.puts("#{username} salió de #{state.name}")
    {:noreply, %{state | users: users}}
  end

  @impl true
  def handle_cast({:message, from_pid, msg}, state) do
    # Obtener el nombre del usuario que envió el mensaje usando su pid
    username = Map.get(state.users, from_pid, "Desconocido")
    full = "#{username}: #{msg}"
    # Enviar el mensaje a todos los usuarios conectados a la sala
    Enum.each(state.users, fn {pid, _} -> send(pid, {:chat, state.name, full}) end)
    {:noreply, %{state | messages: [full | state.messages]}}
  end

  @impl true
  def handle_info({:DOWN, _ref, :process, pid, _}, state) do
    # Eliminar al usuario desconectado cuando su proceso muere
    {username, users} = Map.pop(state.users, pid) 
    IO.puts("#{username} desconectado de #{state.name}")
    {:noreply, %{state | users: users}}
  end
end

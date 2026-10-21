defmodule ChatServer do
  use GenServer

  ## --- API pública ---

  def start_link(_opts \\ []) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def create_room(name), do: GenServer.call(__MODULE__, {:create_room, name})
  def list_rooms(), do: GenServer.call(__MODULE__, :list_rooms)
  def get_room_pid(name), do: GenServer.call(__MODULE__, {:get_room, name})

  ## --- Callbacks ---

  @impl true
  def init(_) do
    # Supervisor dinámico para las salas de chat
    {:ok, sup} = DynamicSupervisor.start_link(strategy: :one_for_one) 
    # El estado del servidor incluye un mapa de salas (nombre => pid) y el pid del supervisor
    {:ok, %{rooms: %{}, sup: sup}}
  end

  @impl true
  def handle_call({:create_room, name}, _from, state) do
    if Map.has_key?(state.rooms, name) do
      # La sala ya existe, no se puede crear otra con el mismo nombre
      {:reply, {:error, :exists}, state}
    else
      # Iniciar una nueva sala de chat como un proceso hijo del supervisor dinámico
      {:ok, pid} = DynamicSupervisor.start_child(state.sup, {ChatRoom, name})
      {:reply, {:ok, pid}, %{state | rooms: Map.put(state.rooms, name, pid)}}
    end
  end

  @impl true
  def handle_call(:list_rooms, _from, state) do
    # Devuelve la lista de nombres de las salas de chat disponibles
    {:reply, Map.keys(state.rooms), state}
  end

  @impl true
  def handle_call({:get_room, name}, _from, state) do
    # Devuelve el pid de la sala si existe, o nil si no existe
    {:reply, Map.get(state.rooms, name), state}
  end
end

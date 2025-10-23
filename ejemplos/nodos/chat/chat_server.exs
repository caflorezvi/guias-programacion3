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
    {:ok, sup} = DynamicSupervisor.start_link(strategy: :one_for_one) # Supervisor dinámico para las salas de chat
    {:ok, %{rooms: %{}, sup: sup}}
  end

  @impl true
  def handle_call({:create_room, name}, _from, state) do
    if Map.has_key?(state.rooms, name) do
      {:reply, {:error, :exists}, state}
    else
      {:ok, pid} = DynamicSupervisor.start_child(state.sup, {ChatRoom, name}) # Iniciar una nueva sala
      {:reply, {:ok, pid}, %{state | rooms: Map.put(state.rooms, name, pid)}}
    end
  end

  def handle_call(:list_rooms, _from, state) do
    {:reply, Map.keys(state.rooms), state}
  end

  def handle_call({:get_room, name}, _from, state) do
    {:reply, Map.get(state.rooms, name), state}
  end
end

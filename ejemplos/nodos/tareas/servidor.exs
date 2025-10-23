defmodule TareasServidor do
  use GenServer

  # Iniciar el GenServer con estado inicial vacío
  def start_link do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(state), do: {:ok, state}

  # ---- Callbacks ----
  def handle_cast({:eliminar_tarea, usuario, titulo}, state) do
    nuevas_tareas =
      state
      |> Map.get(usuario, [])
      |> Enum.filter(fn %Tarea{titulo: t} -> t != titulo end)

    {:noreply, Map.put(state, usuario, nuevas_tareas)}
  end

  def handle_call({:agregar_tarea, usuario, tarea}, _from, state) do
    IO.puts("Se ha enviado una nueva tarea desde un cliente")
    tareas_usuario = Map.get(state, usuario, [])
    nuevas_tareas = [tarea | tareas_usuario]
    nuevo_estado = Map.put(state, usuario, nuevas_tareas)

    {:reply, :ok, nuevo_estado}
  end

  def handle_call({:listar_tareas, usuario}, _from, state) do
    {:reply, Map.get(state, usuario, []), state}
  end

  def main do

    # Crear un nodo servidor
    #{:ok, _} = Node.start(:"servidor_tareas@192.168.1.20", :longnames)
    {:ok, _} = Node.start(:servidor_tareas@localhost, :shortnames)

    # Establece la cookie
    Node.set_cookie(:mi_cookie)

    # Iniciar el servidor de tareas
    {:ok, _} = start_link()
    IO.puts("Servidor de tareas iniciado")

    # Mantener vivo el proceso principal
    :timer.sleep(:infinity)

  end

end

TareasServidor.main()

# ====== Arranque automático del nodo ======

# Nombre y cookie del nodo servidor

# Crear el nodo actual con ese nombre y cookie
#{:ok, _} = :net_kernel.start([:servidor_notas])
#Node.set_cookie(:mi_cookie)
#elixir --sname servidor --cookie mi_cookie server.exs

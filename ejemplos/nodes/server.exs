# ====== Servidor de tareas ======
defmodule TareasServidor do
  use GenServer

  # Iniciar el GenServer con estado inicial vacío
  def start_link do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(state), do: {:ok, state}

  # ---- Callbacks ----
  def handle_cast({:agregar_tarea, usuario, tarea}, state) do
    tareas_usuario = Map.get(state, usuario, [])
    nuevas_tareas = [tarea | tareas_usuario]
    {:noreply, Map.put(state, usuario, nuevas_tareas)}
  end

  def handle_cast({:eliminar_tarea, usuario, titulo}, state) do
    nuevas_tareas =
      state
      |> Map.get(usuario, [])
      |> Enum.filter(fn %Tarea{titulo: t} -> t != titulo end)

    {:noreply, Map.put(state, usuario, nuevas_tareas)}
  end

  def handle_call({:listar_tareas, usuario}, _from, state) do
    {:reply, Map.get(state, usuario, []), state}
  end

  def main do

    # Imprimir el nombre del nodo
    IO.puts(Node.self())

    # Iniciar el servidor de tareas
    {:ok, _} = start_link()
    IO.puts("🚀 Servidor de tareas iniciado")

    # Mantener el proceso principal vivo
    Process.sleep(:infinity)
  end

end

TareasServidor.main()

# ====== Arranque automático del nodo ======

# Nombre y cookie del nodo servidor

# Crear el nodo actual con ese nombre y cookie
#{:ok, _} = :net_kernel.start([:servidor_notas])
#Node.set_cookie(:mi_cookie)
#elixir --sname servidor --cookie mi_cookie server.exs

defmodule TareasCliente do
  use GenServer

  def start_link(server_node) do
    # Conectarse automáticamente al nodo servidor
    case Node.connect(server_node) do
      true -> IO.puts("✅ Conectado al nodo #{inspect(server_node)}")
      false -> IO.puts("⚠️ No se pudo conectar con #{inspect(server_node)}")
    end

    GenServer.start_link(__MODULE__, server_node, name: __MODULE__)
  end

  def init(server_node), do: {:ok, server_node}

  # ---- API pública ----
  def agregar_tarea(usuario, %Tarea{} = tarea) do
    GenServer.cast(__MODULE__, {:agregar_tarea, usuario, tarea})
  end

  def eliminar_tarea(usuario, titulo) do
    GenServer.cast(__MODULE__, {:eliminar_tarea, usuario, titulo})
  end

  def listar_tareas(usuario) do
    GenServer.call(__MODULE__, {:listar_tareas, usuario})
  end

  # ---- Callbacks ----
  def handle_cast({:agregar_tarea, usuario, tarea}, server_node) do
    GenServer.cast({TareasServidor, server_node}, {:agregar_tarea, usuario, tarea})
    {:noreply, server_node}
  end

  def handle_cast({:eliminar_tarea, usuario, titulo}, server_node) do
    GenServer.cast({TareasServidor, server_node}, {:eliminar_tarea, usuario, titulo})
    {:noreply, server_node}
  end

  def handle_call({:listar_tareas, usuario}, _from, server_node) do
    tareas = GenServer.call({TareasServidor, server_node}, {:listar_tareas, usuario})
    {:reply, tareas, server_node}
  end

  def main do

    # Nombre del nodo servidor (ajustar según sea necesario)
    server_node = :'servidor@Mac-mini-de-Carlos'

    IO.puts("💻 Nodo cliente iniciado")

    # Conectarse al servidor y arrancar el cliente
    {:ok, _pid} = start_link(server_node)

    # ====== Ejemplo automático de uso ======
    agregar_tarea("usuario1", %Tarea{titulo: "Comprar leche", descripcion: "Ir al supermercado"})
    agregar_tarea("usuario1", %Tarea{titulo: "Estudiar Elixir", descripcion: "Leer la guía oficial"})
    IO.inspect(listar_tareas("usuario1"))

  end
end

TareasCliente.main()

# ====== Arranque automático del nodo cliente ======



#{:ok, _} = Node.start(:cliente)
#Node.set_cookie(:mi_cookie)
#elixir --sname cliente --cookie mi_cookie client.exs

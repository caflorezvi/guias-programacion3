defmodule EjemploComunicacion do
  @moduledoc """
    Ejemplo de comunicación entre procesos en Elixir usando send y receive
  """

  @doc """
    Proceso 1 recibe un mensaje y envía una confirmación
  """
  def proceso1 do
    receive do
      {:mensaje, msg, pid} ->
        IO.puts "Proceso 1 recibió el mensaje: #{msg}"
        send(pid, :confirmacion)
    end
  end

  @doc """
    Proceso 2 envía un mensaje a proceso 1 y espera confirmación
  """
  def proceso2(pid) do
    send(pid, {:mensaje, "Hola desde proceso 2", self()})

    receive do
      :confirmacion ->
        IO.puts "Proceso 2 recibió confirmación de proceso 1"
    end
  end

  @doc """
    Iniciar procesos 1 y 2
  """
  def iniciar do
    # Iniciar proceso 1
    task1 = Task.async(fn -> proceso1() end)
    # Iniciar proceso 2 y enviar pid de proceso 1
    task2 = Task.async(fn -> proceso2(task1.pid) end)

    # Esperar a que ambos procesos terminen
    Task.await(task1)
    Task.await(task2)
  end
end


defmodule CallCenter do
  def start do
    # Simular la llegada de llamadas
    Enum.each(1..10, fn call_id ->
      spawn(fn -> handle_call(call_id) end)
      :timer.sleep(500)  # Simula el tiempo entre llamadas
    end)
  end

  defp handle_call(call_id) do
    agent_pid = assign_agent()
    send(agent_pid, {:new_call, call_id})
    receive do
      {:call_handled, call_id, satisfaction} ->
        IO.puts("Call #{call_id} handled with satisfaction: #{satisfaction}")
    end
  end

  defp assign_agent do
    # Aquí se podría implementar una lógica para asignar agentes disponibles
    spawn(fn -> agent_loop() end)
  end

  defp agent_loop do
    receive do
      {:new_call, call_id} ->
        IO.puts("Agent handling call #{call_id}")
        :timer.sleep(1000)  # Simula el tiempo de atención
        satisfaction = Enum.random(1..5)  # Simula la satisfacción del cliente
        send(self(), {:call_handled, call_id, satisfaction})
        agent_loop()  # Continuar escuchando nuevas llamadas
    end
  end
end

EjemploComunicacion.iniciar()

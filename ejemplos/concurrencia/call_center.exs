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

CallCenter.start()

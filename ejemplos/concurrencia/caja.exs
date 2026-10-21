defmodule Caja do
  def main do
    IO.puts("Iniciando caja registradora")
    abrir()
    registrar_ventas()
    inspeccionar()

    total = consultar_total()
    IO.puts("La caja respondió que el total vendido es $#{total}")
  end

  # Crea el proceso de la caja y lo registra con el nombre :caja
  defp abrir do
    pid = spawn(fn -> loop(0) end)
    Process.register(pid, :caja)
  end

  # Con el nombre registrado, ya no hace falta pasar el PID de una función a otra
  defp registrar_ventas do
    send(:caja, {:sumar, 5000})
    send(:caja, {:sumar, 3000})
    send(:caja, {:sumar, 2000})
  end

  # Se inspecciona el proceso con funciones del módulo Process
  defp inspeccionar do
    pid = Process.whereis(:caja)
    IO.inspect(Process.info(pid, :message_queue_len), label: "Mensajes pendientes")
    IO.puts("¿La caja sigue abierta? #{Process.alive?(pid)}")
  end

  defp consultar_total do
    # Le pide el total a la caja, indicándole a quién debe responder
    send(:caja, {:total, self()})

    # Espera la respuesta en el mailbox del proceso principal
    receive do
      {:total, total} -> total
    end
  end

  defp loop(total) do
    receive do
      {:sumar, valor} ->
        loop(total + valor)
      {:total, remitente} ->
        send(remitente, {:total, total}) # Le responde al proceso que preguntó
        loop(total)
    end
  end
end

Caja.main()

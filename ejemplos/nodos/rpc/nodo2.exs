defmodule Operaciones do
  @moduledoc """
  Módulo que contiene operaciones matemáticas para ser llamadas remotamente
  """

  def cuadrado(numero) do
    IO.puts("Calculando el cuadrado de #{numero}...")
    numero * numero
  end

end

defmodule ServidorRPC do
  def main do
    # Inicia el nodo en modo distribuido con un nombre corto
    {:ok, _} = Node.start(:nodo2@localhost, :shortnames)

    # Establece la misma cookie que el cliente para la autenticación
    Node.set_cookie(:mi_cookie)

    IO.puts("Nodo2 iniciado correctamente: #{Node.self()}")
    IO.puts("Esperando llamadas RPC...")
    IO.puts("Presiona Ctrl+C dos veces para salir")

    # Mantener el proceso vivo indefinidamente
    :timer.sleep(:infinity)
  end
end

ServidorRPC.main()

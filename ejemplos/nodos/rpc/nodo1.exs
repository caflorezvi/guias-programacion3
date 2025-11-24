defmodule ClienteRPC do
  def main do
    # Inicia el nodo en modo distribuido con un nombre corto
    {:ok, _} = Node.start(:nodo1@localhost, :shortnames)

    # Establece la cookie para la autenticación entre nodos
    Node.set_cookie(:mi_cookie)

    IO.puts("Nodo1 iniciado correctamente: #{Node.self()}")

    # Llamar a la función 'cuadrado/1' del módulo 'Operaciones' en el nodo2
    resultado = :rpc.call(:nodo2@localhost, Operaciones, :cuadrado, [12])
    IO.puts("Resultado remoto: #{resultado}")
  end
end

ClienteRPC.main()

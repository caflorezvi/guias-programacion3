defmodule Cliente do
  @modulo_servidor Servidor
  @nodo_servidor :servidor@localhost

  def main do
    Node.start(crear_nombre_nodo() |> String.to_atom(), :shortnames)
    Node.set_cookie(:cookie)

    IO.puts("Cliente iniciado en #{node()}")
    IO.puts("Intentando conectar al servidor...")

    if Node.connect(@nodo_servidor) do
      IO.puts("Conexión exitosa")
      pedir_numeros() |> enviar_peticion()
    else
      IO.puts("No se pudo conectar al servidor")
    end

    IO.puts("Conexión finalizada")
  end

  # Crear un nombre único para el nodo del cliente
  def crear_nombre_nodo do
    uuid = :crypto.strong_rand_bytes(8) |> Base.encode16(case: :lower)
    "cliente_#{uuid}@localhost"
  end

  def pedir_numeros do
    IO.puts("\nBienvenido cliente")
    IO.puts("Opciones disponibles:")
    IO.puts("1 - Sumar los números")
    IO.puts("2 - Calcular el promedio")
    IO.puts("3 - Filtrar números pares")
    IO.puts("4 - Ejecutar tarea costosa\n")

    opcion = IO.gets("Seleccione una opción (1-4): ") |> String.trim()
    {opcion, crear_lista([])}
  end

  def crear_lista(lista) do
    valor = IO.gets("Ingrese un número (o 'fin' para terminar): ") |> String.trim()

    case valor do
      "fin" ->
        Enum.reverse(lista)

      _ ->
        case Integer.parse(valor) do
          {num, _} ->
            crear_lista([num | lista])

          :error ->
            IO.puts("Error: Solo se aceptan números enteros")
            crear_lista(lista)
        end
    end
  end

  def enviar_peticion({"1", lista}) do
    respuesta = GenServer.call({@modulo_servidor, @nodo_servidor}, {:sumar_numeros, lista})
    IO.inspect(respuesta)
  end

  def enviar_peticion({"2", lista}) do
    respuesta = GenServer.call({@modulo_servidor, @nodo_servidor}, {:calcular_promedio, lista})
    IO.inspect(respuesta)
  end

  def enviar_peticion({"3", lista}) do
    respuesta = GenServer.call({@modulo_servidor, @nodo_servidor}, {:filtrar_pares, lista})
    IO.inspect(respuesta)
  end

  def enviar_peticion({"4", _lista}) do
    respuesta = GenServer.call({@modulo_servidor, @nodo_servidor}, :tarea_costosa, :infinity)
    IO.inspect(respuesta)
  end

  def enviar_peticion({opcion, _lista}) do
    IO.puts("Opción inválida: #{opcion}")
  end
end

Cliente.main()

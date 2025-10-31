defmodule Cliente do
  use GenServer

  @servidor :servidor@localhost

  def main do

    Node.start(:cliente@localhost, :shortnames)
    Node.set_cookie(:cookie)

    if Node.connect(@servidor) do
      IO.puts("Conexión exitosa")
      ejecutar_peticion() |> enviar_peticion()
    else
      IO.puts("No se pudo conectar al servidor")
    end

  end

  def crear_lista(lista) do
    valor = IO.gets("Escriba un número o fin para terminar: ") |> String.trim()
    case valor do
      "fin" -> lista
      _ ->
        case Integer.parse(valor) do
          {num, _} -> crear_lista( [ num |  lista] )
          _ ->
            IO.puts("Solo se aceptan números enteros")
            crear_lista(lista )
        end
    end
  end

  def ejecutar_peticion do
    IO.puts("\nBienvenido cliente")
    IO.puts("Opciones disponibles:")
    IO.puts("1 - Sumar y calcular promedio")
    IO.puts("2 - Filtrar números pares")
    IO.puts("3 - Ejecutar tarea costosa\n")

    opcion = IO.gets("Seleccione una opción (1-3): ") |> String.trim()
    {opcion, crear_lista([])}
  end

  def enviar_peticion({"1", lista}) do
    respuesta = GenServer.call({Servidor, @servidor},{:procesar_lista, lista})
    IO.inspect(respuesta)
  end

  def enviar_peticion({"2", lista}) do
    respuesta = GenServer.call({Servidor, @servidor},{:filtar_pares, lista})
    IO.inspect(respuesta)
  end

  def enviar_peticion({"3", _lista}) do
    respuesta = GenServer.call({Servidor, @servidor},:tarea_costosa, :infinity)
    IO.inspect(respuesta)
  end

  def enviar_peticion({opcion, _lista}) do
    IO.puts("Opción inválida: #{opcion}")
  end

end

Cliente.main()

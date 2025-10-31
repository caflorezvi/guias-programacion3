defmodule Cliente do
  @nombre_servidor :servidor@localhost
  @nombre_proceso :principal
  @timeout 10000

  def main do
    Node.start( crear_nombre_nodo() |> String.to_atom(), :shortnames)
    Node.set_cookie(:cookie)

    IO.puts("Cliente iniciado en #{node()}")
    IO.puts("Intentando conectar al servidor...")

    conectar_servidor(Node.connect(@nombre_servidor))

    IO.puts("Conexión finalizada")
  end

  # Crear un nombre único para el nodo del cliente
  def crear_nombre_nodo do
    uuid = :crypto.strong_rand_bytes(8) |> Base.encode16(case: :lower)
    "cliente_#{uuid}@localhost"
  end

  def conectar_servidor(true) do
    IO.puts("Conexión exitosa")
    pedir_numeros() |> enviar_peticion()
    esperar_respuesta()
  end

  def conectar_servidor(false), do: IO.puts("No se pudo conectar al servidor")

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

  def enviar_peticion({"1", lista}) do
    send({@nombre_proceso, @nombre_servidor}, {:sumar_numeros, self(), lista})
  end

  def enviar_peticion({"2", lista}) do
    send({@nombre_proceso, @nombre_servidor}, {:calcular_promedio, self(), lista})
  end

  def enviar_peticion({"3", lista}) do
    send({@nombre_proceso, @nombre_servidor}, {:filtrar_pares, self(), lista})
  end

  def enviar_peticion({"4", _lista}) do
    send({@nombre_proceso, @nombre_servidor}, {:tarea_costosa, self()})
  end

  def enviar_peticion({opcion, _lista}) do
    IO.puts("Opción inválida: #{opcion}")
  end

  def esperar_respuesta do
    receive do
      {:resultado_suma, suma} ->
        IO.puts("\nResultado recibido:")
        IO.puts("  Suma: #{suma}")

      {:resultado_promedio, :error} ->
        IO.puts("\nError: No se puede procesar una lista vacía")

      {:resultado_promedio, promedio} ->
        IO.puts("\nResultado recibido:")
        IO.puts("  Promedio: #{promedio}")

      {:lista_filtrada, lista} ->
        IO.puts("\nNúmeros pares filtrados:")
        IO.inspect(lista)

      :tarea_completada ->
        IO.puts("\nLa tarea costosa terminó exitosamente")

    after
      @timeout ->
        IO.puts("\nTimeout: El servidor no respondió en #{@timeout}ms")
    end
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
end

Cliente.main()

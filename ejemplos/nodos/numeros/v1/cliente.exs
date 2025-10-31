defmodule Cliente do
  @servidor :servidor@localhost
  @timeout 10000

  def main do
    Node.start(crear_nombre_unico(), :shortnames)
    Node.set_cookie(:cookie)

    IO.puts("Intentando conectar al servidor...")

    conectar_servidor(Node.connect(@servidor))

    IO.puts("Conexión finalizada")
  end

  def crear_nombre_unico do
    random_suffix = :erlang.unique_integer([:positive])
    String.to_atom("cliente_#{random_suffix}@localhost")
  end

  def conectar_servidor(true) do
    IO.puts("Conexión exitosa")
    pedir_numeros() |> enviar_peticion()
    esperar_respuesta()
  end

  def conectar_servidor(false) do
    IO.puts("No se pudo conectar al servidor")
  end

  def pedir_numeros do
    IO.puts("\nBienvenido cliente")
    IO.puts("Opciones disponibles:")
    IO.puts("1 - Sumar y calcular promedio")
    IO.puts("2 - Filtrar números pares")
    IO.puts("3 - Ejecutar tarea costosa\n")

    opcion = IO.gets("Seleccione una opción (1-3): ") |> String.trim()
    {opcion, crear_lista([])}
  end

  def enviar_peticion({"1", lista}) do
    send({:principal, @servidor}, {:procesar_lista, self(), lista})
  end

  def enviar_peticion({"2", lista}) do
    send({:principal, @servidor}, {:filtrar_pares, self(), lista})
  end

  def enviar_peticion({"3", _lista}) do
    send({:principal, @servidor}, {:tarea_costosa, self()})
  end

  def enviar_peticion({opcion, _lista}) do
    IO.puts("Opción inválida: #{opcion}")
    send({:principal, @servidor}, {:opcion_invalida, self()})
  end

  def esperar_respuesta do
    receive do
      {:lista_procesada, {suma, promedio}} ->
        IO.puts("\nResultado recibido:")
        IO.puts("  Suma: #{suma}")
        IO.puts("  Promedio: #{promedio}")

      {:lista_procesada, :error} ->
        IO.puts("\nError: No se puede procesar una lista vacía")

      {:lista_filtrada, lista} ->
        IO.puts("\nNúmeros pares filtrados:")
        IO.inspect(lista)

      {:error, mensaje} ->
        IO.puts("\nError del servidor: #{mensaje}")

      :tarea_completada ->
        IO.puts("\nLa tarea costosa terminó exitosamente")

      :opcion_invalida ->
        IO.puts("\nEl servidor rechazó la opción enviada")
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

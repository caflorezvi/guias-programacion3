defmodule Util do
  @moduledoc """
  Funciones de entrada y salida por consola reutilizables en distintos programas.
  Permite leer texto, enteros y flotantes, e imprimir mensajes normales y de error.
  - autor: Carlos Andrés Florez V.
  - fecha: Octubre del 2026
  """

  @doc """
  Muestra `mensaje` como solicitud, lee una línea ingresada por el usuario y la
  devuelve convertida al tipo indicado.

  - `:string` devuelve el texto sin espacios ni saltos de línea al inicio y al final.
  - `:integer` y `:float` devuelven el número leído. Si la entrada no es un número
    válido del tipo solicitado, se informa el error y se vuelve a solicitar el dato
    hasta que sea correcto.

  Una entrada como `"40 horas"` se considera inválida, ya que contiene caracteres
  adicionales después del número.

  ## Ejemplo

      iex> Util.leer("Ingrese las horas trabajadas: ", :integer)
      Ingrese las horas trabajadas: 40
      40
  """
  def leer(mensaje, :string) do
    IO.gets(mensaje)
    |> String.trim()
  end

  def leer(mensaje, :integer) do
    leer_con_parser(mensaje, &Integer.parse/1) # Se pasa la función de parseo
  end

  def leer(mensaje, :float) do
    leer_con_parser(mensaje, &Float.parse/1)
  end

  # Lee una línea, la convierte con la función recibida (Integer.parse/1 o Float.parse/1)
  # y vuelve a preguntar mientras la entrada no sea un número válido
  defp leer_con_parser(mensaje, funcion) do
    valor = IO.gets(mensaje)
    |> String.trim()
    |> funcion.() # Se ejecuta la función de parseo

    case valor do
      {numero, ""} -> numero
      _ ->
        imprimir("Entrada inválida. Debe escribir un número.", :error)
        leer_con_parser(mensaje, funcion) # Se vuelve a preguntar hasta recibir un valor válido
    end
  end

  @doc """
  Imprime `mensaje` en la salida de errores (`:standard_error`), separada de la
  salida normal del programa.

  ## Ejemplo

      iex> Util.imprimir("El valor ingresado no es válido.", :error)
      El valor ingresado no es válido.
      :ok
  """
  def imprimir(mensaje, :error) do
    IO.puts(:standard_error, mensaje)
  end

  @doc """
  Imprime `mensaje` en la salida estándar.

  ## Ejemplo

      iex> Util.imprimir("Hola")
      Hola
      :ok
  """
  def imprimir(mensaje) do
    IO.puts(mensaje)
  end

end

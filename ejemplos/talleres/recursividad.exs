defmodule Listas do
  @moduledoc """
  Funciones básicas para el procesamiento recursivo de listas.
  """

  def main do
    IO.puts(sumar([1, 2, 3, 1, 5, 9], 0))
  end

  @doc """
  Calcula la suma de los elementos de una lista de enteros utilizando recursividad de cola.

  La función emplea un acumulador (`acc`) para mantener la suma parcial en cada llamada,
  lo que permite una ejecución eficiente en términos de memoria.

  ## Estrategia

  - Caso base: cuando la lista está vacía, se retorna el valor acumulado.
  - Caso recursivo: se descompone la lista en cabeza (`head`) y cola (`tail`),
    se suma el valor de `head` al acumulador y se continúa con el resto de la lista.

  ## Ejemplos
      iex> sumar([1, 2, 3, 4], 0)
      10

      iex> sumar([], 0)
      0
  """
  def sumar([], acc), do: acc

  def sumar([head | tail], acc), do: sumar(tail, acc + head)
end

defmodule DivisionNormal do
  @moduledoc """
  Módulo para dividir dos números enteros usando recursividad.
  """

  def main do
    IO.inspect(dividir(20, 7))
  end

  @doc """
  Resta el divisor del dividendo hasta que el dividendo sea menor que el divisor, contando cuántas veces se ha restado.
  Devuelve el cociente. Si el divisor es 0, devuelve un error.
  ## Ejemplo:
      iex> DivisionNormal.dividir(10, 3)
      3
      iex> DivisionNormal.dividir(20, 4)
      5
      iex> DivisionNormal.dividir(5, 0)
      :indeterminado
  """
  def dividir(_a, 0), do: :indeterminado
  def dividir(a, b) when b > a, do: 0
  def dividir(a, b), do: 1 + dividir(a - b, b)
end

defmodule DivisionTail do
  @moduledoc """
  Módulo para dividir dos números enteros usando recursividad.
  """

  def main do
    IO.inspect(dividir(12, 7))
  end

  @doc """
  Resta el divisor del dividendo hasta que el dividendo sea menor que el divisor, contando cuántas veces se ha restado.
  Devuelve una tupla con el cociente y el resto. Si el divisor es 0, devuelve un error.
  ## Ejemplo:
      iex> DivisionTail.dividir(10, 3)
      {3, 1}
      iex> DivisionTail.dividir(20, 4)
      {5, 0}
      iex> DivisionTail.dividir(5, 0)
      {:error, "División por cero"}
  """
  def dividir(_a, 0), do: {:error, "División por cero"}
  def dividir(a, b), do: dividir(a, b, 0)

  defp dividir(a, b, result) when a >= b, do: dividir(a - b, b, result + 1)
  defp dividir(a, _b, result), do: {result, a}
end

defmodule Primos do
  @moduledoc """
  Módulo para sumar números primos en una lista usando recursividad. Un número primo es aquel que solo es divisible por 1 y por sí mismo.
  """

  def main do
    IO.puts(sumar_primos([9, 10, 20]))
  end

  @doc """
  Recorre la lista y suma los números primos usando una función auxiliar para determinar si un número es primo.
  ## Ejemplo:
      iex> Primos.sumar_primos([1, 2, 3, 4, 5])
      10
      iex> Primos.sumar_primos([10, 15, 20])
      0
  """
  def sumar_primos([]), do: 0

  def sumar_primos([head | tail]) do
    if es_primo?(head, div(head, 2)) do
      head + sumar_primos(tail)
    else
      sumar_primos(tail)
    end
  end

  # 0 y 1 no son primos
  defp es_primo?(num, _) when num < 2, do: false

  # Caso base: no se encontraron divisores
  defp es_primo?(_num, divisor) when divisor < 2, do: true

  # Si es divisible, no es primo
  defp es_primo?(num, divisor) when rem(num, divisor) == 0, do: false

  # Seguir probando con el siguiente divisor
  defp es_primo?(num, divisor), do: es_primo?(num, divisor - 1)
end

defmodule Palindroma do
  @moduledoc """
  Módulo para determinar si una cadena de texto es un palíndromo usando recursividad.
  Un palíndromo es una palabra o frase que se lee igual de izquierda a derecha que de derecha a izquierda.
  """

  def main do
    IO.puts(es_palindroma?("mesa"))
  end

  @doc """
  Determina si una cadena es un palíndromo mediante un enfoque recursivo
  basado en la comparación de sus caracteres extremos.

  En cada llamada:
  - Se obtiene el primer y el último caracter de la cadena.
  - Si ambos son iguales, se realiza una llamada recursiva con la subcadena
    resultante de eliminar dichos caracteres.
  - Si son diferentes, la función retorna `false`.

  La recursión finaliza cuando la cadena está vacía (o implícitamente cuando
  queda un solo caracter), caso en el cual se considera un palíndromo y se retorna `true`.

  ## Ejemplos
      iex> es_palindroma?("radar")
      true

      iex> es_palindroma?("mesa")
      false
  """
  def es_palindroma?(""), do: true

  def es_palindroma?(cadena) do
    primer = String.first(cadena)
    ultimo = String.last(cadena)

    if primer == ultimo do
      es_palindroma?(String.slice(cadena, 1..-2//1))
    else
      false
    end
  end
end

defmodule Palindroma2 do
  @moduledoc """
  Módulo para determinar si una cadena de texto es un palíndromo usando recursividad.
  Un palíndromo es una palabra o frase que se lee igual de izquierda a derecha que de derecha a izquierda.
  """

  def main do
    IO.puts(es_palindroma?("radar"))
  end

  @doc """
  Determina si una cadena es un palíndromo convirtiéndola en una lista de grafemas
  y comparándola recursivamente con su versión invertida.

  El proceso consiste en:
  - Transformar la cadena en una lista de grafemas.
  - Generar una copia invertida de dicha lista.
  - Comparar ambas listas elemento a elemento mediante recursividad:
    - Si los elementos correspondientes son iguales, se continúa con las colas.
    - Si en algún punto difieren, se retorna `false`.

  La recursión finaliza cuando ambas listas quedan vacías, lo que indica que
  todos los caracteres coincidieron y, por tanto, la cadena es un palíndromo.

  ## Ejemplos
      iex> es_palindroma?("radar")
      true

      iex> es_palindroma?("mesa")
      false
  """
  def es_palindroma?(""), do: true

  def es_palindroma?(cadena) do
    lista = String.graphemes(cadena)
    invertida = Enum.reverse(lista)
    comparar(lista, invertida)
  end

  defp comparar([], []), do: true
  defp comparar([h1 | _t1], [h2 | _t2]) when h1 != h2, do: false
  defp comparar([_h1 | t1], [_h2 | t2]), do: comparar(t1, t2)
end

Palindroma2.main()

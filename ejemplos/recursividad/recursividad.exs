defmodule Cadena do
  @moduledoc """
  Módulo para invertir una cadena de texto usando recursividad. Es una alternativa a la función String.reverse/1.
  """

  @doc """
  Función principal que llama a la función auxiliar con los parámetros iniciales y devuelve la cadena invertida.
  Se usa recursividad de cola, pasando la respuesta como parámetro.
  ## Ejemplo:
      iex> Cadena.invertir("hola")
      "aloh"
  """
  def invertir(cadena), do: invertir_aux(cadena, "")

  defp invertir_aux("", respuesta), do: respuesta
  defp invertir_aux(cadena, respuesta) do
    resto_cadena = String.slice(cadena, 0..-2//1)
    invertir_aux(resto_cadena, respuesta <> String.last(cadena) )
  end

end

defmodule Division do
  @moduledoc """
  Módulo para dividir dos números enteros usando recursividad.
  """

  @doc """
  Resta el divisor del dividendo hasta que el dividendo sea menor que el divisor, contando cuántas veces se ha restado.
  Devuelve una tupla con el cociente y el resto. Si el divisor es 0, devuelve un error.
  ## Ejemplo:
      iex> Division.dividir(10, 3)
      {3, 1}
      iex> Division.dividir(20, 4)
      {5, 0}
      iex> Division.dividir(5, 0)
      {:error, "División por cero"}
  """
  def dividir(_a, 0), do: {:error, "División por cero"}
  def dividir(a, b), do: dividir(a, b, 0)

  defp dividir(a, b, result) when a >= b, do: dividir(a-b, b, result+1)
  defp dividir(a, _b, result), do: {result, a}

end

defmodule Primos do
  @moduledoc """
  Módulo para sumar números primos en una lista usando recursividad. Un número primo es aquel que solo es divisible por 1 y por sí mismo.
  """

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
    case es_primo?(head) do
      true -> head + sumar_primos(tail)
      _ -> sumar_primos(tail)
    end
  end

  defp es_primo?(n), do: es_primo?(n, 2)

  defp es_primo?(n, i) when i*i > n, do: true
  defp es_primo?(n, i) when rem(n, i) == 0, do: false
  defp es_primo?(n, i), do: es_primo?(n, i+1)

end

defmodule ContarNumeros do
  @moduledoc """
  Módulo para contar cuántas veces aparece un número en una lista usando recursividad.
  """

  @doc """
  Función principal que llama a la función auxiliar con los parámetros iniciales y devuelve el número de veces que aparece el elemento en la lista.
  ## Ejemplo:
      iex> ContarNumeros.contar_repeticiones([1, 2, 3, 2, 4, 2], 2)
      3
      iex> ContarNumeros.contar_repeticiones([5, 6, 7], 4)
      0
  """
  def contar_repeticiones(lista, numero), do: contar_repeticiones(lista, numero, 0) #Recursividad de cola, se pasa el contador como parámetro

  defp contar_repeticiones([], _numero, contador), do: contador
  defp contar_repeticiones([head | tail], numero, contador) when head == numero, do: contar_repeticiones(tail, numero, contador+1)
  defp contar_repeticiones([_head | tail], numero, contador), do: contar_repeticiones(tail, numero, contador)

end

defmodule Vocales do
  @moduledoc """
  Módulo para contar el número de vocales en una cadena de texto usando recursividad.
  """

  @doc """
  Se usa String.first y String.slice para separar la cadena en el primer carácter y el resto de la cadena.
  Si el primer carácter es una vocal, se suma 1 y se llama recursivamente con el resto de la cadena.
  ## Ejemplo:
      iex> Vocales.contar_vocales("Hola Mundo")
      4
      iex> Vocales.contar_vocales("Elixir es genial")
      7
  """
  def contar_vocales(""), do: 0
  def contar_vocales(cadena) do
    inicio = String.first(cadena)
    resto = String.slice(cadena, 1..-1//1)

    if inicio in ["a", "e", "i", "o", "u"] do
      1 + contar_vocales(resto)
    else
      contar_vocales(resto)
    end

  end

end

defmodule Vocales2 do
  @moduledoc """
  Módulo para contar el número de vocales en una cadena de texto usando recursividad.
  """

  @doc """
  Función principal que llama a la función auxiliar y le pasa la cadena convertida a minúsculas y separada en una lista de caracteres.
  Se usa String.graphemes para separar la cadena en una lista de caracteres y luego se cuenta recursivamente.
  ## Ejemplo:
      iex> Vocales2.contar_vocales("Hola Mundo")
      4
      iex> Vocales2.contar_vocales("Elixir es genial")
      7
  """
  def contar_vocales(cadena) do
    cadena
    |> String.downcase()
    |> String.graphemes()
    |> contar_vocales_aux()
  end

  defp contar_vocales_aux([]), do: 0
  defp contar_vocales_aux([head | tail ]) when head in ["a", "e", "i", "o", "u"], do: 1+contar_vocales_aux(tail)
  defp contar_vocales_aux([_head | tail ]), do: contar_vocales_aux(tail)

end

defmodule Palindroma do
  @moduledoc """
  Módulo para determinar si una cadena de texto es un palíndromo usando recursividad.
  Un palíndromo es una palabra o frase que se lee igual de izquierda a derecha que de derecha a izquierda.
  """

  @doc """
  Función principal que convierta la cadena a minúsculas y elimina los espacios, luego llama a la función auxiliar para verificar si es un palíndromo.
  ## Ejemplo:
      iex> Palindroma.es_palindroma?("Anita lava la tina")
      true
      iex> Palindroma.es_palindroma?("Hola")
      false
  """
  def es_palindroma?(cadena) do

    cadena
    |> String.replace(" ", "")
    |> String.downcase()
    |> es_palindroma_aux?()
  end

  defp es_palindroma_aux?(""), do: true
  defp es_palindroma_aux?(cadena) do
    primero = String.first(cadena)
    ultimo = String.last(cadena)
    case primero == ultimo do
      true -> es_palindroma_aux?( String.slice(cadena, 1..-2//1) )
      _ -> false
    end
  end

end

defmodule Palindroma2 do
  @moduledoc """
  Módulo para determinar si una cadena de texto es un palíndromo usando recursividad.
  Un palíndromo es una palabra o frase que se lee igual de izquierda a derecha que de derecha a izquierda.
  """

  @doc """
  Función principal que convierta la cadena a minúsculas y elimina los espacios, luego convierte la cadena en una lista de caracteres y llama a la función auxiliar para verificar si es un palíndromo.
  ## Ejemplo:
      iex> Palindroma2.es_palindroma?("Anita lava la tina")
      true
      iex> Palindroma2.es_palindroma?("Hola")
      false
  """
  def es_palindroma?(cadena) do
    cadena
    |> String.replace(" ", "")
    |> String.downcase()
    |> String.graphemes()
    |> es_palindroma_aux?()
  end

  defp es_palindroma_aux?([]), do: true
  defp es_palindroma_aux?([_]), do: true
  defp es_palindroma_aux?([head | tail]) do
    case head == List.last(tail) do
      true -> es_palindroma_aux?( Enum.slice(tail, 0..-2//1) )
      _ -> false
    end
  end

end

defmodule Perfecto do
  @moduledoc """
  Módulo para determinar si un número es perfecto usando recursividad. Un número perfecto es aquel que es igual a la suma de sus divisores propios (excluyendo el mismo número).
  """

  @doc """
  Función principal que llama a la función auxiliar con los parámetros iniciales y devuelve true si el número es perfecto, false en caso contrario.
  ## Ejemplo:
      iex> Perfecto.es_perfecto?(6)
      true
      iex> Perfecto.es_perfecto?(28)
      true
      iex> Perfecto.es_perfecto?(12)
      false
  """
  def es_perfecto?(n), do: es_perfecto(n, 1, 0)

  defp es_perfecto(n, i, suma) when i > div(n, 2), do: suma == n
  defp es_perfecto(n, i, suma) when rem(n, i) == 0, do: es_perfecto(n, i+1, suma+i)
  defp es_perfecto(n, i, suma), do: es_perfecto(n, i+1, suma)

end

defmodule CadenaPares do
  @moduledoc """
  Módulo para extraer los caracteres en posiciones pares de una lista usando recursividad.
  """

  @doc """
  Se recorre la lista y se concatenan los caracteres en posiciones pares usando una función auxiliar que lleva un índice y una cadena acumuladora.
  ## Ejemplo:
      iex> CadenaPares.obtener_cadena([1, 2, 3, 4, 5])
      "135"
  """
  def obtener_cadena(lista), do: obtener_cadena(lista, 0)

  defp obtener_cadena([], _i) , do: ""
  defp obtener_cadena([head | tail], i) when rem(i, 2) == 0, do: to_string(head)<>obtener_cadena(tail, i+1)
  defp obtener_cadena([_head | tail], i), do: obtener_cadena(tail, i+1)

end

defmodule Digitos do
  @moduledoc """
  Módulo para contar el número de dígitos de un número usando recursividad.
  """

  @doc """
  Se divide el número entre 10 hasta que el número sea 0, contando cuántas veces se ha dividido. Si el número es 0, devuelve 0.
  ## Ejemplo:
      iex> Digitos.contar_digitos(73910)
      5
      iex> Digitos.contar_digitos(0)
      0
  """
  def contar_digitos(0), do: 0
  def contar_digitos(numero), do: 1+contar_digitos( div(numero, 10) )

end

defmodule Potencia do
  @moduledoc """
  Módulo para determinar si un número es una potencia de otro usando recursividad.
  Un número n es una potencia de b si existe un entero k tal que n = b^k.
  """

  @doc """
  Se divide n entre b hasta que n sea 1 (en cuyo caso es una potencia) o hasta que n no sea divisible por b (en cuyo caso no es una potencia).
  Si n es 1, devuelve true. Si n no es divisible por b, devuelve false. En otro caso, llama recursivamente con n dividido entre b.
  ## Ejemplo:
      iex> Potencia.es_potencia?(27, 3)
      true
      iex> Potencia.es_potencia?(16, 2)
      true
      iex> Potencia.es_potencia?(20, 2)
      false
  """
  def es_potencia?(n, _b) when n == 1, do: true
  def es_potencia?(n, b) when rem(n, b) != 0, do: false
  def es_potencia?(n, b), do: es_potencia?(div(n, b), b)

end

defmodule CadenaLarga do
  @moduledoc """
  Módulo para encontrar la cadena más larga en una lista de cadenas usando recursividad.
  """

  @doc """
  Se recorre la lista y se compara la longitud de cada cadena con la cadena más larga encontrada hasta el momento usando una función auxiliar que lleva la cadena más larga como parámetro.
  ## Ejemplo:
      iex> CadenaLarga.obtener_cadena(["hola", "mundo", "elixir", "es", "genial"])
      "genial"
      iex> CadenaLarga.obtener_cadena(["a", "ab", "abc", "abcd"])
      "abcd"
  """
  def obtener_cadena(lista), do: obtener_cadena(lista, "")

  defp obtener_cadena([], mayor) , do: mayor
  defp obtener_cadena([head | tail], mayor) do
    if String.length(head) > String.length(mayor) do
      obtener_cadena(tail, head)
    else
      obtener_cadena(tail, mayor)
    end
  end

end

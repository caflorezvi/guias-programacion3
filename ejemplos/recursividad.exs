defmodule Division do

  def dividir(_a, 0), do: {:error, "División por cero"}
  def dividir(a, b), do: dividir(a, b, 0)

  defp dividir(a, b, result) when a >= b, do: dividir(a-b, b, result+1)
  defp dividir(a, _b, result), do: {result, a}

end

defmodule Primos do

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

defmodule Vocales do

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

  def es_perfecto?(n), do: es_perfecto(n, 1, 0)

  defp es_perfecto(n, i, suma) when i > div(n, 2), do: suma == n
  defp es_perfecto(n, i, suma) when rem(n, i) == 0, do: es_perfecto(n, i+1, suma+i)
  defp es_perfecto(n, i, suma), do: es_perfecto(n, i+1, suma)

end

defmodule CadenaPares do

  def obtener_cadena(lista), do: obtener_cadena(lista, 0)

  defp obtener_cadena([], _i) , do: ""
  defp obtener_cadena([head | tail], i) when rem(i, 2) == 0, do: to_string(head)<>obtener_cadena(tail, i+1)
  defp obtener_cadena([_head | tail], i), do: obtener_cadena(tail, i+1)

end

defmodule Digitos do

  def contar_digitos(0), do: 0
  def contar_digitos(numero), do: 1+contar_digitos( div(numero, 10) )

end

IO.inspect( Cadena.procesar(["Elixir", "es", "un", "lenguaje", "funcional", "muy", "poderoso"]) )

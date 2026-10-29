defmodule Tombola do
  @minimo 1
  @maximo 10

  def main do
    "Ingrese el número con el que desea participar (#{@minimo} a #{@maximo}): "
    |> Util.leer(:integer)
    |> participar()
    |> Util.imprimir()
  end

  defp participar(numero) when numero in @minimo..@maximo do
    numero
    |> calcular_diferencia()
    |> evaluar_resultado()
  end

  defp participar(_), do: "Número no válido, el recibo no participa en la tómbola."

  defp calcular_diferencia(numero_cliente) do
    numero_ganador = :rand.uniform(@maximo) # Genera un número aleatorio entre 1 y @maximo
    abs(numero_cliente - numero_ganador) # Devuelve el valor absoluto de la diferencia
  end

  defp evaluar_resultado(0), do: "¡Felicidades, su mercado es gratis!"
  defp evaluar_resultado(diferencia), do: "Lo siento, no ganó. La diferencia fue de #{diferencia}."
end

Tombola.main()

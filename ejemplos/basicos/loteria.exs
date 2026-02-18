defmodule Loteria do
  @minimo 1
  @maximo 10

  def main do
    "Ingrese un número entre #{@minimo} y #{@maximo}: "
    |> Util.leer(:integer)
    |> jugar()
    |> Util.imprimir()
  end

  defp jugar(numero) when numero >= @minimo and numero <= @maximo do
    numero
    |> calcular_diferencia()
    |> evaluar_resultado()
  end

  defp jugar(_), do: "Número no válido, fin del juego."

  defp calcular_diferencia(numero_usuario) do
    numero_ganador = :rand.uniform(@maximo) # Genera un número aleatorio entre 1 y @maximo
    abs(numero_usuario - numero_ganador) # Devuelve el valor absoluto de la diferencia
  end

  defp evaluar_resultado(0), do: "¡Felicidades, has ganado!"
  defp evaluar_resultado(diferencia), do: "Lo siento, has perdido. La diferencia fue de #{diferencia}."
end

Loteria.main()

defmodule Loteria do
  @minimo 1
  @maximo 10

  def main do
    numero = Util.leer("Ingrese un número entre #{@minimo} y #{@maximo}: ", :integer)

    numero
    |> validar_y_jugar()
    |> Util.imprimir()
  end

  defp validar_y_jugar(numero) when numero >= @minimo and numero <= @maximo do
    ejecutar_sorteo(numero)
  end

  defp validar_y_jugar(_numero), do: "Número no válido, fin del juego."

  defp ejecutar_sorteo(numero_usuario) do
    numero_ganador = :rand.uniform(@maximo)
    diferencia = abs(numero_usuario - numero_ganador)
    evaluar_resultado(diferencia)
  end

  defp evaluar_resultado(diferencia) do
    case diferencia do
      0 -> mostrar_victoria()
      _ -> mostrar_derrota(diferencia)
    end
  end

  defp mostrar_victoria, do: "¡Felicidades, has ganado!"

  defp mostrar_derrota(diferencia), do: "Lo siento, has perdido. La diferencia fue de #{diferencia}."

end

Loteria.main()

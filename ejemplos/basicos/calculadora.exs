defmodule Calculadora do

  def main do
    numero1 = Util.leer("Ingrese el primer número: ", :integer)
    numero2 = Util.leer("Ingrese el segundo número: ", :integer)
    operacion = Util.leer("Escriba 1 para suma, 2 para resta, 3 para multiplicación, 4 para división: ", :integer)

    validar_operacion(numero1, numero2, operacion)
    |> mostrar_resultado()
  end

  defp validar_operacion(numero1, numero2, operacion) when operacion in 1..4 do
    operar(numero1, numero2, operacion)
  end

  defp validar_operacion(_, _, _), do: {:error, "Operación no válida."}

  defp operar(numero1, numero2, 1), do: {:ok, numero1 + numero2}
  defp operar(numero1, numero2, 2), do: {:ok, numero1 - numero2}
  defp operar(numero1, numero2, 3), do: {:ok, numero1 * numero2}
  defp operar(_numero1, 0, 4), do: {:error, "División por cero no permitida."}
  defp operar(numero1, numero2, 4), do: {:ok, numero1 / numero2}

  defp mostrar_resultado({:ok, resultado}), do: Util.imprimir("El resultado es: #{resultado}")
  defp mostrar_resultado({:error, mensaje}), do: Util.imprimir("Error: #{mensaje}", :error)

end

Calculadora.main()

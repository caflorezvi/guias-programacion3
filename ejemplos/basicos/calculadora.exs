defmodule Calculadora do

  def main do
    numero1 = Util.leer("Ingrese el primer número: ", :integer)
    numero2 = Util.leer("Ingrese el segundo número: ", :integer)
    operacion = Util.leer("Escriba 1 para suma, 2 para resta, 3 para multiplicación, 4 para división: ", :integer)

    validar_operacion(numero1, numero2, operacion)
    |> generar_mensaje()
    |> Util.imprimir_mensaje()
  end

  def validar_operacion(numero1, numero2, operacion) when operacion in 1..4 do
    operar(numero1, numero2, operacion)
  end

  def validar_operacion(_, _, _), do: {:error, "Operación no válida."}

  defp operar(numero1, numero2, 1), do: {:ok, numero1 + numero2}
  defp operar(numero1, numero2, 2), do: {:ok, numero1 - numero2}
  defp operar(numero1, numero2, 3), do: {:ok, numero1 * numero2}
  defp operar(_numero1, 0, 4), do: {:error, "División por cero no permitida."}
  defp operar(numero1, numero2, 4), do: {:ok, numero1 / numero2}
  defp operar(_, _, _), do: {:error, "Operación no válida."}

  def generar_mensaje({:ok, resultado}) do
    "El resultado es: #{resultado}"
  end

  def generar_mensaje({:error, mensaje}) do
    "Error: #{mensaje}"
  end

end

Calculadora.main()

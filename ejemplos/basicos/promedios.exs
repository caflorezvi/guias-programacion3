defmodule Notas do

  def main do
    "Ingrese 1 para calcular la nota del curso 1 (promedio) o 2 para la nota del curso 2 (porcentajes): "
    |> Util.leer(:integer)
    |> procesar()
    |> Util.imprimir_mensaje()
  end

  defp procesar(curso) when curso == 1 or curso == 2, do: calcular_y_generar_mensaje(curso)
  defp procesar(_), do: "Error, curso incorrecto"

  defp calcular_y_generar_mensaje(curso) do
    notas = leer_notas()
    nota_final = calcular_nota(curso, notas)

    aprobado?(nota_final)
    |> generar_mensaje(nota_final)
  end

  defp leer_notas do
    n1 = Util.leer("Ingrese la nota 1: ", :float)
    n2 = Util.leer("Ingrese la nota 2: ", :float)
    n3 = Util.leer("Ingrese la nota 3: ", :float)
    n4 = Util.leer("Ingrese la nota 4: ", :float)

    {n1, n2, n3, n4}
  end

  defp calcular_nota(1, {n1, n2, n3, n4}), do: (n1 + n2 + n3 + n4) / 4
  defp calcular_nota(2, {n1, n2, n3, n4}), do: n1 * 0.15 + n2 * 0.30 + n3 * 0.35 + n4 * 0.20

  defp aprobado?(nota), do: nota >= 3.0

  defp generar_mensaje(true, nota), do: "El estudiante aprobó el curso con una nota final de #{Float.round(nota, 2)}."
  defp generar_mensaje(false, nota), do: "El estudiante no aprobó el curso. La nota final fue #{Float.round(nota, 2)}."

end

Notas.main()

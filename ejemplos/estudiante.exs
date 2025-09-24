defmodule Notas do

  def main do
    n1 = Util.leer("Ingrese la nota 1: ", :float)
    n2 = Util.leer("Ingrese la nota 2: ", :float)
    n3 = Util.leer("Ingrese la nota 3: ", :float)
    n4 = Util.leer("Ingrese la nota 4: ", :float)

    nota_final = calcular_nota_curso_1(n1, n2, n3, n4)
    es_aprobado = aprobado?(nota_final)

    generar_mensaje(es_aprobado, nota_final)
    |> Util.imprimir()

  end

  defp calcular_nota_curso_1(n1, n2, n3, n4) do
    (n1 + n2 + n3 + n4) / 4
  end

  defp calcular_nota_curso_2(n1, n2, n3, n4) do
    (n1 * 0.15 + n2 * 0.30 + n3 * 0.35 + n4 * 0.20)
  end

  defp aprobado?(nota), do: nota >= 3.0

  defp generar_mensaje(true, nota) do
    "El estudiante aprobó el curso con una nota de #{nota}."
  end

  defp generar_mensaje(false, nota) do
    "El estudiante no aprobó el curso con una nota de #{nota}."
  end

end

Notas.main()

defmodule Notas do
  def main do
    Util.leer("Escriba 1 para calcular la nota definitiva del curso 1, o 2 para el curso 2: ", :integer)
    |> procesar_curso()
    |> Util.imprimir_mensaje()
  end

  defp procesar_curso(curso) when curso not in 1..2 do
    "El valor ingresado es incorrecto"
  end

  defp procesar_curso(curso) do
    notas = pedir_datos()
    calcular_promedio(curso, notas)
    |> generar_mensaje()
  end

  defp pedir_datos do
    nota1 = Util.leer("Ingrese la nota 1: ", :float)
    nota2 = Util.leer("Ingrese la nota 2: ", :float)
    nota3 = Util.leer("Ingrese la nota 3: ", :float)
    nota4 = Util.leer("Ingrese la nota 4: ", :float)
    {nota1, nota2, nota3, nota4}
  end

  defp calcular_promedio(1, {n1, n2, n3, n4}), do: (n1 + n2 + n3 + n4) / 4
  defp calcular_promedio(2, {n1, n2, n3, n4}), do: n1 * 0.15 + n2 * 0.3 + n3 * 0.35 + n4 * 0.2

  defp generar_mensaje(promedio) when promedio >= 3, do: "Su nota definitiva es: #{promedio} por lo tanto ha aprobado"
  defp generar_mensaje(promedio),do: "Su nota definitiva es: #{promedio} por lo tanto ha reprobado"

end

Notas.main()

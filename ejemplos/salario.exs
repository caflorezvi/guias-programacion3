defmodule Salario do

  def main do
    nombre = "Ingrese el nombre del empleado: "
    |> Util.leer(:string)

    horas_trabajadas = "Ingrese las horas trabajadas: "
    |> Util.leer(:integer)

    valor_por_hora = "Ingrese el valor por hora: "
    |> Util.leer(:float)

    salario = calcular_salario(horas_trabajadas, valor_por_hora)
    |> formatear_salario

    generar_mensaje(nombre, salario)
    |> Util.imprimir_mensaje
  end

  defp calcular_salario(horas_trabajadas, valor_por_hora), do: horas_trabajadas * valor_por_hora
  defp generar_mensaje(nombre, salario), do: "El salario de #{nombre} es: $#{salario}"
  defp formatear_salario(salario), do: :erlang.float_to_binary(salario, decimals: 2)

end

Salario.main()

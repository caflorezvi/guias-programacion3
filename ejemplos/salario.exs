defmodule Salario do

  def main do
    nombre = "Ingrese el nombre del empleado: "
    |> Util.leer(:string)

    horas_trabajadas = "Ingrese las horas trabajadas: "
    |> Util.leer(:integer)

    valor_por_hora = "Ingrese el valor por hora: "
    |> Util.leer(:float)

    salario = calcular_salario(horas_trabajadas, valor_por_hora)

    generar_mensaje(nombre, salario)
    |> Util.imprimir_mensaje
  end

  defp calcular_salario(horas_trabajadas, valor_por_hora) do
    horas_trabajadas * valor_por_hora
  end

  defp generar_mensaje(nombre, salario) do
    "El salario de #{nombre} es: $#{salario}"
  end

end

defmodule Util do

  def leer(mensaje, :string) do
    IO.gets(mensaje)
    |> String.trim()
  end

  def leer(mensaje, :integer) do
    leer_con_parser(mensaje, fn valor -> Integer.parse(valor) end)
  end

  def leer(mensaje, :float) do
    leer_con_parser(mensaje, &Float.parse/1)
  end

  defp leer_con_parser(mensaje, parser) do
    valor = IO.gets(mensaje)
    |> String.trim()
    |> parser.()

    case valor do
      {numero, _} -> numero
      :error ->
        imprimir_error("Error. Se utilizará 0 como valor predeterminado.")
        0
    end
  end

  def imprimir_error(mensaje) do
    IO.puts(:standard_error, mensaje)
  end

  def imprimir_mensaje(mensaje) do
    IO.puts(mensaje)
  end

end

Salario.main()

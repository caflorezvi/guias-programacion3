defmodule Estudiantes do

  def main do
    notas = [
      %{nombre: "pepito", nota: 1},
      %{nombre: "carlos", nota: 5},
      %{nombre: "lucas", nota: 4},
      %{nombre: "pedro", nota: 3.5},
      %{nombre: "maria", nota: 4.1},
      %{nombre: "juan", nota: 2},
    ]

    promedio = calcular_promedio(notas)

    Util.imprimir_mensaje(promedio)

    total_segun_promedio(notas, promedio)
    |>generar_mensaje()
    |> Util.imprimir_mensaje()

    obtener_nota_maxima_minima(notas)
    |> generar_mensaje_nota()
    |> Util.imprimir_mensaje()

    generar_lista_aprobados(notas)
    |> IO.inspect()

  end

  def generar_mensaje_nota({ %{nombre: estudiante1, nota: nota1} , %{nombre: estudiante2, nota: nota2} }) do
    "La nota más baja es #{nota1} que le pertenece a #{estudiante1}, " <>
    "La nota más alta es #{nota2} que le pertenece a #{estudiante2}"
  end

  def generar_mensaje({debajo, encima}) do
    "Hay #{debajo} estudiantes con una nota menor al promedio y #{encima} estudiantes con una nota mayor al promedio"
  end

  def calcular_promedio(lista) do

    suma_notas = Enum.map(lista, fn estudiante -> estudiante.nota end)
    |> Enum.sum()

    suma_notas / length(lista)
  end

  def generar_lista_aprobados(lista) do

    Enum.map(lista, fn estudiante ->

      cond do
        estudiante.nota >= 3 -> { estudiante.nombre, :aprobado }
        true -> { estudiante.nombre, :reprobado }
      end
    end

    )

  end

  def obtener_nota_maxima_minima(lista) do
    min = Enum.min_by(lista, fn estudiante -> estudiante.nota end)
    max = Enum.max_by(lista, &(&1.nota))
    {min, max}
  end

  def total_segun_promedio(lista, promedio) do
    encima = Enum.count(lista, &(&1.nota > promedio) ) #Función anónima - Lambda
    debajo = Enum.count(lista, fn estudiante -> estudiante.nota < promedio end )

    {debajo, encima}
  end

  def contar_aprobados(lista) do
    aprobados = Enum.count(lista, fn estudiante -> estudiante.nota >= 3 end)
    {aprobados, length(lista)-aprobados}
  end

end

Estudiantes.main()

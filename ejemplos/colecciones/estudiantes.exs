defmodule Estudiantes do
  def main do
    lista = estudiantes_del_curso()

    promedio = calcular_promedio(lista)
    IO.puts("El promedio es #{promedio}")

    {menores, mayores} = contar_segun_promedio(lista, promedio)
    IO.puts("Hay #{menores} por debajo del promedio y #{mayores} por encima")

    {menor, mayor} = obtener_estudiantes_min_max(lista)
    IO.puts("La nota más baja es de #{menor.nombre} (#{menor.nota}) y la más alta es de #{mayor.nombre} (#{mayor.nota})")

    {aprobados, reprobados} = contar_aprobados_reprobados(lista)
    IO.puts("Aprobaron #{aprobados} estudiantes y reprobaron #{reprobados}")

    agregar_estado(lista)
    |> IO.inspect(label: "Estado de los estudiantes")

    ordenar_por_nota(lista)
    |> Enum.each(fn estudiante -> IO.puts("#{estudiante.nombre}: #{estudiante.nota}") end)

    distribucion_notas(lista)
    |> IO.inspect(label: "Distribución de notas")

    nombres_aprobados(lista)
    |> IO.inspect(label: "Aprobados")
  end

  defp estudiantes_del_curso do
    [
      %{nombre: "pepe", nota: 3},
      %{nombre: "maria", nota: 4},
      %{nombre: "juan", nota: 4.6},
      %{nombre: "luisa", nota: 1.6},
      %{nombre: "carlos", nota: 2.3},
      %{nombre: "ana", nota: 4.5},
      %{nombre: "marcos", nota: 1}
    ]
  end

  def calcular_promedio([]), do: 0

  def calcular_promedio(lista) do
    Enum.map(lista, fn estudiante -> estudiante.nota end) # Es necesario extraer la nota de cada estudiante
    |> Enum.sum()
    |> then(fn suma -> suma / length(lista) end) # then() permite encadenar operaciones
  end

  # Enum.min_max_by permite asociar una función para acceder a la nota
  defp obtener_estudiantes_min_max(lista), do: Enum.min_max_by(lista, fn estudiante -> estudiante.nota end)

  defp contar_segun_promedio(lista, promedio) do
    menores = Enum.count(lista, fn estudiante -> estudiante.nota < promedio end)
    mayores = Enum.count(lista, fn estudiante -> estudiante.nota > promedio end)
    {menores, mayores}
  end

  defp contar_aprobados_reprobados(lista) do
    total = length(lista)
    aprobados = Enum.count(lista, fn estudiante -> estudiante.nota >= 3 end)
    {aprobados, total - aprobados}
  end

  defp agregar_estado(lista) do
    Enum.map(lista, fn %{nombre: nombre, nota: nota} ->
      estado = if nota >= 3, do: :aprobado, else: :reprobado
      {nombre, estado}
    end)
  end

  defp ordenar_por_nota(lista) do
    Enum.sort_by(lista, fn estudiante -> estudiante.nota end, :desc)
  end

  # Para cada parte entera de la nota (0 a 5) se cuentan los estudiantes que la obtuvieron
  defp distribucion_notas(lista) do
    Enum.map(0..5, fn n ->
      {n, Enum.count(lista, fn estudiante -> trunc(estudiante.nota) == n end)}
    end)
  end

  defp nombres_aprobados(lista) do
    for %{nombre: nombre, nota: nota} <- lista, nota >= 3, do: nombre
  end
end

Estudiantes.main()

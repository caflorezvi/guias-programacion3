defmodule Estudiantes do
  def main do
    # Ahora tenemos una lista de mapas
    lista = [
      %{nombre: "pepe", nota: 3},
      %{nombre: "maria", nota: 4},
      %{nombre: "juan", nota: 4.6},
      %{nombre: "luisa", nota: 1.6},
      %{nombre: "carlos", nota: 2.3},
      %{nombre: "ana", nota: 4.5},
      %{nombre: "marcos", nota: 1},
    ]

    promedio = calcular_promedio(lista)
    Util.imprimir_mensaje("El promedio es #{promedio}")

    {menores, mayores} = total_segun_promedio(lista, promedio)
    Util.imprimir_mensaje("Hay #{menores} por debajo del promedio y #{mayores} por encima")

    {menor, mayor} = obtener_mejor_peor_nota(lista)
    Util.imprimir_mensaje("La nota más baja es de #{menor.nombre} (#{menor.nota}) y la más alta es de #{mayor.nombre} (#{mayor.nota})")

    {aprobados, reprobados} = aprobados_reprobados(lista)
    Util.imprimir_mensaje("Aprobaron #{aprobados} estudiantes y reprobaron #{reprobados}")

    IO.inspect( ordenar_lista(lista) )
  end

  defp calcular_promedio(lista) do
    Enum.map(lista, &(&1.nota)) # Es necesario extraer la nota de cada estudiante
    |> Enum.sum()
    |> then( &(&1/length(lista)) ) # then() permite encadenar operaciones
  end

  defp obtener_mejor_peor_nota(lista) do
    peor = Enum.min_by(lista, &(&1.nota)) # Enum.min_by permite asociar una función para acceder a la nota
    mejor = Enum.max_by(lista, &(&1.nota))
    {peor, mejor}
  end

  defp total_segun_promedio(lista, promedio) do
    menores = Enum.count(lista, &(&1.nota < promedio))
    mayores = Enum.count(lista, &(&1.nota > promedio))
    {menores, mayores}
  end

  defp aprobados_reprobados(lista) do
    total = length(lista)
    aprobados = Enum.count(lista, &(&1.nota>=3))
    {aprobados, total - aprobados}
  end

  defp agregar_estado(lista) do
    Enum.map(lista, fn %{nombre: nombre, nota: nota} ->

      estado = cond do
        nota >= 3 -> :aprobado
        true -> :reprobado
      end

      {nombre, estado }
    end)
  end

  defp agregar_estado_v2(lista) do
    Enum.map(lista, &({&1.nombre, if(&1.nota >= 3, do: :aprobado, else: :reprobado)}))
  end

  defp ordenar_lista(lista) do
    Enum.sort_by(lista, &(&1.nota), :desc)
  end

end

Estudiantes.main()

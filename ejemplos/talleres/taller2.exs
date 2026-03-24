defmodule Punto1 do
  def ejercicio1() do
    lista = ["Elixir", "es", "un", "lenguaje", "funcional", "muy", "poderoso"]

    resultado =
      Enum.map(lista, &String.upcase(&1))
      |> Enum.filter(fn w -> String.length(w) > 4 end)
      |> Enum.map(fn cadena -> String.reverse(cadena) end)
      |> Enum.sort()
      |> Enum.take(3)
      |> Enum.join(" - ")

    IO.puts(resultado)
  end

  def ejercicio2() do
    numeros = Enum.to_list(1..15)

    resultado =
      numeros
      |> Enum.filter(&(rem(&1, 3) == 0))
      |> Enum.map(&(&1 + 1))
      |> Enum.reduce({0, 0}, fn x, {suma, conteo} -> {suma + x, conteo + 1} end)
      |> then(fn {suma, conteo} -> suma / conteo end)

    IO.puts("Salida: #{resultado}")
  end

  def ejercicio3() do
    personas = [
      %{nombre: "Antonio", edad: 23},
      %{nombre: "Luis", edad: 30},
      %{nombre: "Marta", edad: 19},
      %{nombre: "Pedro", edad: 40},
      %{nombre: "Andrés", edad: 28},
      %{nombre: "Ana", edad: 35}
    ]

    resultado =
      personas
      |> Enum.filter(fn %{nombre: nombre, edad: edad} ->
        edad >= 21 and nombre |> String.downcase() |> String.starts_with?("a")
      end)
      |> Enum.map(fn %{nombre: nombre} -> String.upcase(nombre) end)
      |> Enum.sort_by(&String.length(&1))
      |> Enum.join(" | ")

    IO.puts(resultado)
  end
end

defmodule Punto2 do
  def main do
    vuelos = [
      %{
        codigo: "AV201",
        aerolinea: "Avianca",
        origen: "BOG",
        destino: "MDE",
        duracion: 45,
        precio: 180_000,
        pasajeros: 120,
        disponible: true
      },
      %{
        codigo: "LA305",
        aerolinea: "Latam",
        origen: "BOG",
        destino: "CLO",
        duracion: 55,
        precio: 210_000,
        pasajeros: 98,
        disponible: true
      },
      %{
        codigo: "AV410",
        aerolinea: "Avianca",
        origen: "MDE",
        destino: "CTG",
        duracion: 75,
        precio: 320_000,
        pasajeros: 134,
        disponible: false
      },
      %{
        codigo: "VV102",
        aerolinea: "Viva Air",
        origen: "BOG",
        destino: "BAQ",
        duracion: 90,
        precio: 145_000,
        pasajeros: 180,
        disponible: true
      },
      %{
        codigo: "LA512",
        aerolinea: "Latam",
        origen: "CLO",
        destino: "CTG",
        duracion: 110,
        precio: 480_000,
        pasajeros: 76,
        disponible: false
      },
      %{
        codigo: "AV330",
        aerolinea: "Avianca",
        origen: "BOG",
        destino: "CTG",
        duracion: 135,
        precio: 520_000,
        pasajeros: 155,
        disponible: true
      },
      %{
        codigo: "VV215",
        aerolinea: "Viva Air",
        origen: "MDE",
        destino: "BOG",
        duracion: 50,
        precio: 130_000,
        pasajeros: 190,
        disponible: true
      },
      %{
        codigo: "LA620",
        aerolinea: "Latam",
        origen: "BOG",
        destino: "MDE",
        duracion: 145,
        precio: 390_000,
        pasajeros: 112,
        disponible: true
      },
      %{
        codigo: "AV505",
        aerolinea: "Avianca",
        origen: "CTG",
        destino: "BOG",
        duracion: 120,
        precio: 440_000,
        pasajeros: 143,
        disponible: false
      },
      %{
        codigo: "VV340",
        aerolinea: "Viva Air",
        origen: "BAQ",
        destino: "BOG",
        duracion: 85,
        precio: 160_000,
        pasajeros: 175,
        disponible: true
      }
    ]

    ejercicio1 = filtrar_vuelos_disponibles(vuelos)
    ejercicio2 = agrupar_por_aerolinea(vuelos)
    ejercicio3 = crear_informe_vuelo(vuelos)
    ejercicio4 = filtrar_vuelos_precio(vuelos, 400_000)
    ejercicio5 = clasificar_vuelos_duracion(vuelos)
    ejercicio6 = ranking_rutas(vuelos)

    IO.inspect(ejercicio1, label: "Vuelos disponibles")
    IO.inspect(ejercicio2, label: "Pasajeros por aerolinea")
    IO.inspect(ejercicio3, label: "Informe vuelos")
    IO.inspect(ejercicio4, label: "Vuelos menores a un precio dado")
    IO.inspect(ejercicio5, label: "Clasificación de vuelos por duración")
    IO.inspect(ejercicio6, label: "Rutas más rentables")
  end

  defp filtrar_vuelos_disponibles(vuelos) do
    Enum.filter(vuelos, fn vuelo -> vuelo.disponible end)
    |> Enum.map(fn vuelo -> vuelo.codigo end)
    |> Enum.sort()
  end

  defp agrupar_por_aerolinea(vuelos) do
    Enum.group_by(vuelos, fn vuelo -> vuelo.aerolinea end)
    |> Enum.map(fn {aerolinea, lista} ->
      total_pasajeros = Enum.sum_by(lista, fn vuelo -> vuelo.pasajeros end)
      {aerolinea, total_pasajeros}
    end)
  end

  defp crear_informe_vuelo(vuelos) do
    Enum.map(vuelos, fn %{codigo: codigo, duracion: duracion, origen: origen, destino: destino} ->
      horas = div(duracion, 60)
      minutos = rem(duracion, 60)
      minutos_str = if minutos < 10, do: "0#{minutos}", else: "#{minutos}"

      "#{codigo} — #{origen} → #{destino}: #{horas}h #{minutos_str}m"
    end)
  end

  defp filtrar_vuelos_precio(vuelos, limite) do
    Enum.filter(vuelos, &(&1.precio < limite))
    |> Enum.map(fn vuelo ->
      nuevo_precio = vuelo.precio * 0.90
      {vuelo.codigo, "#{vuelo.origen}-#{vuelo.destino}", nuevo_precio}
    end)
    |> Enum.sort_by(fn {_codigo, _ruta, precio} -> precio end)
  end

  defp categorizar(duracion) when duracion < 60, do: :corto
  defp categorizar(duracion) when duracion <= 120, do: :medio
  defp categorizar(_duracion), do: :largo

  defp clasificar_vuelos_duracion(vuelos) do
    Enum.group_by(vuelos, fn vuelo -> vuelo.aerolinea end)
    |> Enum.filter(fn {_aerolinea, grupo} ->
      categorias =
        Enum.map(grupo, fn vuelo -> categorizar(vuelo.duracion) end)
        |> Enum.uniq()

      Enum.member?(categorias, :corto) and
        Enum.member?(categorias, :medio) and
        Enum.member?(categorias, :largo)
    end)
    |> Enum.map(fn {aerolinea, _grupo} -> aerolinea end)
  end

  defp ranking_rutas(vuelos) do
    Enum.filter(vuelos, & &1.disponible)
    |> Enum.map(fn v -> {"#{v.origen} → #{v.destino}", v.precio * v.pasajeros} end)
    |> Enum.group_by(fn {ruta, _} -> ruta end)
    |> Enum.map(fn {ruta, lista} ->
      total =
        Enum.map(lista, fn {_, ingreso} -> ingreso end)
        |> Enum.sum()

      {ruta, total}
    end)
    |> Enum.sort_by(fn {_, total} -> total end, :desc)
    |> Enum.take(3)
  end
end

Punto2.main()

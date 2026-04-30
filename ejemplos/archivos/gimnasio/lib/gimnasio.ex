defmodule Gimnasio do

  def main do

    # Crear datos de prueba solo cuando no existe el archivo
    socios =
      case GestionArchivos.cargar_socios() do
        map when map_size(map) == 0 -> crear_datos_prueba(map)
        map -> map
      end

    # Mostrar información
    case obtener_socio(socios, "123") do
      {:ok, socio} ->
        IO.puts("\n=== Socio 123 ===")
        IO.inspect(socio)

      {:error, _} ->
        IO.puts("Socio no encontrado")
    end

    # Estadísticas
    stats = obtener_estadisticas(socios)
    IO.puts("\n=== Estadísticas ===")
    IO.inspect(stats)

    # Listar socios en una clase
    IO.puts("\n=== Socios en Yoga ===")
    socios_yoga = socios_en_clase(socios, "Yoga")
    Enum.each(socios_yoga, &IO.puts(&1.nombre))

    # Mostrar todos
    IO.inspect(listar_socios(socios))
  end

  def crear_datos_prueba(socios) do
    # Agregar socios
    {:ok, socios} = agregar_socio(socios, "123", "Juan Pérez", 30)
    {:ok, socios} = agregar_socio(socios, "456", "María García", 25)
    {:ok, socios} = agregar_socio(socios, "789", "Carlos López", 35)

    # Intentar agregar duplicado
    case agregar_socio(socios, "123", "Otro Juan", 28) do
      {:error, :cedula_duplicada} ->
        IO.puts("No se puede agregar: cédula duplicada")

      {:ok, _} ->
        IO.puts("Socio agregado")
    end

    # Inscribir en clases
    {:ok, socios} = inscribir_clase(socios, "123", "Yoga")
    {:ok, socios} = inscribir_clase(socios, "123", "Pilates")
    {:ok, socios} = inscribir_clase(socios, "456", "Spinning")

    # Intentar inscribir duplicado
    case inscribir_clase(socios, "123", "Yoga") do
      {:error, :ya_inscrito} ->
        IO.puts("Ya está inscrito en esa clase")

      {:ok, _} ->
        IO.puts("Inscrito en clase")
    end

    # Actualizar socio
    #{:ok, socios} = actualizar_socio(socios, "123", "Juan Pérez Gómez", 31)

    # Eliminar socio
    # {:ok, socios} = eliminar_socio(socios, "789")
    socios
  end

  def agregar_socio(socios, cedula, nombre, edad) do
    case Socio.nuevo(nombre, edad) do
      {:ok, nuevo_socio} ->
        if Map.has_key?(socios, cedula) do
          {:error, :cedula_duplicada}
        else
          nuevo = Map.put(socios, cedula, nuevo_socio)
          GestionArchivos.guardar_socios(nuevo)
          {:ok, nuevo}
        end

      {:error, razon} ->
        {:error, razon}
    end
  end

  def obtener_socio(socios, cedula) do
    case Map.get(socios, cedula) do
      nil -> {:error, :no_encontrado}
      socio -> {:ok, socio}
    end
  end

  def actualizar_socio(socios, cedula, nombre, edad) do
    case Map.get(socios, cedula) do
      nil ->
        {:error, :no_encontrado}

      socio ->
        actualizado = %{socio | nombre: nombre, edad: edad}
        nuevo = Map.put(socios, cedula, actualizado)
        GestionArchivos.guardar_socios(nuevo)
        {:ok, nuevo}
    end
  end

  def eliminar_socio(socios, cedula) do
    if Map.has_key?(socios, cedula) do
      nuevo = Map.delete(socios, cedula)
      GestionArchivos.guardar_socios(nuevo)
      {:ok, nuevo}
    else
      {:error, :no_encontrado}
    end
  end

  def inscribir_clase(socios, cedula, clase) do
    case Map.get(socios, cedula) do
      nil ->
        {:error, :no_encontrado}

      socio ->
        case Socio.inscribir_clase(socio, clase) do
          {:ok, actualizado} ->
            nuevo = Map.put(socios, cedula, actualizado)
            GestionArchivos.guardar_socios(nuevo)
            {:ok, nuevo}

          {:error, razon} ->
            {:error, razon}
        end
    end
  end

  def desinscribir_clase(socios, cedula, clase) do
    case Map.get(socios, cedula) do
      nil ->
        {:error, :no_encontrado}

      socio ->
        case Socio.desinscribir_clase(socio, clase) do
          {:ok, actualizado} ->
            nuevo = Map.put(socios, cedula, actualizado)
            GestionArchivos.guardar_socios(nuevo)
            {:ok, nuevo}
        end
    end
  end

  def listar_socios(socios), do: Map.values(socios)

  # Devuelve la lista de socios que pertenece a una clase específica
  def socios_en_clase(socios, clase) do
    socios
    |> Map.values()
    |> Enum.filter(&Socio.tiene_clase?(&1, clase))
  end

  # Devuelve estadísticas básicas del gimnasio
  def obtener_estadisticas(socios) do
    %{
      total: map_size(socios),
      edad_promedio: calcular_edad_promedio(socios)
    }
  end

  defp calcular_edad_promedio(socios) when map_size(socios) == 0, do: 0

  defp calcular_edad_promedio(socios) do
    edades = socios |> Map.values() |> Enum.map(& &1.edad)
    Enum.sum(edades) / length(edades)
  end
end

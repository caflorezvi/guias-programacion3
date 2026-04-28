defmodule Socio do
  @enforce_keys [:nombre, :edad]
  defstruct [:nombre, :edad, clases: []]

  # Constructor con validación
  def nuevo(nombre, edad) when edad > 0 and edad < 100 do
    {:ok, %__MODULE__{nombre: nombre, edad: edad}}
  end

  def nuevo(_nombre, _edad), do: {:error, :edad_invalida}

  # --------------------- Funciones de utilidad relacionadas con el struct ---------------------

  def inscribir_clase(%__MODULE__{clases: clases} = socio, clase) do
    if tiene_clase?(socio, clase) do
      {:error, :ya_inscrito}
    else
      {:ok, %{socio | clases: [clase | clases]}}
    end
  end

  def desinscribir_clase(%__MODULE__{clases: clases} = socio, clase) do
    {:ok, %{socio | clases: List.delete(clases, clase)}}
  end

  def tiene_clase?(%__MODULE__{clases: clases}, clase), do: Enum.member?(clases, clase)
end

defmodule Gimnasio do
  @primera_vez false

  def main do
    # Inicializar
    socios = GestionArchivos.cargar_socios()

    if @primera_vez do
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

defmodule GestionArchivos do
  @moduledoc """
  Módulo para gestionar la lectura y escritura de socios en archivos de texto.
  """

  @archivo "socios.csv"

  @doc """
  Guarda el mapa de socios en un archivo de texto.
  Cada socio se guarda en una línea con el formato:
  cedula;nombre;edad;clase1,clase2,...
  """
  def guardar_socios(socios) do
    # Convertir el mapa de socios a líneas de texto

    cabecera = "cedula,nombre,edad,clases"

    contenido =
      Enum.map_join(socios, "\n", fn {cedula, socio} -> convertir_a_linea(cedula, socio) end)

    # Escribir el contenido al archivo
    File.write!(@archivo, "#{cabecera}\n#{contenido}")
  end

  defp convertir_a_linea(cedula, %Socio{nombre: nombre, edad: edad, clases: clases}) do
    # Unir las clases con comas
    clases_str = Enum.join(clases, ";")
    # Formato de línea para el archivo
    "#{cedula},#{nombre},#{edad},#{clases_str}"
  end

  @doc """
  Carga el mapa de socios desde un archivo de texto.
  Retorna un mapa con la estructura:
  %{cedula => %Socio{...}, ...}
  Si el archivo no existe, retorna un mapa vacío.
  """
  def cargar_socios() do
    try do
      # Abrir el archivo como un stream (puede fallar si no existe)
      stream = File.stream!(@archivo)

      stream
      # Omitir la primera línea (encabezado)
      |> Stream.drop(1)
      # Eliminar espacios en blanco y saltos de línea
      |> Stream.map(&String.trim/1)
      # Convertir cada línea a una tupla {cedula, socio}
      |> Stream.map(fn linea -> convertir_a_socio(linea) end)
      |> Enum.reduce(%{}, fn {cedula, socio}, acc ->
        # Construir el mapa de socios
        Map.put(acc, cedula, socio)
      end)
    rescue
      # Si el archivo no existe, retornar un mapa vacío
      _ -> %{}
    end
  end

  defp convertir_a_socio(linea) do
    # Dividir la línea en partes
    [cedula, nombre, edad_str, clases_str] = String.split(linea, ",")
    # Convertir la edad a entero
    edad = String.to_integer(edad_str)
    # Dividir las clases en una lista
    clases = if clases_str == "", do: [], else: String.split(clases_str, ";")
    # Retornar la tupla {cedula, socio}
    {cedula, %Socio{nombre: nombre, edad: edad, clases: clases}}
  end
end

Gimnasio.main()

defmodule Socio do
  defstruct nombre: "", edad: 0, clases: []
end

defmodule Gimnasio do

  def main do
    # Se lee el archivo de socios al iniciar la aplicación
    socios = GestionArchivos.cargar_socios()

    # Listar todos los socios
    IO.inspect(listar_socios(socios), label: "Lista de Socios")

    # Ejemplos de uso (agregar varios socios y guardar cambios)
    socios = agregar_socio(socios, "123", "Juan", 30)
    GestionArchivos.guardar_socios(socios)

    socios = agregar_socio(socios, "456", "Maria", 25)
    GestionArchivos.guardar_socios(socios)

    socios = agregar_socio(socios, "789", "Pedro", 29)
    GestionArchivos.guardar_socios(socios)

    # Actualizar socio y se guardar cambios
    socios = actualizar_socio(socios, "123", "Juan Perez", 31)
    GestionArchivos.guardar_socios(socios)

    # Inscribir socio en clases y guardar cambios
    socios = inscribir_clase(socios, "123", "Yoga")
    GestionArchivos.guardar_socios(socios)

    socios = inscribir_clase(socios, "123", "Pilates")
    GestionArchivos.guardar_socios(socios)

    # Listar todos los socios
    IO.inspect(listar_socios(socios), label: "Lista de Socios")

  end

  defp agregar_socio(socios, cedula, nombre, edad) do
    nuevo_socio = %Socio{nombre: nombre, edad: edad, clases: []}
    Map.put(socios, cedula, nuevo_socio)
  end

  defp obtener_socio(socios, cedula) do
    Map.get(socios, cedula)
  end

  defp actualizar_socio(socios, cedula, nombre, edad) do
    case Map.get(socios, cedula) do
      nil ->
        {:error, "Socio no encontrado"}

      %Socio{} = socio ->
        actualizado = %Socio{socio | nombre: nombre, edad: edad}
        Map.put(socios, cedula, actualizado)
    end
  end

  defp eliminar_socio(socios, cedula) do
    Map.delete(socios, cedula)
  end

  defp listar_socios(socios) do
    Map.values(socios)
  end

  defp inscribir_clase(socios, cedula, clase) do
    case Map.get(socios, cedula) do
      nil ->
        {:error, "Socio no encontrado"}

      %Socio{} = socio ->
        actualizado = %Socio{socio | clases: [clase | socio.clases]}
        Map.put(socios, cedula, actualizado)
    end
  end
end

defmodule GestionArchivos do

  @archivo "socios.txt"

  @doc """
  Guarda el mapa de socios en un archivo de texto.
  Cada socio se guarda en una línea con el formato:
  cedula;nombre;edad;clase1,clase2,...
  """
  def guardar_socios(socios) do
    # Convertir el mapa de socios a líneas de texto
    contenido =
      Enum.map(socios, fn {cedula, socio} -> convertir_a_linea(cedula, socio) end)
      |> Enum.join("\n")

    # Escribir el contenido al archivo
    File.write!(@archivo, contenido)
  end

  defp convertir_a_linea(cedula, %Socio{nombre: nombre, edad: edad, clases: clases}) do
    # Unir las clases con comas
    clases_str = Enum.join(clases, ",")
    # Formato de línea para el archivo
    "#{cedula};#{nombre};#{edad};#{clases_str}"
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
    [cedula, nombre, edad_str, clases_str] = String.split(linea, ";")
    # Convertir la edad a entero
    edad = String.to_integer(edad_str)
    # Dividir las clases en una lista
    clases = if clases_str == "", do: [], else: String.split(clases_str, ",")
    # Retornar la tupla {cedula, socio}
    {cedula, %Socio{nombre: nombre, edad: edad, clases: clases}}
  end
end

Gimnasio.main()

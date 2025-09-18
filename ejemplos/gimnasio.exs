defmodule Socio do
  defstruct nombre: "", edad: 0, clases: []
end

defmodule Gimnasio do
  def main do
    socios = %{}

    socios = agregar_socio(socios, "123", "Juan", 30)
    socios = agregar_socio(socios, "456", "Maria", 25)

    IO.inspect(obtener_socio(socios, "123"))

    socios = actualizar_socio(socios, "123", "Juan Perez", 31)
    IO.inspect(obtener_socio(socios, "123"))

    socios = inscribir_clase(socios, "123", "Yoga")
    socios = inscribir_clase(socios, "123", "Pilates")
    IO.inspect(obtener_socio(socios, "123"))

    IO.inspect(listar_socios(socios))

    socios = eliminar_socio(socios, "456")
    IO.inspect(listar_socios(socios))
  end

  def agregar_socio(socios, cedula, nombre, edad) do
    nuevo_socio = %Socio{nombre: nombre, edad: edad, clases: []}
    Map.put(socios, cedula, nuevo_socio)
  end

  def obtener_socio(socios, cedula) do
    Map.get(socios, cedula)
  end

  def actualizar_socio(socios, cedula, nombre, edad) do
    case Map.get(socios, cedula) do
      nil ->
        {:error, "Socio no encontrado"}

      socio ->
        actualizado = %Socio{socio | nombre: nombre, edad: edad}
        Map.put(socios, cedula, actualizado)
    end
  end

  def eliminar_socio(socios, cedula) do
    Map.delete(socios, cedula)
  end

  def listar_socios(socios) do
    Map.values(socios)
  end

  def inscribir_clase(socios, cedula, clase) do
    case Map.get(socios, cedula) do
      nil ->
        {:error, "Socio no encontrado"}

      socio ->
        actualizado = %Socio{socio | clases: [clase | socio.clases]}
        Map.put(socios, cedula, actualizado)
    end
  end

  def guardar_socios(archivo, socios) do
    contenido =
      socios
      |> Enum.map(fn {cedula, %Socio{nombre: nombre, edad: edad, clases: clases}} ->
        clases_str = Enum.join(clases, ",")
        "#{cedula};#{nombre};#{edad};#{clases_str}"
      end)
      |> Enum.join("\n")

    File.write!(archivo, contenido)
  end

  def cargar_socios(archivo) do
    case File.read(archivo) do
      {:ok, contenido} ->
        contenido
        |> String.split("\n", trim: true)
        |> Enum.reduce(%{}, fn linea, acc ->
          [cedula, nombre, edad_str, clases_str] =
            String.split(linea, ";")

          clases =
            if clases_str == "" do
              []
            else
              String.split(clases_str, ",")
            end

          socio = %Socio{nombre: nombre, edad: String.to_integer(edad_str), clases: clases}
          Map.put(acc, cedula, socio)
        end)

      {:error, _} ->
        # Si el archivo no existe, devuelve un mapa vacío
        %{}
    end
  end
end

Gimnasio.main()

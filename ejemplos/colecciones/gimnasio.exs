defmodule Socio do
  defstruct nombre: "", edad: 0, clases: []
end

defmodule Gimnasio do

  def main do
    # Se lee el archivo de socios al iniciar la aplicación
    socios = %{}

    # Ejemplos de uso (agregar varios socios y guardar cambios)
    socios = agregar_socio(socios, "123", "Juan", 30)
    socios = agregar_socio(socios, "456", "Maria", 25)
    socios = agregar_socio(socios, "789", "Pedro", 29)

    # Actualizar socio y se guardar cambios
    socios = actualizar_socio(socios, "123", "Juan Perez", 31)

    # Inscribir socio en clases y guardar cambios
    socios = inscribir_clase(socios, "123", "Yoga")
    socios = inscribir_clase(socios, "123", "Pilates")

    # Consultar socio
    socio = obtener_socio(socios, "123")
    IO.inspect(socio, label: "Socio con cédula 123")

    # Listar todos los socios
    IO.inspect(listar_socios(socios), label: "Lista de Socios")

    # Eliminar socio y guardar cambios
    socios = eliminar_socio(socios, "456")

    # Listar todos los socios
    IO.inspect(listar_socios(socios), label: "Lista de Socios después de eliminar 456")
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

      %Socio{} = socio ->
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

      %Socio{} = socio ->
        actualizado = %Socio{socio | clases: [clase | socio.clases]}
        Map.put(socios, cedula, actualizado)
    end
  end

end

Gimnasio.main()

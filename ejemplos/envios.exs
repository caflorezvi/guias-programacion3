defmodule EmpresaEnvios do
  @moduledoc """
  Módulo para gestionar mensajes de envío de paquetes dado el nombre del usuario,
  el nombre del destinatario y la dirección de envío.
  """

  def main do
    nombre_usuario = leer("Ingrese el nombre del usuario: ")
    nombre_destinatario = leer("Ingrese el nombre del destinatario: ")
    direccion = leer("Ingrese la dirección de envío: ")
    mensaje = generar_mensaje(nombre_usuario, nombre_destinatario, direccion)
    imprimir_mensaje(mensaje)
  end

  @doc """
  Lee una línea de entrada del usuario. Imprime el mensaje de solicitud recibido y devuelve el texto ingresado, eliminando espacios en blanco (incluidos saltos de línea) al inicio y al final.
  """
  def leer(mensaje) do
    IO.gets(mensaje)
    |> String.trim()
  end

  defp generar_mensaje(nombre_usuario, nombre_destinatario, direccion) do
    "El paquete a nombre de #{nombre_usuario} será enviado a #{nombre_destinatario} en la dirección #{direccion}."
  end

  defp imprimir_mensaje(mensaje) do
    IO.puts(mensaje)
  end

end

EmpresaEnvios.main()

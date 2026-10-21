defmodule Registro do

  def main do
    nombre = Util.leer("Ingrese el nombre: ", :string)
    edad = Util.leer("Ingrese la edad: ", :string)
    email = Util.leer("Ingrese el email: ", :string)

    registrar(nombre, edad, email)
    |> Util.imprimir_mensaje()
  end

  defp registrar(nombre, edad, email) do
    with {:ok, nombre} <- validar_nombre(nombre),
         {:ok, edad} <- validar_edad(edad),
         {:ok, email} <- validar_email(email) do
      "Usuario #{nombre} (#{edad} años, #{email}) registrado correctamente."
    else
      {:error, motivo} -> "Error de registro: #{motivo}"
    end
  end

  defp validar_nombre(""), do: {:error, "El nombre no puede estar vacío."}
  defp validar_nombre(nombre), do: {:ok, nombre}

  defp validar_edad(edad) do
    case Integer.parse(edad) do
      {numero, ""} when numero >= 18 -> {:ok, numero} # en la cláusula se puede usar un guard para validar la edad
      {_numero, ""} -> {:error, "El usuario debe ser mayor de edad."}
      _ -> {:error, "La edad no es un número válido."}
    end
  end

  defp validar_email(email) do
    if String.contains?(email, "@") do
      {:ok, email}
    else
      {:error, "El email debe contener el carácter '@'."}
    end
  end

end

Registro.main()

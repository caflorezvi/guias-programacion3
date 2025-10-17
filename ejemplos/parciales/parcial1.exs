defmodule EmpresaTransporte do

  def main do
    precio_distancia = Util.leer("Ingrese la distancia en km: ", :float)
    |> obtener_precio

    descuento_tipo = Util.leer("Ingrese el tipo de usuario 1=estudiante, 2=adulto mayor, 3=regular: ", :integer)
    |> obtener_descuento

    recargo_horario = Util.leer("Ingrese el horario 1=nocturno, 2=normal: ", :integer)
    |> obtener_recargo

    calcular_precio_final(precio_distancia, descuento_tipo, recargo_horario)
    |> generar_mensaje
    |> Util.imprimir
  end

  defp obtener_precio(distancia) when distancia > 0 and distancia <= 5, do: 2500
  defp obtener_precio(distancia) when distancia > 5 and distancia <=15, do: 4000
  defp obtener_precio(distancia) when distancia > 15, do: 6500
  defp obtener_precio(_distancia), do: 0 # caso inválido

  defp obtener_descuento(1), do: 0.3
  defp obtener_descuento(2), do: 0.25
  defp obtener_descuento(_), do: 0.0

  defp obtener_recargo(horario) do
    cond do
      horario == 1 -> 0.2
      true -> 0.0
    end
  end

  defp calcular_precio_final(precio_distancia, descuento, recargo) do
    #precio_final =
    #  precio_distancia
    #  |> then(&(&1 - &1*descuento))
    #  |> then(&(&1 + &1*recargo))

    precio_final = precio_distancia * (1 - descuento) * (1 + recargo)
    {precio_final, precio_distancia}
  end

  defp generar_mensaje({total, subtotal}), do: "El subtotal es #{subtotal} y el total es #{total}"

end

defmodule Juego do
  @min 1
  @max 20

  def main do
    aleatorio = :rand.uniform(@max)
    numero_1 = Util.leer("Ingrese el primer número ", :integer)

    {gano, mensaje} = calcular_diferencia(numero_1, aleatorio, 1)
    Util.imprimir(mensaje)

    if not gano do
      numero_2 = Util.leer("Ingrese el segundo número ", :integer)

      {_, mensaje} = calcular_diferencia(numero_2, aleatorio, 2)
      Util.imprimir(mensaje)
    end

    Util.imprimir("El número era: #{aleatorio}")

  end

  def validar_numero(numero) when numero in @min..@max, do: {:ok, numero}
  def validar_numero(_), do: {:error, "Número inválido"}

  def calcular_diferencia(numero, aleatorio, intento) do
    diferencia = aleatorio-numero
    absoluto = abs(diferencia)

    pista = crear_pista(diferencia)

    cond do
      absoluto == 0 -> {true, "¡Felicidades! Lo lograste en #{intento} intentos"}
      absoluto > 10 -> {false, "Estás lejos (>10). #{pista}"}
      absoluto >= 5 and absoluto <= 10 -> {false, "Estás cerca (entre 5 y 10). #{pista}"}
      true -> {false, "Estás muy cerca (<5). #{pista}"}
    end

  end

  def crear_pista(diferencia) when diferencia > 0, do: "El número secreto es más grande"
  def crear_pista(diferencia) when diferencia < 0, do: "El número secreto es más pequeño"
  def crear_pista(_), do: ""

end

defmodule Password do

  def main do
    Util.leer("Ingrese una contraseña: ", :string)
    |> validar()
    |> Util.imprimir()
  end

  defp validar(password) do

    mensaje =
      ""
      |> validar_tam(password)
      |> validar_may(password)
      |> validar_numero(password)
      |> validar_espacios(password)

    case mensaje do
      "" -> "Contraseña correcta"
      _ -> mensaje
    end

  end

  defp validar_tam(mensaje, password) do
    cond do
      String.length(password) < 8 -> agregar_error(mensaje, "Contraseña muy corta")
      true -> mensaje
    end
  end

  defp validar_may(mensaje, password) do
    min = String.downcase(password)
    cond do
      min == password -> agregar_error(mensaje, "La contraseña debe tener al menos una letra mayúscula")
      true -> mensaje
    end
  end

  defp validar_numero(mensaje, password) do
    contiene = String.contains?(password, "1") or String.contains?(password, "2") or String.contains?(password, "3")
    case contiene do
      false -> agregar_error(mensaje, "La contraseña debe tener al menos un número")
      true -> mensaje
    end
  end

  defp validar_espacios(mensaje, password) do
    sin_espacios = String.replace(password, " ", "")
    cond do
      sin_espacios != password -> agregar_error(mensaje, "La contraseña no puede tener espacios en blanco")
      true -> mensaje
    end
  end

  defp agregar_error(mensaje, nuevo) do
    cond do
      mensaje == "" -> nuevo
      true -> mensaje <> "\n" <> nuevo
    end
  end

end

Password.main()

defmodule Matematicas do

  def main do
    dividir(10, 9) |> imprimir() |> IO.puts()
  end

  def dividir(a,b) do
    cond do
      b == 0 -> {:error, "No se puede dividir por cero"}
      true -> {:ok, a / b}
    end
  end

  def imprimir({resp, valor}) do
    case resp do
      :ok -> "El resultado es: #{Float.round(valor, 2)}"
      :error -> "Error: #{valor}"
    end
  end

end


Matematicas.main()

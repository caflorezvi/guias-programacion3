defmodule Matematicas do

  def main do
    dividir(10, 67)
    |> crear_respuesta()
    |> IO.puts()
  end

  def dividir(a, b) do
    cond do
      b == 0 -> {:error, "La división NO es válida"}
      true -> {:ok, a/b}
    end
  end

  def crear_respuesta(tupla) do
    case tupla do
      {:ok, valor} -> "El resultado de la división es: #{valor}"
      {:error, mensaje} -> "Error: #{mensaje}"
    end
  end

end

Matematicas.main()

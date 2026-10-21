defmodule Ruta do
  @enforce_keys [:nombre, :ciudad, :distancia]
  defstruct [:nombre, :ciudad, :distancia, recorridos: 0, favorita: false]

  def recorrer(%Ruta{recorridos: n} = ruta) do
    %{ruta | recorridos: n + 1}
  end

  def marcar_favorita(%Ruta{} = ruta), do: %{ruta | favorita: true}

  def distancia_formateada(%Ruta{distancia: metros}) do
    "#{div(metros, 1000)} km y #{rem(metros, 1000)} metros"
  end

  def frecuente?(%Ruta{recorridos: n}), do: n >= 3
end

defmodule AppCiclismo do
  def main do
    ruta =
      %Ruta{nombre: "Armenia - Salento", ciudad: "Armenia", distancia: 24350}
      |> Ruta.recorrer()
      |> Ruta.recorrer()
      |> Ruta.recorrer()
      |> Ruta.marcar_favorita()

    IO.puts("#{ruta.nombre}, desde #{ruta.ciudad} (#{Ruta.distancia_formateada(ruta)})")
    IO.puts("Recorridos: #{ruta.recorridos}")
    IO.puts("¿Es frecuente? #{Ruta.frecuente?(ruta)}")
  end
end

AppCiclismo.main()

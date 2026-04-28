defmodule GestionArchivos do
  @archivo Path.join("data", "socios.json")

  @doc """
  Guarda los socios en formato JSON.
  """
  def guardar_socios(socios) do
    # Convertimos el mapa a algo serializable
    datos =
      socios
      |> Enum.map(fn {cedula, socio} ->
        {cedula, socio_a_map(socio)}
      end)
      |> Enum.into(%{})

    json = Jason.encode!(datos, pretty: true)
    File.write!(@archivo, json)
  end

  defp socio_a_map(%Socio{nombre: n, edad: e, clases: c}) do
    %{
      nombre: n,
      edad: e,
      clases: c
    }
  end

  @doc """
  Carga los socios desde JSON.
  """
  def cargar_socios() do
    case File.read(@archivo) do
      {:ok, contenido} ->
        contenido
        |> Jason.decode!()
        |> Enum.map(fn {cedula, socio_map} ->
          {cedula, map_a_socio(socio_map)}
        end)
        |> Enum.into(%{})

      {:error, _} ->
        %{}
    end
  end

  defp map_a_socio(%{"nombre" => n, "edad" => e, "clases" => c}) do
    %Socio{
      nombre: n,
      edad: e,
      clases: c
    }
  end
end

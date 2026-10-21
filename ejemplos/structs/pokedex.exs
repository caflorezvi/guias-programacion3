defmodule Pokemon do
  @enforce_keys [:nombre, :nivel]
  defstruct [:nombre, :nivel, movimientos: []]

  # El límite de movimientos es una regla del dominio, no un número suelto en el código
  @max_movimientos 4

  # Constructor con validación
  def nuevo(nombre, nivel) when nivel > 0 and nivel <= 100 do
    {:ok, %__MODULE__{nombre: nombre, nivel: nivel}}
  end

  def nuevo(_nombre, _nivel), do: {:error, :nivel_invalido}

  # Actualización con la misma validación del constructor
  def actualizar(%__MODULE__{} = pokemon, nombre, nivel) when nivel > 0 and nivel <= 100 do
    {:ok, %{pokemon | nombre: nombre, nivel: nivel}}
  end

  def actualizar(%__MODULE__{}, _nombre, _nivel), do: {:error, :nivel_invalido}

  # --------------------- Funciones de utilidad relacionadas con el struct ---------------------

  def aprender_movimiento(%__MODULE__{movimientos: movimientos} = pokemon, movimiento) do
    cond do
      conoce_movimiento?(pokemon, movimiento) -> {:error, :ya_lo_conoce}
      length(movimientos) >= @max_movimientos -> {:error, :movimientos_llenos}
      true -> {:ok, %{pokemon | movimientos: [movimiento | movimientos]}}
    end
  end

  def olvidar_movimiento(%__MODULE__{movimientos: movimientos} = pokemon, movimiento) do
    {:ok, %{pokemon | movimientos: List.delete(movimientos, movimiento)}}
  end

  def conoce_movimiento?(%__MODULE__{movimientos: movimientos}, movimiento) do
    Enum.member?(movimientos, movimiento)
  end
end

defmodule Pokedex do
  def main do
    # Registrar Pokémon
    pokemones =
      %{}
      |> registrar(25, "Pikachu", 12)
      |> registrar(6, "Charizard", 36)
      |> registrar(9, "Blastoise", 34)
      |> registrar(25, "Raichu", 30)      # número duplicado
      |> registrar(150, "Mewtwo", 0)      # nivel inválido

    # Enseñar movimientos
    pokemones =
      pokemones
      |> ensenar(25, "Impactrueno")
      |> ensenar(25, "Ataque Rapido")
      |> ensenar(25, "Impactrueno")       # ya lo conoce
      |> ensenar(25, "Cola Ferrea")
      |> ensenar(25, "Rayo")
      |> ensenar(25, "Placaje")           # quinto movimiento
      |> ensenar(6, "Lanzallamas")

    IO.inspect(listar_pokemones(pokemones))
  end

  # Informa el resultado y continúa con el mapa nuevo, o con el mismo si falló
  defp registrar(pokemones, numero, nombre, nivel) do
    case registrar_pokemon(pokemones, numero, nombre, nivel) do
      {:ok, nuevo_mapa} ->
        IO.puts("#{nombre} registrado con el numero #{numero}")
        nuevo_mapa

      {:error, razon} ->
        IO.puts("No se pudo registrar a #{nombre}: #{razon}")
        pokemones
    end
  end

  defp ensenar(pokemones, numero, movimiento) do
    case aprender_movimiento(pokemones, numero, movimiento) do
      {:ok, nuevo_mapa} ->
        IO.puts("El Pokemon #{numero} aprendio #{movimiento}")
        nuevo_mapa

      {:error, razon} ->
        IO.puts("El Pokemon #{numero} no pudo aprender #{movimiento}: #{razon}")
        pokemones
    end
  end

  def registrar_pokemon(pokemones, numero, nombre, nivel) do
    with :ok <- verificar_numero_libre(pokemones, numero),
         {:ok, nuevo_pokemon} <- Pokemon.nuevo(nombre, nivel) do
      # Retorna un nuevo mapa con el Pokémon agregado
      {:ok, Map.put(pokemones, numero, nuevo_pokemon)}
    end
  end

  defp verificar_numero_libre(pokemones, numero) do
    if Map.has_key?(pokemones, numero), do: {:error, :numero_duplicado}, else: :ok
  end

  def obtener_pokemon(pokemones, numero) do
    case Map.get(pokemones, numero) do
      nil -> {:error, :no_encontrado}
      pokemon -> {:ok, pokemon}
    end
  end

  def actualizar_pokemon(pokemones, numero, nombre, nivel) do
    with {:ok, pokemon} <- obtener_pokemon(pokemones, numero),
         {:ok, actualizado} <- Pokemon.actualizar(pokemon, nombre, nivel) do
      {:ok, Map.put(pokemones, numero, actualizado)}
    end
  end

  def liberar_pokemon(pokemones, numero) do
    if Map.has_key?(pokemones, numero) do
      # Retorna un nuevo mapa sin el Pokémon liberado
      {:ok, Map.delete(pokemones, numero)}
    else
      {:error, :no_encontrado}
    end
  end

  def aprender_movimiento(pokemones, numero, movimiento) do
    with {:ok, pokemon} <- obtener_pokemon(pokemones, numero),
         {:ok, actualizado} <- Pokemon.aprender_movimiento(pokemon, movimiento) do
      {:ok, Map.put(pokemones, numero, actualizado)}
    end
  end

  def olvidar_movimiento(pokemones, numero, movimiento) do
    with {:ok, pokemon} <- obtener_pokemon(pokemones, numero),
         {:ok, actualizado} <- Pokemon.olvidar_movimiento(pokemon, movimiento) do
      {:ok, Map.put(pokemones, numero, actualizado)}
    end
  end

  def listar_pokemones(pokemones), do: Map.values(pokemones)

  # Devuelve la lista de Pokémon que conoce un movimiento específico
  def pokemones_con_movimiento(pokemones, movimiento) do
    pokemones
    |> Map.values()
    |> Enum.filter(&Pokemon.conoce_movimiento?(&1, movimiento))
  end

  # Devuelve estadísticas básicas de la Pokédex
  def obtener_estadisticas(pokemones) do
    %{
      total: map_size(pokemones),
      nivel_promedio: calcular_nivel_promedio(pokemones)
    }
  end

  defp calcular_nivel_promedio(pokemones) when map_size(pokemones) == 0, do: 0

  defp calcular_nivel_promedio(pokemones) do
    niveles = pokemones |> Map.values() |> Enum.map(& &1.nivel)
    Enum.sum(niveles) / length(niveles)
  end
end

Pokedex.main()

defmodule Socio do
  @enforce_keys [:nombre, :edad]
  defstruct [:nombre, :edad, clases: []]

  # Constructor con validación
  def nuevo(nombre, edad) when edad > 0 and edad < 100 do
    {:ok, %__MODULE__{nombre: nombre, edad: edad}}
  end

  def nuevo(_nombre, _edad), do: {:error, :edad_invalida}

  # --------------------- Funciones de utilidad relacionadas con el struct ---------------------

  def inscribir_clase(%__MODULE__{clases: clases} = socio, clase) do
    if tiene_clase?(socio, clase) do
      {:error, :ya_inscrito}
    else
      {:ok, %{socio | clases: [clase | clases]}}
    end
  end

  def desinscribir_clase(%__MODULE__{clases: clases} = socio, clase) do
    {:ok, %{socio | clases: List.delete(clases, clase)}}
  end

  def tiene_clase?(%__MODULE__{clases: clases}, clase), do: Enum.member?(clases, clase)

end

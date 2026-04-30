defmodule GimnasioApp do
  use Application

  def start(_type, _args) do
    Gimnasio.main()
    {:ok, self()}
  end

end

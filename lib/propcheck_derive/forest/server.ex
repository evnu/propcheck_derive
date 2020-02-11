defmodule PropCheck.Derive.Forest.Server do
  @moduledoc false

  use Agent

  alias __MODULE__.State

  def start_link(args) do
    name = Keyword.get(args, :name, __MODULE__)

    Agent.start_link(fn -> %State{} end, name: name)
  end

  def add(server \\ __MODULE__, forest = %PropCheck.Derive.Forest{}) do
    Agent.update(server, &State.add_forest!(&1, forest))
  end

  def find_cycle(server \\ __MODULE__) do
    Agent.get(server, &State.find_cycle(&1))
  end
end

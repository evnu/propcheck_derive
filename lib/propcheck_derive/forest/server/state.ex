defmodule PropCheck.Derive.Forest.Server.State do
  @moduledoc false

  # condensed: Only root and leaf nodes
  # expanded: complete trees

  defstruct condensed: %{}, expanded: %{}

  def add_forest!(state = %__MODULE__{}, forest = %PropCheck.Derive.Forest{}) do
    Enum.reduce(forest.trees, state, &update(&2, &1))
  end

  defp update(state, root = %PropCheck.Derive.Type{}) do
    canonic = canonic_type(root)

    if state.expanded[canonic] do
      state
    else
      expanded = Map.put(state.expanded, canonic, root)
      condensed = Map.put(state.condensed, canonic, condense(root))
      %__MODULE__{state | expanded: expanded, condensed: condensed}
    end
  end

  defp canonic_type(node) do
    {node.module, node.name, node.arity}
  end

  defp condense(node) do
    if PropCheck.Derive.Type.leaf?(node) do
      []
    else
      condense1(node)
    end
  end

  defp condense1(node) do
    if PropCheck.Derive.Type.leaf?(node) do
      [node]
    else
      Enum.map(node.depends_on, &condense1/1) |> List.flatten()
    end
  end

  def find_cycle(%__MODULE__{condensed: condensed}) do
    condensed
    |> Map.keys()
    |> traverse(condensed, [], MapSet.new())
  end

  defp traverse(names, condensed, path, visited) do
    Enum.reduce_while(names, :no_cycle, fn
      root, :no_cycle ->
        case find_cycle1(root, condensed, path, visited) do
          :no_cycle -> {:cont, :no_cycle}
          cycle = {:cycle, _} -> {:halt, cycle}
        end
    end)
  end

  defp find_cycle1(type, condensed, path, visited) do
    path = [type | path]

    if type in visited do
      {:cycle, Enum.reverse(path)}
    else
      leaf_nodes = condensed[type]

      if leaf_nodes do
        visited = MapSet.put(visited, type)

        leaf_nodes
        |> Enum.map(&canonic_type/1)
        |> traverse(condensed, path, visited)
      else
        :no_cycle
      end
    end
  end
end

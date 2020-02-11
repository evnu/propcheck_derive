defmodule PropCheck.Derive.Forest do
  @moduledoc false

  alias PropCheck.Derive.Forest.Server

  @enforce_keys [:trees]

  defstruct @enforce_keys

  def add_trees_from_ast!(ast, module) do
    ast
    |> to_forest!(module)
    |> make_generators()
    |> add_to_forest_server()
    |> detect_cycles!()
  end

  defp add_to_forest_server(forest = %__MODULE__{}) do
    :ok = Server.add(forest)

    forest
  end

  def generators(forest = %__MODULE__{}) do
    Enum.map(forest.trees, & &1.generator)
  end

  defp to_forest!(top_level_types, module) do
    trees =
      Enum.map(top_level_types, fn t = {viz, {top_level_type, typedef, vars}}
                                   when viz in [:type, :typep] ->
        case PropCheck.Derive.Type.new(module, top_level_type, typedef, vars) do
          {:ok, tree} ->
            privatize(tree, viz)

          {:error, {:unsupported, inner}} ->
            raise PropCheck.Derive.Type.TypeUnsupported, %{module: module, type: t, caused_by: inner}

          {:error, {:type_unclear, inner, type_name, reason}} ->
            raise PropCheck.Derive.Type.TypeUnclear, %{
              module: module,
              type_name: type_name,
              type: t,
              inner: inner,
              reason: reason,
              caused_by: inner
            }
        end
      end)

    %__MODULE__{trees: trees}
  end

  defp privatize(t = %PropCheck.Derive.Type{}, :type), do: t
  defp privatize(t = %PropCheck.Derive.Type{}, :typep), do: %PropCheck.Derive.Type{t | private: true}

  defp detect_cycles!(forest) do
    case Server.find_cycle() do
      :no_cycle ->
        forest

      cycle = {:cycle, _} ->
        raise ArgumentError, "Cycle detected: #{inspect(cycle)}"
    end
  end

  defp make_generators(forest = %__MODULE__{}) do
    update_in(
      forest.trees,
      &Enum.map(&1, fn tree -> add_generator_to_tree(tree) end)
    )
  end

  defp add_generator_to_tree(tree = %PropCheck.Derive.Type{}) do
    name = tree.name
    vars = tree.vars
    generator_block = tree.generator_block

    generator =
      if tree.private do
        quote do
          defp unquote(name)(unquote_splicing(vars)) do
            unquote(generator_block)
          end
        end
      else
        quote do
          def unquote(name)(unquote_splicing(vars)) do
            unquote(generator_block)
          end
        end
      end

    struct!(tree, generator: generator)
  end
end

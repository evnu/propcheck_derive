ExUnit.start()

defmodule TestUtils do
  def construct_forest(trees) do
    %PropCheck.Derive.Forest{trees: Enum.map(trees, &construct_tree/1)}
  end

  def construct_tree({:leaf, {module, type, arity}}) do
    %PropCheck.Derive.Type{
      module: module,
      name: type,
      arity: arity,
      vars: [],
      depends_on: nil,
      generator_block: nil,
      generator: nil
    }
  end

  def construct_tree({:nested, {module, type, arity}, nested}) do
    %PropCheck.Derive.Type{
      module: module,
      name: type,
      arity: arity,
      vars: [],
      depends_on: Enum.map(nested, &construct_tree/1),
      generator_block: nil,
      generator: nil
    }
  end
end

defmodule PropCheck.Derive.TypeTest do
  use ExUnit.Case
  use PropCheck

  doctest PropCheck.Derive.Type

  test "leaf?" do
    type_a = %PropCheck.Derive.Type{
      module: A,
      name: :a,
      arity: 0,
      vars: [],
      depends_on: [
        type_b = %PropCheck.Derive.Type{
          module: B,
          name: :b,
          arity: 0,
          vars: [],
          depends_on: nil,
          generator_block: nil
        }
      ],
      generator_block: nil
    }

    refute PropCheck.Derive.Type.leaf?(type_a)
    assert PropCheck.Derive.Type.leaf?(type_b)
  end
end

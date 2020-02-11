defmodule PropCheck.Derive.Forest.Server.StateTest do
  use ExUnit.Case

  alias PropCheck.Derive.Forest.Server.State

  import TestUtils

  test "add_forest" do
    forest = %PropCheck.Derive.Forest{
      trees: [
        type_a = %PropCheck.Derive.Type{
          module: A,
          name: :a,
          arity: 0,
          vars: [],
          generator_block: nil,
          depends_on: [
            type_b = %PropCheck.Derive.Type{
              module: B,
              name: :b,
              arity: 0,
              vars: [],
              depends_on: nil,
              generator_block: nil
            }
          ]
        }
      ]
    }

    state = State.add_forest!(%State{}, forest)

    assert %{{A, :a, 0} => type_a} == state.expanded
    assert %{{A, :a, 0} => [type_b]} == state.condensed

    assert_raise ArgumentError, fn ->
      State.add_forest!(state, forest)
    end
  end

  describe "find_cycle" do
    test "finds no false positive" do
      forest = construct_forest([{:nested, {A, :a, 0}, [{:leaf, {B, :b, 0}}]}])

      state = State.add_forest!(%State{}, forest)
      assert :no_cycle == State.find_cycle(state)
    end

    test "finds a cycle" do
      forest =
        construct_forest([
          {:nested, {A, :a, 0}, [{:leaf, {B, :b, 0}}]},
          {:nested, {B, :b, 0},
           [{:nested, {C, :c, 0}, [{:leaf, {A, :a, 0}}, {:leaf, {D, :d, 0}}]}]}
        ])

      state = State.add_forest!(%State{}, forest)

      assert {:cycle, [{A, :a, 0}, {B, :b, 0}, {A, :a, 0}]} == State.find_cycle(state)
    end
  end
end

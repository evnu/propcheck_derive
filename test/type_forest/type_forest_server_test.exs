defmodule PropCheck.Derive.Forest.ServerTest do
  use ExUnit.Case

  alias PropCheck.Derive.Forest.Server

  import TestUtils

  test "find cycles" do
    {:ok, server} = Server.start_link(name: TestServer)

    assert :no_cycle == Server.find_cycle(server)

    forest =
      construct_forest([
        {:nested, {A, :a, 0}, [{:leaf, {B, :b, 0}}]},
        {:nested, {B, :b, 0}, [{:nested, {C, :c, 0}, [{:leaf, {A, :a, 0}}, {:leaf, {D, :d, 0}}]}]}
      ])

    assert :ok == Server.add(server, forest)

    assert {:cycle, [{A, :a, 0}, {B, :b, 0}, {A, :a, 0}]} == Server.find_cycle(server)
  end
end

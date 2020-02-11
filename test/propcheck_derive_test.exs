defmodule PropcheckDeriveTest do
  use ExUnit.Case
  doctest PropcheckDerive

  test "greets the world" do
    assert PropcheckDerive.hello() == :world
  end
end

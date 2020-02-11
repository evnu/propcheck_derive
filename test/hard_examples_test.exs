defmodule HardExamplesTest do
  # Test examples which might be harder than what PropCheck.DeriveTest does
  use ExUnit.Case
  use PropCheck

  alias Hard.Generate

  property "list-of-lists-of-lists" do
    forall l1 <- Generate.ls(integer()) do
      with true <- Enum.all?(l1, &is_list/1),
           l2 <- Enum.concat(l1),
           true <- Enum.all?(l2, &is_list/1),
           l3 <- Enum.concat(l2) do
        Enum.all?(l3, &is_integer/1)
      end
    end
  end

  property "private types' generators are accessible via a public type" do
    forall i <- Generate.ii() do
      is_integer(i)
    end
  end

  property "union with type variables" do
    forall t <- Generate.t(integer(), float()) do
      is_atom(t) or is_integer(t) or is_float(t)
    end
  end

  property "annotated" do
    forall i <- Generate.annotated() do
      is_integer(i)
    end
  end

  property "annotated2" do
    forall {f, i} <- Generate.annotated2() do
      is_float(f) and is_integer(i)
    end
  end

  property "range" do
    forall i <- Generate.range() do
      i in -1..1
    end
  end

  property "range2" do
    forall i <- Generate.range2() do
      i in -3..-1
    end
  end
end

defmodule Hard do
  use PropCheck.Derive

  @type ls(a) :: list(list(list(a)))

  # handling private types
  @typep i :: integer()
  @type ii :: i()

  @type t(a, b) :: atom() | a | b

  # Adapted from Access.get_and_update_fun/2
  @type annotated :: result :: integer()
  @type annotated2 :: {result :: float(), result :: integer()}

  # Adapted from Calendar.ISO.year/0
  @type range :: -1..1
  @type range2 :: -3..-1
end

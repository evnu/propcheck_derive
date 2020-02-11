defmodule CycleDetectionTest do
  # Detect type cycles
  use ExUnit.Case

  test "simple cycle" do
    assert_raise ArgumentError, fn ->
      Code.compile_string("""
      defmodule Simple do
        use PropCheck.Derive
        @type a() :: b()
        @type b() :: a()
      end
      """)
    end
  end

  test "simple remote modules" do
    assert_raise ArgumentError, fn ->
      Code.compile_string("""
      defmodule A do
        use PropCheck.Derive
        @type a() :: B.b()
      end

      defmodule B do
        use PropCheck.Derive
        @type b() :: A.a()
      end
      """)
    end
  end

  test "link of modules" do
    assert_raise ArgumentError, fn ->
      Code.compile_string("""
      defmodule A1 do
        use PropCheck.Derive
        @type a() :: B.b()
      end

      defmodule B2 do
        use PropCheck.Derive
        @type b() :: C.c()
      end

      defmodule C3 do
        use PropCheck.Derive
        @type c() :: A.a()
      end
      """)
    end
  end

  test "cycle through type variable" do
    assert_raise ArgumentError, fn ->
      Code.compile_string("""
      defmodule TVar do
        use PropCheck.Derive
        @type t1(a) :: a
        @type t2 :: t1(t2)
      end
      """)
    end
  end

  test "remote cycle through type variable in tuple or list" do
    assert_raise ArgumentError, fn ->
      Code.compile_string("""
      defmodule TVarRemoteA do
        use PropCheck.Derive
        @type t1(a) :: {TVarRemoteB.t1(a)}
      end

      defmodule TVarRemoteB do
        use PropCheck.Derive
        @type t1(b) :: [TVarRemoteA.t1(b)]
      end
      """)
    end
  end
end

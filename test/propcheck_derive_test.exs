defmodule PropCheck.DeriveTest do
  use ExUnit.Case
  use PropCheck

  alias SampleModule.Generate

  #
  # Basic Types
  #
  property("any", do: forall(_anys <- Generate.anys(), do: true))
  property("atom", do: forall(atoms <- Generate.atoms(), do: is_atom(atoms)))
  property("map", do: forall(map <- Generate.maps(), do: is_map(map)))

  property("struct",
    do: forall(s <- Generate.structs(), do: is_map(s) and Map.has_key?(s, :__struct__))
  )

  property("tuple", do: forall(t <- Generate.tuples(), do: is_tuple(t)))
  property("integer", do: forall(i <- Generate.integers(), do: is_integer(i)))
  property("floats", do: forall(f <- Generate.floats(), do: is_float(f)))

  property("non_neg_integer",
    do: forall(i <- Generate.non_neg_integers(), do: is_integer(i) and i >= 0)
  )

  property("pos_integer", do: forall(i <- Generate.pos_integers(), do: is_integer(i) and i >= 1))
  property("neg_integer", do: forall(i <- Generate.neg_integers(), do: is_integer(i) and i < 0))

  property "list of integers" do
    forall l <- Generate.lists_integers() do
      is_list(l) and Enum.all?(l, &is_integer/1)
    end
  end

  property "list of custom generator" do
    forall l <- Generate.lists(integer()) do
      is_list(l) and Enum.all?(l, &is_integer/1)
    end
  end

  property "nonempty_list" do
    forall l <- Generate.nonempty_lists(integer()) do
      is_list(l) and Enum.all?(l, &is_integer/1) and length(l) > 0
    end
  end

  #
  # Literals
  #
  property "atom literals", numtests: 1 do
    forall a <- Generate.atom_literal() do
      a == :atom
    end
  end

  property "special atom literals", numtests: 1 do
    forall a <- Generate.special_atom_literal() do
      a in [true, false, nil]
    end
  end

  property "empty bitstring", numtests: 1 do
    forall b <- Generate.empty_bitstrings() do
      <<>> == b
    end
  end

  property "sized bitstring" do
    forall b <- Generate.sized_bitstrings() do
      is_bitstring(b) && bit_size(b) == 5
    end
  end

  property "unit_bitstring" do
    forall b <- Generate.unit_bitstrings() do
      is_bitstring(b) && rem(bit_size(b), 10) == 0
    end
  end

  property "sized_unit_bitstring" do
    forall b <- Generate.sized_unit_bitstrings() do
      is_bitstring(b) && bit_size(b) == 50
    end
  end

  property "fun_0" do
    forall f <- Generate.zero_aritys() do
      is_function(f, 0)
    end
  end

  property "fun_2", numtests: 1 do
    forall f <- Generate.two_aritys() do
      is_function(f, 2) and f.(:a, :b) == :ok
    end
  end

  property "any_arity1", numtests: 1 do
    forall f <- Generate.any_aritys1() do
      is_function(f)
    end
  end

  property "any_arity2" do
    forall f <- Generate.any_aritys2() do
      is_function(f)
    end
  end

  property "constant integer", numtests: 1 do
    forall one <- Generate.one() do
      one == 1
    end
  end

  property "range" do
    forall i <- Generate.range() do
      i in 1..10
    end
  end

  property "empty list", numtests: 1 do
    forall l <- Generate.empty_lists() do
      l == []
    end
  end

  property "list with any number of elements" do
    forall l <- Generate.any_number_lists() do
      Enum.all?(l, &is_number/1)
    end
  end

  property "nonempty list with any" do
    forall l <- Generate.nonempty_lists_with_any() do
      is_list(l) and l != []
    end
  end

  property "nonempty list with type" do
    forall l <- Generate.nonempty_lists_with_type(Generate.integers()) do
      is_list(l) and l != [] and Enum.all?(l, &is_integer/1)
    end
  end

  property "keyword list" do
    forall kw <- Generate.keyword_lists(Generate.integers()) do
      keys = Keyword.keys(kw)
      values = Keyword.values(kw)
      Enum.all?(keys, &(&1 in [:key1, :key2, :key3])) && Enum.all?(values, &is_integer/1)
    end
  end

  property "empty map", numtests: 1 do
    forall m <- Generate.empty_maps() do
      m == %{}
    end
  end

  property "map with keys" do
    forall m <- Generate.map_with_key(Generate.integers(), Generate.floats()) do
      Map.has_key?(m, :key1) && Map.has_key?(m, :key2) && is_integer(m.key1) && is_float(m.key2)
    end
  end

  property "map with required pairs" do
    forall m <- Generate.map_with_required_pairs(Generate.integers(), Generate.floats()) do
      keys = Map.keys(m)
      values = Map.values(m)
      Enum.all?(keys, &is_integer/1) && Enum.all?(values, &is_float/1)
    end
  end

  property "map with optional pairs" do
    forall m <- Generate.map_with_optional_pairs(Generate.integers(), Generate.floats()) do
      keys = Map.keys(m)
      values = Map.values(m)
      Enum.all?(keys, &is_integer/1) && Enum.all?(values, &is_float/1)
    end
  end

  property "a particular struct", numtests: 1 do
    forall s <- Generate.any_particular_struct() do
      s.__struct__ == SampleModule.SomeStruct
    end
  end

  property "a particular struct with a required key" do
    forall s <- Generate.a_particular_struct_with_required_key(Generate.integers()) do
      s.__struct__ == SampleModule.SomeStruct && is_integer(s.key)
    end
  end

  property "empty tuples", numtests: 1 do
    forall t <- Generate.empty_tuples() do
      t == {}
    end
  end

  property "two-element tuples" do
    forall t <- Generate.two_element_tuples() do
      tuple_size(t) == 2 && elem(t, 0) == :ok && is_integer(elem(t, 1))
    end
  end

  #
  # Built-In
  #

  property "term" do
    forall _t <- Generate.terms() do
      true
    end
  end

  property "arity" do
    forall a <- Generate.aritys() do
      is_integer(a) && a >= 0
    end
  end

  property "as_boolean" do
    forall b <- Generate.as_booleans(Generate.integers()) do
      is_integer(b)
    end
  end

  property "binary" do
    forall b <- Generate.binaries() do
      is_binary(b)
    end
  end

  property "bitstring" do
    forall b <- Generate.bitstrings() do
      is_bitstring(b)
    end
  end

  property "boolean" do
    forall b <- Generate.booleans() do
      is_boolean(b)
    end
  end

  property "byte" do
    forall b <- Generate.bytes() do
      is_integer(b) && b >= 0 && b <= 255
    end
  end

  property "char" do
    forall c <- Generate.chars() do
      is_integer(c) && c >= 0 && c <= 0x10FFFF
    end
  end

  property "charlist" do
    forall l <- Generate.charlists() do
      is_list(l) &&
        Enum.all?(l, fn c ->
          is_integer(c) && c >= 0 && c <= 0x10FFFF
        end)
    end
  end

  property "nonempty charlist" do
    forall l <- Generate.nonempty_charlists() do
      is_list(l) &&
        l != [] &&
        Enum.all?(l, fn c ->
          is_integer(c) && c >= 0 && c <= 0x10FFFF
        end)
    end
  end

  property "fun" do
    forall f <- Generate.funs() do
      is_function(f)
    end
  end

  property "any keyword" do
    forall kw <- Generate.any_keywords() do
      is_list(kw) &&
        Enum.all?(kw, fn t -> is_tuple(t) && tuple_size(t) == 2 && is_atom(elem(t, 0)) end)
    end
  end

  property "typed keyword" do
    forall kw <- Generate.keywords(Generate.integers()) do
      is_list(kw) &&
        Enum.all?(kw, fn t ->
          is_tuple(t) && tuple_size(t) == 2 && is_atom(elem(t, 0)) && is_integer(elem(t, 1))
        end)
    end
  end

  property "list of any" do
    forall l <- Generate.any_lists() do
      is_list(l)
    end
  end

  property "nonempty list of any" do
    forall l <- Generate.any_nonempty_lists() do
      is_list(l) && l != []
    end
  end

  property "mfa" do
    forall mfa <- Generate.mfas() do
      case mfa do
        {m, f, a} ->
          is_atom(m) && is_atom(f) && is_integer(a)

        _ ->
          false
      end
    end
  end

  property "module" do
    forall m <- Generate.modules() do
      is_atom(m)
    end
  end

  property "node" do
    forall n <- Generate.nodes() do
      is_atom(n)
    end
  end

  property "number" do
    forall n <- Generate.numbers() do
      is_integer(n) || is_float(n)
    end
  end

  property "timeout" do
    forall t <- Generate.timeouts() do
      t == :infinity || is_integer(t)
    end
  end

  property "remote type" do
    forall s <- Generate.my_string() do
      is_binary(s)
    end
  end

  property "remote type with type args" do
    forall kw <- Generate.my_keyword(Generate.integers()) do
      is_list(kw) &&
        Enum.all?(kw, fn t -> is_tuple(t) && is_atom(elem(t, 0)) && is_integer(elem(t, 1)) end)
    end
  end

  #
  # Referring to local user type
  #
  property "local user type" do
    forall b <- Generate.my_binary() do
      is_binary(b)
    end
  end

  property "parametrized local user type" do
    forall l <- Generate.my_list(Generate.integers()) do
      Enum.all?(l, &is_integer/1)
    end
  end

  #
  # Discouraged Types
  #

  property "erlang string" do
    forall l <- Generate.erlang_strings() do
      is_list(l) && Enum.all?(l, &is_integer/1)
    end
  end

  property "nonempty erlang string" do
    forall l <- Generate.nonempty_erlang_strings() do
      is_list(l) && l != [] && Enum.all?(l, &is_integer/1)
    end
  end
end

defmodule SampleModule do
  # Sample module with all types from https://hexdocs.pm/elixir/typespecs.html
  #
  # NOTE: This module must be placed before the actual test module when using `async: true`.
  #

  use PropCheck.Derive

  # UNSUPPORTED @type nones :: none()

  #
  # Basic Types
  #
  @type anys :: any()
  @type atoms :: atom()
  @type maps :: map()
  # # UNSUPPORTED @type pids :: pid()
  # # UNSUPPORTED @type ports :: port()
  # # UNSUPPORTED @type references :: reference()
  @type structs :: struct()
  @type tuples :: tuple()

  @type integers :: integer()
  @type floats :: float()
  @type non_neg_integers :: non_neg_integer()
  @type pos_integers :: pos_integer()
  @type neg_integers :: neg_integer()

  @type lists_integers :: list(integer())
  @type lists(type) :: list(type)
  @type nonempty_lists(type) :: nonempty_list(type)
  # FIXME unknown semantics
  # @type maybe_improper_lists(type1, type2) :: maybe_improper_list(type1, type2)
  # FIXME unknown semantics
  # @type nonempty_improper_lists(type1, type2) :: nonempty_improper_list(type1, type2)
  # FIXME unknown semantics
  # @type nonempty_maybe_improper_lists(type1, type2) :: nonempty_maybe_improper_list(type1, type2)

  # #
  # # Literals
  # #

  # ## Atoms
  @type atom_literal :: :atom
  @type special_atom_literal :: true | false | nil

  # ## Bitstrings
  @type empty_bitstrings :: <<>>
  @type sized_bitstrings :: <<_::5>>
  @type unit_bitstrings :: <<_::_*10>>
  @type sized_unit_bitstrings :: <<_::5, _::_*10>>

  # ## (Anonymous) Functions

  @type zero_aritys :: (() -> any())
  @type two_aritys :: (any(), any() -> :ok)
  @type any_aritys1 :: (... -> any())
  @type any_aritys2 :: (... -> integer())

  # ## Integers
  @type one :: 1
  @type range :: 1..10

  # ## Lists
  @type empty_lists :: []
  @type any_number_lists :: [integer()]
  @type nonempty_lists_with_any :: [...]
  @type nonempty_lists_with_type(type) :: [type, ...]

  @type keyword_lists(value_type) :: [key1: value_type, key2: value_type, key3: value_type]

  defmodule SomeStruct do
    # Helper for %SomeStruct{} type
    defstruct [:key]
  end

  # ## Maps
  @type empty_maps :: %{}
  @type map_with_key(type1, type2) :: %{key1: type1, key2: type2}
  @type map_with_required_pairs(key_type, value_type) :: %{required(key_type) => value_type}
  @type map_with_optional_pairs(key_type, value_type) :: %{optional(key_type) => value_type}
  @type any_particular_struct :: %SomeStruct{}
  @type a_particular_struct_with_required_key(value_type) :: %SomeStruct{key: value_type}

  # ## Tuples

  @type empty_tuples :: {}
  @type two_element_tuples :: {:ok, integer()}

  # #
  # # Built-In
  # #

  @type terms :: term()
  @type aritys :: arity()
  @type as_booleans(t) :: as_boolean(t)
  @type binaries :: binary()
  @type bitstrings :: bitstring()
  @type booleans :: boolean()
  @type bytes :: byte()
  @type chars :: char()
  @type charlists :: charlist()
  @type nonempty_charlists :: nonempty_charlist()
  @type funs() :: fun()
  # # NOT SUPPORTED identifier() :: pid() | port() | reference()
  # # NOT SUPPORTED iodata :: iolist() | binary()
  # # NOT SUPPORTED iolist :: maybe_improper_list(byte() | binary() | iolist(), binary() | [])
  @type any_keywords :: keyword()
  @type keywords(type) :: keyword(type)
  @type any_lists :: list()
  @type any_nonempty_lists :: nonempty_list()
  # FIXME unknown semantics
  # @type any_maybe_improper_lists() :: maybe_improper_list()
  # FIXME unknown semantics
  # @type any_nonempty_maybe_improper_list :: nonempty_maybe_improper_list()
  @type mfas :: mfa()
  @type modules :: module()
  # NOT SUPPORTED no_return() :: none()
  @type nodes :: node()
  @type numbers :: number()
  # # Part of basic types:  struct() :: %{:__struct__ => atom(), optional(atom()) => any()}
  @type timeouts :: timeout()

  # # Remote Types

  use PropCheck.Derive, module: String, exclude: []
  @type my_string :: String.t()

  use PropCheck.Derive, module: Keyword, include: [t: 1, key: 0]
  @type my_keyword(type) :: Keyword.t(type)

  # # Local User Types

  # Referring to local user-defined types
  @type my_binary :: binaries()
  @type my_list(a) :: list(a)

  # # Discouraged Types
  @type erlang_strings() :: string()
  @type nonempty_erlang_strings() :: nonempty_string()
end

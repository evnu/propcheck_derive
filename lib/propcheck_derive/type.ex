defmodule PropCheck.Derive.Type do
  # FIXME the :name field is rather arbitrary for types without a given name, such as constants
  @enforce_keys [:name, :generator_block]
  defstruct [
    :name,
    :generator_block,
    module: :"Elixir",
    # FIXME define this as 'type arity' - on how many types does it depend directly?
    # FIXME integer or any
    arity: 0,
    generator: nil,
    vars: [],
    depends_on: nil,
    private: false
  ]

  @doc false
  def new(module, typename, typedef, vars) do
    # FIXME this is only needed for :user_type; is there a better way to get that into that one clause?
    Process.put(:module, module)

    case type_node(typedef) do
      {:ok, sparse_type_node} ->
        {:ok,
         %__MODULE__{
           module: module,
           name: typename,
           depends_on: [sparse_type_node],
           arity: arity(vars),
           vars: vars_to_macro_vars(vars),
           generator_block: sparse_type_node.generator_block
         }}

      error = {:error, _} ->
        error
    end
  end

  def leaf?(%__MODULE__{depends_on: depends_on}), do: is_nil(depends_on)

  # @type anys() :: any()
  defp type_node({:type, _, :any, []}) do
    {:ok,
     %__MODULE__{
       name: :any,
       generator_block: quote(do: any())
     }}
  end

  # @type atoms() :: atom()
  defp type_node({:type, _, :atom, []}) do
    {:ok,
     %__MODULE__{
       name: :atom,
       generator_block: quote(do: atom())
     }}
  end

  # @type maps() :: map()
  defp type_node({:type, _, :map, :any}) do
    {:ok, %__MODULE__{name: :map, generator_block: quote(do: map(any(), any()))}}
  end

  # @type empty_maps :: %{}
  defp type_node({:type, _, :map, []}) do
    {:ok, %__MODULE__{name: :map, generator_block: quote(do: %{})}}
  end

  # @type map_with_key(type1, type2) :: %{key1: type1, key2: type2}
  defp type_node({:type, _, :map, inner}) do
    arity = length(inner)

    case map_while_ok(inner, &type_node/1) do
      {:ok, inner_nodes = [%__MODULE__{} | _]} ->
        vars = Enum.map(inner_nodes, & &1.vars)
        inner_generator_blocks = Enum.map(inner_nodes, & &1.generator_block)

        {:ok,
         %__MODULE__{
           name: :map,
           arity: arity,
           vars: vars,
           depends_on: inner_nodes,
           generator_block:
             quote do
               let inner <- unquote(inner_generator_blocks) do
                 inner |> Enum.reject(&is_nil/1) |> Map.new()
               end
             end
         }}

      e = {:error, _} ->
        e
    end
  end

  # required map field as in
  # @type map_with_key(type1, type2) :: %{key1: type1, key2: type2}
  defp type_node({:type, _, :map_field_exact, inner = [_left, _right]}) do
    case map_while_ok(inner, &type_node/1) do
      {:ok, inner_nodes = [%__MODULE__{} | _]} ->
        vars = Enum.map(inner_nodes, & &1.vars)
        inner_generator_blocks = Enum.map(inner_nodes, & &1.generator_block)

        {:ok,
         %__MODULE__{
           name: :union,
           arity: 2,
           vars: vars,
           depends_on: inner_nodes,
           generator_block: quote(do: {unquote_splicing(inner_generator_blocks)})
         }}

      e = {:error, _} ->
        e
    end
  end

  # optional field as in
  # @type map_with_optional_pairs(key_type, value_type) :: %{optional(key_type) => value_type}
  defp type_node({:type, _, :map_field_assoc, inner = [_left, _right]}) do
    case map_while_ok(inner, &type_node/1) do
      {:ok, inner_nodes = [%__MODULE__{} | _]} ->
        vars = Enum.map(inner_nodes, & &1.vars)
        inner_generator_blocks = Enum.map(inner_nodes, & &1.generator_block)

        {:ok,
         %__MODULE__{
           name: :union,
           arity: 2,
           vars: vars,
           depends_on: inner_nodes,
           generator_block: quote(do: oneof([nil, {unquote_splicing(inner_generator_blocks)}]))
         }}

      e = {:error, _} ->
        e
    end
  end

  # @type structs() :: struct()
  defp type_node({:remote_type, _, [{:atom, _, :elixir}, {:atom, _, :struct}, []]}) do
    {:ok,
     %__MODULE__{
       name: :struct,
       generator_block:
         quote do
           let [
             m <- map(any(), any()),
             name <- atom()
           ] do
             Map.put(m, :__struct__, name)
           end
         end
     }}
  end

  # @type tuples() :: tuple()
  defp type_node({:type, _, :tuple, :any}) do
    {:ok, %__MODULE__{name: :tuple, generator_block: quote(do: tuple())}}
  end

  # @type tuples(var) :: {atom(), var()}
  # @type empty_tuples :: {}
  defp type_node({:type, _, :tuple, inner}) do
    arity = length(inner)

    case map_while_ok(inner, &type_node/1) do
      {:ok, []} ->
        {:ok,
         %__MODULE__{
           name: :tuple,
           generator_block: quote(do: {})
         }}

      {:ok, inner_nodes = [%__MODULE__{} | _]} ->
        vars = Enum.map(inner_nodes, & &1.vars)
        inner_generator_blocks = Enum.map(inner_nodes, & &1.generator_block)

        {:ok,
         %__MODULE__{
           name: :tuple,
           arity: arity,
           vars: vars,
           depends_on: inner_nodes,
           generator_block: quote(do: {unquote_splicing(inner_generator_blocks)})
         }}

      e = {:error, _} ->
        e
    end
  end

  # @type integers() :: integer()
  defp type_node({:type, _, :integer, []}) do
    {:ok, %__MODULE__{name: :integer, generator_block: quote(do: integer())}}
  end

  # @type floats :: float()
  defp type_node({:type, _, :float, []}) do
    {:ok, %__MODULE__{name: :float, generator_block: quote(do: float())}}
  end

  # @type non_neg_integers :: non_neg_integer()
  defp type_node({:type, _, :non_neg_integer, []}) do
    {:ok, %__MODULE__{name: :non_neg_integer, generator_block: quote(do: non_neg_integer())}}
  end

  # @type pos_integers :: pos_integer()
  defp type_node({:type, _, :pos_integer, []}) do
    {:ok,
     %__MODULE__{
       name: :pos_integer,
       generator_block: quote(do: pos_integer())
     }}
  end

  # @type neg_integers :: neg_integer()
  defp type_node({:type, _, :neg_integer, []}) do
    {:ok, %__MODULE__{name: :neg_integer, generator_block: quote(do: neg_integer())}}
  end

  # @type lists_integers :: list(integer())
  # @type keyword_lists(value_type) :: [key1: value_type, key2: value_type, key3: value_type]
  defp type_node({:type, _, :list, [inner]}) do
    case type_node(inner) do
      {:ok, inner_node = %__MODULE__{}} ->
        inner_generator_block = inner_node.generator_block

        {:ok,
         %__MODULE__{
           name: :list,
           arity: 1,
           vars: inner_node.vars,
           depends_on: [inner_node],
           generator_block: quote(do: list(unquote(inner_generator_block)))
         }}

      e = {:error, _} ->
        e
    end
  end

  # @type nonempty_lists(type) :: nonempty_list(type)
  # @type nonempty_lists(type) :: [type, ...]
  defp type_node(t = {:type, _, :nonempty_list, [_]}) do
    # this is a special case of list
    case t |> put_elem(2, :list) |> type_node() do
      {:ok, node = %__MODULE__{}} ->
        inner_generator_block = node.generator_block

        {:ok,
         %__MODULE__{node | generator_block: quote(do: non_empty(unquote(inner_generator_block)))}}

      error = {:error, _} ->
        error
    end
  end

  # a type variable encountered on the rhs
  defp type_node({:var, _, var_name}) do
    var = Macro.var(var_name, nil)

    {:ok,
     %__MODULE__{
       name: :type_var,
       generator_block: quote(do: unquote(var))
     }}
  end

  # @type maybe_improper_lists(type1, type2) :: maybe_improper_list(type1, type2)
  # @type nonempty_improper_lists(type1, type2) :: nonempty_improper_list(type1, type2)
  # @type nonempty_maybe_improper_lists(type1, type2) :: nonempty_maybe_improper_list(type1, type2)
  defp type_node(unclear = {:type, _, unknown_semantics, _})
       when unknown_semantics in [
              :maybe_improper_list,
              :nonempty_improper_list,
              :nonempty_maybe_improper_list
            ] do
    {:error,
     {:type_unclear, unclear, unknown_semantics,
      """
      * https://github.com/josefs/Gradualizer/issues/110:
        For @type t(a, b) :: maybe_improper_list(a, b), is b :: t(a, b)? And [] :: t(a, b)?
      * https://stackoverflow.com/a/1922724/436853
        Term is improper list if the terminator is not a list.
      """}}
  end

  # @type atom_literal :: :atom
  defp type_node({:atom, _, atom}) do
    {:ok,
     %__MODULE__{
       name: :atom_literal,
       generator_block: quote(do: unquote(atom))
     }}
  end

  # @type special_atom_literal :: true | false | nil
  defp type_node({:type, _, :union, inner}) do
    arity = length(inner)

    case map_while_ok(inner, &type_node/1) do
      {:ok, inner_nodes = [%__MODULE__{} | _]} ->
        vars = Enum.map(inner_nodes, & &1.vars)
        inner_generator_blocks = Enum.map(inner_nodes, & &1.generator_block)

        {:ok,
         %__MODULE__{
           name: :union,
           # FIXME shouldn't this be the arity of the inner nodes?
           arity: arity,
           vars: vars,
           depends_on: inner_nodes,
           generator_block: quote(do: oneof([unquote_splicing(inner_generator_blocks)]))
         }}

      e = {:error, _} ->
        e
    end
  end

  # @type empty_bitstrings :: <<>>
  defp type_node({:type, _, :binary, [{:integer, _, 0}, {:integer, _, 0}]}) do
    {:ok,
     %__MODULE__{
       name: :bitstring,
       generator_block: quote(do: <<>>)
     }}
  end

  # @type sized_bitstrings :: <<_::5>>
  defp type_node({:type, _, :binary, [{:integer, _, size}, {:integer, _, 0}]}) do
    {:ok,
     %__MODULE__{
       name: :sized_bitstring,
       generator_block: quote(do: bitstring(unquote(size)))
     }}
  end

  # @type unit_bitstrings :: <<_::_*10>>
  defp type_node({:type, _, :binary, [{:integer, _, 0}, {:integer, _, unit}]}) do
    {:ok,
     %__MODULE__{
       name: :unit_bitstring,
       generator_block:
         quote do
           let size <- non_neg_integer() do
             bitstring(size * unquote(unit))
           end
         end
     }}
  end

  # @type sized_unit_bitstrings :: <<_::5, _::_*10>>
  defp type_node({:type, _, :binary, [{:integer, _, unit}, {:integer, _, size}]}) do
    {:ok,
     %__MODULE__{
       name: :sized_unit_bitstring,
       generator_block: quote(do: bitstring(unquote(size) * unquote(unit)))
     }}
  end

  # @type zero_aritys :: (() -> any())
  # @type two_aritys :: (any(), any() -> any())
  defp type_node({:type, _, :fun, [{:type, _, :product, arguments}, result]}) do
    # FIXME document that the function does no computation, but simply returns a generated result
    case type_node(result) do
      {:ok, result = %__MODULE__{}} ->
        arity = length(arguments)
        result_generator_block = result.generator_block

        {:ok,
         %__MODULE__{
           name: :function,
           # FIXME is this the correct arity?
           arity: 1,
           depends_on: [result],
           generator_block: quote(do: function(unquote(arity), unquote(result_generator_block)))
         }}

      error = {:error, _} ->
        error
    end
  end

  # @type any_aritys2 :: (... -> integer())
  defp type_node({:type, _, :fun, [{:type, _, :any}, result]}) do
    case type_node(result) do
      {:ok, result = %__MODULE__{}} ->
        result_generator_block = result.generator_block

        {:ok,
         %__MODULE__{
           name: :function,
           # FIXME is this the correct arity?
           arity: :any,
           depends_on: [result],
           generator_block:
             quote do
               # PropEr has an arity limit for functions (search MAX_ARITY in the source)
               let arity <- integer(0, 20) do
                 function(arity, unquote(result_generator_block))
               end
             end
         }}

      error = {:error, _} ->
        error
    end
  end

  # @type any_aritys1 :: (... -> any())
  defp type_node({:type, _, :fun, []}) do
    {:ok,
     %__MODULE__{
       name: :function,
       # FIXME is this the correct arity?
       arity: :any,
       depends_on: nil,
       generator_block:
         quote do
           # PropEr has an arity limit for functions (search MAX_ARITY in the source)
           let arity <- integer(0, 20) do
             function(arity, any())
           end
         end
     }}
  end

  # @type one :: 1
  defp type_node({:integer, _, constant}) when is_integer(constant) do
    {:ok,
     %__MODULE__{
       name: :constant,
       generator_block: quote(do: unquote(constant))
     }}
  end

  # @type range :: 1..10
  # @type range :: -1..1
  defp type_node({:type, _, :range, [from, to]}) do
    from = to_signed(from)
    to = to_signed(to)

    {:ok,
     %__MODULE__{
       name: :range,
       generator_block: quote(do: integer(unquote(from), unquote(to)))
     }}
  end

  # @type empty_lists :: []
  defp type_node({:type, _, nil, []}) do
    {:ok,
     %__MODULE__{
       name: :empty_list,
       generator_block: quote(do: [])
     }}
  end

  # @type nonempty_lists_with_any :: [...]
  defp type_node({:type, _, :nonempty_list, []}) do
    {:ok,
     %__MODULE__{
       name: :nonempty_any_list,
       generator_block: quote(do: non_empty([any()]))
     }}
  end

  # @type terms :: term()
  defp type_node(t = {:type, _, :term, []}) do
    t |> put_elem(2, :any) |> type_node()
  end

  # @type aritys :: arity()
  defp type_node({:type, _, :arity, []}) do
    {:ok,
     %__MODULE__{
       name: :arity,
       generator_block: quote(do: integer(0, :inf))
     }}
  end

  # @type as_booleans(t) :: as_boolean(t)
  defp type_node({:remote_type, _, [{:atom, _, :elixir}, {:atom, _, :as_boolean}, [inner]]}) do
    case type_node(inner) do
      {:ok, inner_node = %__MODULE__{}} ->
        inner_generator_block = inner_node.generator_block

        {:ok,
         %__MODULE__{
           name: :as_boolean,
           arity: 1,
           vars: inner_node.vars,
           depends_on: [inner_node],
           generator_block: quote(do: unquote(inner_generator_block))
         }}

      e = {:error, _} ->
        e
    end
  end

  # @type binaries :: binary()
  defp type_node({:type, _, :binary, []}) do
    {:ok,
     %__MODULE__{
       name: :binary,
       generator_block: quote(do: binary())
     }}
  end

  # @type bitstrings :: bitstring()
  defp type_node({:type, _, :bitstring, []}) do
    {:ok,
     %__MODULE__{
       name: :bitstring,
       generator_block: quote(do: bitstring())
     }}
  end

  # @type booleans :: boolean()
  defp type_node({:type, _, :boolean, []}) do
    {:ok,
     %__MODULE__{
       name: :boolean,
       generator_block: quote(do: boolean())
     }}
  end

  # @type bytes :: byte()
  defp type_node({:type, _, :byte, []}) do
    {:ok,
     %__MODULE__{
       name: :byte,
       generator_block: quote(do: integer(0, 255))
     }}
  end

  # @type chars :: char()
  defp type_node({:type, _, :char, []}) do
    {:ok,
     %__MODULE__{
       name: :char,
       generator_block: quote(do: integer(0, 0x10FFF))
     }}
  end

  # @type charlists :: charlist()
  defp type_node({:remote_type, _, [{:atom, _, :elixir}, {:atom, _, :charlist}, []]}) do
    {:ok,
     %__MODULE__{
       name: :charlist,
       generator_block: quote(do: list(integer(0, 0x10FFF)))
     }}
  end

  # @type nonempty_charlists :: nonempty_charlist()
  defp type_node({:remote_type, _, [{:atom, _, :elixir}, {:atom, _, :nonempty_charlist}, []]}) do
    {:ok,
     %__MODULE__{
       name: :charlist,
       generator_block: quote(do: non_empty(list(integer(0, 0x10FFF))))
     }}
  end

  # @type any_keywords :: keyword()
  defp type_node({:remote_type, _, [{:atom, _, :elixir}, {:atom, _, :keyword}, []]}) do
    {:ok,
     %__MODULE__{
       name: :keyword,
       generator_block: quote(do: list({atom(), any()}))
     }}
  end

  # @type keywords(type) :: keyword(type)
  defp type_node({:remote_type, _, [{:atom, _, :elixir}, {:atom, _, :keyword}, [inner]]}) do
    case type_node(inner) do
      {:ok, inner_node = %__MODULE__{}} ->
        inner_generator_block = inner_node.generator_block

        {:ok,
         %__MODULE__{
           name: :as_boolean,
           arity: 1,
           vars: inner_node.vars,
           depends_on: [inner_node],
           generator_block: quote(do: list({atom(), unquote(inner_generator_block)}))
         }}

      e = {:error, _} ->
        e
    end
  end

  # @type any_lists :: list()
  defp type_node({:type, _, :list, []}) do
    {:ok,
     %__MODULE__{
       name: :list,
       generator_block: quote(do: list())
     }}
  end

  # @type @type mfas :: mfa()
  defp type_node({:type, _, :mfa, []}) do
    {:ok,
     %__MODULE__{
       name: :mfa,
       generator_block: quote(do: {atom(), atom(), integer(0, :inf)})
     }}
  end

  # @type modules :: module()
  defp type_node({:type, _, :module, []}) do
    {:ok,
     %__MODULE__{
       name: :module,
       generator_block: quote(do: atom())
     }}
  end

  # @type nodes :: node()
  defp type_node({:type, _, :node, []}) do
    {:ok,
     %__MODULE__{
       name: :node,
       generator_block: quote(do: atom())
     }}
  end

  # @type numbers :: number()
  defp type_node({:type, _, :number, []}) do
    {:ok,
     %__MODULE__{
       name: :number,
       generator_block: quote(do: number())
     }}
  end

  # @type timeouts :: timeout()
  defp type_node({:type, _, :timeout, []}) do
    {:ok,
     %__MODULE__{
       name: :timeout,
       generator_block: quote(do: oneof([:infinity, integer(0, :inf)]))
     }}
  end

  # @type my_string :: String.t()
  # @type my_keyword(type) :: Keyword.t(type)
  defp type_node({:remote_type, _, [{:atom, _, module}, {:atom, _, name}, inner]}) do
    arity = length(inner)
    remote_generator = Module.concat(module, Generate)

    case map_while_ok(inner, &type_node/1) do
      {:ok, inner_nodes = [%__MODULE__{} | _]} ->
        vars = Enum.map(inner_nodes, & &1.vars)
        inner_generator_blocks = Enum.map(inner_nodes, & &1.generator_block)

        {:ok,
         %__MODULE__{
           module: module,
           name: name,
           arity: arity,
           vars: vars,
           depends_on: inner_nodes,
           generator_block:
             quote do
               unquote(remote_generator).unquote(name)(unquote_splicing(inner_generator_blocks))
             end
         }}

      {:ok, []} ->
        {:ok,
         %__MODULE__{
           module: module,
           name: name,
           arity: arity,
           generator_block: quote(do: unquote(remote_generator).unquote(name)())
         }}

      e = {:error, _} ->
        e
    end
  end

  # @type my_binary :: binaries()
  defp type_node({:user_type, _, local_user_type, inner}) do
    arity = length(inner)

    case map_while_ok(inner, &type_node/1) do
      {:ok, inner_nodes = [%__MODULE__{} | _]} ->
        vars = Enum.map(inner_nodes, & &1.vars)
        inner_generator_blocks = Enum.map(inner_nodes, & &1.generator_block)

        {:ok,
         %__MODULE__{
           module: Process.get(:module),
           name: local_user_type,
           arity: arity,
           vars: vars,
           depends_on: inner_nodes,
           generator_block:
             quote(do: unquote(local_user_type)(unquote_splicing(inner_generator_blocks)))
         }}

      {:ok, []} ->
        {:ok,
         %__MODULE__{
           module: Process.get(:module),
           name: local_user_type,
           arity: arity,
           generator_block: quote(do: unquote(local_user_type)())
         }}

      e = {:error, _} ->
        e
    end
  end

  # @type annotated :: result :: integer()
  defp type_node({:ann_type, _, [_, actual_type]}) do
    type_node(actual_type)
  end

  # @type erlang_strings() :: string()
  defp type_node({:type, _, :string, []}) do
    # string() refers to erlang strings
    {:ok,
     %__MODULE__{
       name: :string,
       generator_block: quote(do: list(char()))
     }}
  end

  # @type nonempty_erlang_strings() :: nonempty_string()
  defp type_node({:type, _, :nonempty_string, []}) do
    {:ok,
     %__MODULE__{
       name: :string,
       generator_block: quote(do: non_empty(list(char())))
     }}
  end

  defp type_node(unsupported) do
    {:error, {:unsupported, unsupported}}
  end

  defp arity(vars) do
    length(vars)
  end

  defp vars_to_macro_vars(vars) do
    Enum.map(vars, fn {:var, _, var_name} -> Macro.var(var_name, nil) end)
  end

  defp map_while_ok(enum, fun) do
    Enum.reduce_while(enum, {:ok, []}, fn el, {:ok, acc} ->
      case fun.(el) do
        {:ok, r} -> {:cont, {:ok, [r | acc]}}
        e = {:error, _} -> {:halt, e}
      end
    end)
    |> case do
      {:ok, result} ->
        {:ok, Enum.reverse(result)}

      e = {:error, _} ->
        e
    end
  end

  defp to_signed({:op, _, :-, {:integer, _, constant}}) do
    -1 * constant
  end

  defp to_signed({:integer, _, constant}) do
    constant
  end
end

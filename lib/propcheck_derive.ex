defmodule PropCheck.Derive do
  @valid_keys [:include, :exclude, :module]

  defmacro __using__(args) do
    verify_args!(args)

    include = Keyword.get(args, :include)
    exclude = Keyword.get(args, :exclude)

    case Keyword.get(args, :module) do
      nil ->
        quote do
          @propcheck_only unquote(include)
          @propcheck_exclude unquote(exclude)
          @after_compile PropCheck.Derive
        end

      module ->
        derive_type_dependencies(module, nil, include, exclude)
    end
  end

  defp verify_args!(args) do
    include = Keyword.get(args, :include)
    exclude = Keyword.get(args, :exclude)

    unknown = Keyword.keys(args) -- @valid_keys

    cond do
      not is_nil(include) and not is_list(include) ->
        raise ArgumentError, ":include must be a list or nil"

      not is_nil(exclude) and not is_list(exclude) ->
        raise ArgumentError, ":exclude must be a list or nil"

      not is_nil(include) and not is_nil(exclude) ->
        raise ArgumentError, "Can only use either :include or :exclude"

      unknown != [] ->
        raise ArgumentError, """
        Unexpected key(s): #{inspect(unknown)}
        Valid keys are: #{inspect(@valid_keys)}
        """

      true ->
        :ok
    end
  end

  defmacro __after_compile__(_env, bytecode) do
    {:ok, {module, _}} = :beam_lib.chunks(bytecode, [:abstract_code])
    derive_type_dependencies(module, bytecode, nil, nil)
  end

  defp derive_type_dependencies(module, bytecode, include, exclude) do
    quote bind_quoted: [module: module, bytecode: bytecode, include: include, exclude: exclude] do
      {include, exclude} =
        try do
          {
            Module.get_attribute(module, :propcheck_only),
            Module.get_attribute(module, :propcheck_exclude)
          }
        rescue
          _ ->
            {include, exclude}
        end

      {:ok, types} =
        case Code.Typespec.fetch_types(bytecode || module) do
          :error ->
            raise ArgumentError, "Could not retrieve types for #{module}"

          other ->
            other
        end

      top_level_types =
        types
        |> Enum.filter(fn {key, _} -> key in [:type, :typep] end)
        |> Enum.filter(fn {_, {name, _, args}} ->
          is_nil(include) || {name, length(args)} in include
        end)
        |> Enum.reject(fn {_, {name, _, args}} ->
          not is_nil(exclude) and {name, length(args)} in exclude
        end)

      generators =
        top_level_types
        |> PropCheck.Derive.Forest.add_trees_from_ast!(module)
        |> PropCheck.Derive.Forest.generators()

      defs =
        quote do
          use PropCheck

          unquote_splicing(generators)
        end

      # XXX Debug
      # defs |> Macro.expand(__ENV__) |> Macro.to_string() |> IO.puts()

      module
      |> Module.concat(:Generate)
      |> Module.create(defs, Macro.Env.location(__ENV__))
    end
  end
end

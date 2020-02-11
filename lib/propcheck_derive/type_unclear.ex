defmodule PropCheck.Derive.Type.TypeUnclear do
  defexception [:module, :type_name, :type, :inner, :reason, :caused_by]

  @impl true
  def exception(args) do
    %__MODULE__{
      module: args.module,
      type: args.type,
      inner: args.inner,
      type_name: args.type_name,
      reason: args.reason,
      caused_by: args.caused_by
    }
  end

  @impl true
  def message(ex) do
    """
    Found #{inspect(ex.type_name)} in #{ex.module}. This type does not have
    a well-defined semantic.

    Reason:
    #{ex.reason}
    Full type: #{inspect(ex.type)}
    Unsupported: #{inspect(ex.caused_by)}
    """
  end
end

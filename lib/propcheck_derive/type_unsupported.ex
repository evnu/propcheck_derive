defmodule PropCheck.Derive.Type.TypeUnsupported do
  defexception [:module, :type, :caused_by]

  @impl true
  def exception(args) do
    %__MODULE__{
      module: args.module,
      type: args.type,
      caused_by: args.caused_by
    }
  end

  @impl true
  def message(ex) do
    """
    Found an unsupported type in module '#{ex.module}':

    Full type: #{inspect(ex.type)}
    Unsupported: #{inspect(ex.caused_by)}

    Please consider submitting a bug report on this case.
    """
  end
end

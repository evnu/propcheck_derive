defmodule PropCheck.Derive.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      PropCheck.Derive.Forest.Server
    ]

    opts = [strategy: :one_for_one, name: PropCheck.Derive.Forest.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

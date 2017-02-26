defmodule Cordial.Store do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false


    # Define workers and child supervisors to be supervised
    children = [
      supervisor(Cordial.Repo, [])
      # Starts a worker by calling: Cordial.Store.Worker.start_link(arg1, arg2, arg3)
      # worker(Cordial.Store.Worker, [arg1, arg2, arg3]),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Cordial.Store.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

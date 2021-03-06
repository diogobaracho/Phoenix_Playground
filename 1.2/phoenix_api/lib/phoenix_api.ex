defmodule PhoenixApi do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      worker(GuardianDb.ExpiredSweeper, []),
      # Start the Ecto repository
      supervisor(PhoenixApi.Repo, []),
      # Start the endpoint when the application starts
      supervisor(PhoenixApi.Endpoint, []),
      # Start your own worker by calling: PhoenixApi.Worker.start_link(arg1, arg2, arg3)
      # worker(PhoenixApi.Worker, [arg1, arg2, arg3]),
      PhoenixApi.EventManager.child_spec
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PhoenixApi.Supervisor]

    with {:ok, pid} <- Supervisor.start_link(children, opts),
      :ok <- PhoenixApi.EventManager.register_event_manager(), do: {:ok, pid}
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    PhoenixApi.Endpoint.config_change(changed, removed)
    :ok
  end
end

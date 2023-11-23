defmodule LiveGuardTestEndpoint do
  @moduledoc false

  use Phoenix.Endpoint, otp_app: :live_guard
end

defmodule LiveGuardTestApplication do
  @moduledoc false

  use Application

  @impl true
  @spec start(type :: term(), args :: term()) :: {:error, term()} | {:ok, pid()}
  def start(_type, _args),
    do:
      Supervisor.start_link([LiveGuardTestEndpoint],
        strategy: :one_for_one,
        name: LiveGuardTestSupervisor
      )
end

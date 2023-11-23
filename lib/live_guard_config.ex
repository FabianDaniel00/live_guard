defmodule LiveGuard.Config do
  @moduledoc ~S"""
  The config module of LiveGuard.
  """

  alias LiveGuard.Helpers

  @default_configs [
    current_user: :current_user,
    unauthorized_handler: {Helpers, :handle_unauthorized}
  ]

  @typedoc "The default configs."
  @type default_configs() :: [
          current_user: :current_user,
          unauthorized_handler: {LiveGuard.Helpers, :handle_unauthorized}
        ]

  @doc "The default configs of LiveGuard."
  @spec default_configs() :: default_configs()
  def default_configs(), do: @default_configs

  @doc ~S"""
  The `:current_user` config of LiveGuard.

  **You need to assign the current user to the socket before LiveGuard [`on_mount/4`](https://hexdocs.pm/live_guard/LiveGuard.html#on_mount/4) callback is called.**.
  The default assign name for the current user is `:current_user`.
  If you assign the current user as another than `:current_user` you can set in the config:
  ```elixir
  config :live_guard, :current_user, :user
  ```
  """
  @spec current_user() :: atom()
  def current_user(),
    do: Application.get_env(:live_guard, :current_user, @default_configs[:current_user])

  @doc ~S"""
  The `:unauthorized_handler` config of LiveGuard.

  This function handles unauthorized LiveView lifecycle stages.
  It's called when the [`allowed?/4`](https://hexdocs.pm/live_guard/LiveGuard.Allowed.html#allowed?/4) function returns `false`.

  By default it will put an error flash message with text "_You don't have permission to do that!_".

  `:mount` and `:handle_params` LiveView lifecycle stages needs redirect after it detected as unauthorized.
  In this case by default it will redirect to the home page (`/`).

  You can set a custom handler in the config:
  ```elixir
  config :live_guard, :unauthorized_handler, {MyModule, :my_handle_unauthorized}
  ```
  It's called with 2 inputs, first is a `socket`, second is `is_redirect` _(boolean)_.
  """
  @spec unauthorized_handler() :: {module(), atom()}
  def unauthorized_handler(),
    do:
      Application.get_env(
        :live_guard,
        :unauthorized_handler,
        @default_configs[:unauthorized_handler]
      )
end

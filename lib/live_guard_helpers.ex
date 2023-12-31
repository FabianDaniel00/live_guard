defmodule LiveGuard.Helpers do
  @moduledoc ~S"""
  Helpers module of LiveGuard.
  """

  import Phoenix.LiveView, only: [put_flash: 3, redirect: 2]

  alias Phoenix.LiveView.Socket

  @doc ~S"""
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
  @spec handle_unauthorized(socket :: Socket.t(), is_redirect :: boolean()) :: Socket.t()
  def handle_unauthorized(socket, false = _is_redirect),
    do: put_flash(socket, :error, not_authorized_message())

  def handle_unauthorized(socket, _is_redirect),
    do: socket |> handle_unauthorized(false) |> redirect(to: "/")

  @doc false
  @spec not_authorized_message() :: binary()
  def not_authorized_message(), do: "You don't have permission to do that!"
end

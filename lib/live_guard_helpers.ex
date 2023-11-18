defmodule LiveGuard.Helpers do
  @moduledoc """
  Helpers module of LiveGuard.
  """

  import Phoenix.LiveView, only: [put_flash: 3, redirect: 2]

  @doc """
  This function handles unauthorized LiveView lifecycle stages.
  It's called when the `allowed?/4` function return `false`.

  By default it will put an error flash message with text "_You don't have permission to do that!_".

  `:mount`, `:handle_params` and `:after_render` LiveView lifecycle stages needs redirect after it detected as unauthorized.
  In this case by default it will redirect to the home page (`/`).

  You can set a custom handler in the config:
  ```elixir
  config :live_guard, :unauthorized_handler, {MyModule, :my_handle_unauthorized}
  ```
  """
  def handle_unauthorized(socket, false),
    do: put_flash(socket, :error, "You don't have permission to do that!")

  def handle_unauthorized(socket, _is_redirect),
    do: socket |> handle_unauthorized(false) |> redirect(to: "/")
end

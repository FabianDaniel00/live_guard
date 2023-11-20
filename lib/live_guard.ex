defmodule LiveGuard do
  @moduledoc """
  A simple module with `on_mount/4` callback. This can used in [Phoenix LiveView](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html#on_mount/1) applications.
  The main goal is to protect the Phoenix LiveView lifecycle stages easily.
  It uses the [`attach_hook/4`](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html#attach_hook/4) function to authorize all attachable LiveView lifecycle stages.
  """

  import Phoenix.LiveView, only: [attach_hook: 4]
  import LiveGuard.Allowed, only: [allowed?: 4]
  import LiveGuard.GuardedStages, only: [guarded_stages: 1]

  alias LiveGuard.{Helpers, GuardedStages}
  alias Phoenix.LiveView.Socket

  @attachable_lifecycle_stages [:handle_params, :handle_event, :handle_info, :after_render]

  @current_user Application.compile_env(:live_guard, :current_user, :current_user)
  @unauthorized_handler Application.compile_env(
                          :live_guard,
                          :unauthorized_handler,
                          {Helpers, :handle_unauthorized}
                        )

  @doc """
  You can find the documentation of `on_mount/1` [here](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html#on_mount/1).
  """

  @spec on_mount(:default, map(), map(), Socket.t()) :: {:cont | :halt, Socket.t()}
  def on_mount(:default, params, session, socket),
    do:
      (allowed?(
         :erlang.map_get(@current_user, socket.assigns),
         socket.view,
         :mount,
         {params, session, socket}
       ) &&
         {:cont,
          Enum.reduce(
            (GuardedStages.impl_for(:atom) && guarded_stages(socket.view)) ||
              @attachable_lifecycle_stages,
            socket,
            fn stage, socket ->
              attach_hook(
                socket,
                "live_guard_#{stage}",
                stage,
                hook_fn(stage)
              )
            end
          )}) || {:halt, unauthorized_handler({socket, true})}

  @spec hook_fn(:handle_params | :handle_event | :handle_info | :after_render) ::
          (... -> {:cont | :halt, Socket.t()})
  defp hook_fn(:handle_params = stage),
    do: fn params, uri, socket ->
      (allowed?(socket.assigns[@current_user], socket.view, stage, {params, uri, socket}) &&
         {:cont, socket}) || {:halt, unauthorized_handler({socket, true})}
    end

  defp hook_fn(:handle_event = stage),
    do: fn event, params, socket ->
      (allowed?(socket.assigns[@current_user], socket.view, stage, {event, params, socket}) &&
         {:cont, socket}) || {:halt, unauthorized_handler({socket, false})}
    end

  defp hook_fn(:handle_info = stage),
    do: fn msg, socket ->
      (allowed?(socket.assigns[@current_user], socket.view, stage, {msg, socket}) &&
         {:cont, socket}) || {:halt, unauthorized_handler({socket, false})}
    end

  defp hook_fn(:after_render = stage),
    do: fn socket ->
      (allowed?(socket.assigns[@current_user], socket.view, stage, {socket}) && socket) ||
        unauthorized_handler({socket, true})
    end

  @spec unauthorized_handler({Socket.t(), boolean()}) :: Socket.t()
  defp unauthorized_handler({socket, is_redirect}),
    do:
      @unauthorized_handler
      |> elem(0)
      |> apply(elem(@unauthorized_handler, 1), [socket, is_redirect])

  @doc """
  This macro can be used with [`@before_compile`](https://hexdocs.pm/elixir/Module.html#module-before_compile) hook.

  It will add a catch-all `allowed?/4` function returning `true`, to the end the module.

  ## Example

  ```elixir
  defimpl LiveGuard.Allowed, for: User do
    @before_compile {LiveGuard, :before_compile_allowed}

    # some code...
  end
  ```
  """

  @spec before_compile_allowed(map()) :: tuple()
  defmacro before_compile_allowed(_env),
    do: quote(do: def(allowed?(_user, _live_view_module, _stage, _stage_inputs), do: true))

  @doc """
  This macro can be used with [`@before_compile`](https://hexdocs.pm/elixir/Module.html#module-before_compile) hook.

  It will add a catch-all `guarded_stages/1` function returning all the [valid attachable LiveView lifecycle stages](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html#attach_hook/4), to the end the module.

  ## Example

  ```elixir
  defimpl LiveGuard.GuardedStages, for: Atom do
    @before_compile {LiveGuard, :before_compile_guarded_stages}

    # some code...
  end
  ```
  """

  @spec before_compile_guarded_stages(map()) :: tuple()
  defmacro before_compile_guarded_stages(_env),
    do:
      quote(do: def(guarded_stages(_live_view_module), do: unquote(@attachable_lifecycle_stages)))
end

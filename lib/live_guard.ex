defmodule LiveGuard do
  @moduledoc ~S"""
  A simple module with `on_mount/4` callback. This can used in [Phoenix LiveView](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html#on_mount/1) applications.
  The main goal is to protect the Phoenix LiveView lifecycle stages easily.
  It uses the [`attach_hook/4`](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html#attach_hook/4) function to authorize attachable LiveView lifecycle stages (`:handle_params`, `:handle_event`, `:handle_info` and `:handle_async`).
  """

  @typedoc "The [attachable LiveView lifecycle stages](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html#attach_hook/4) (`:handle_params`, `:handle_event`, `:handle_info` and `:handle_async`)."
  @type attachable_lifecycle_stages() ::
          :handle_params | :handle_event | :handle_info | :handle_async

  import Phoenix.LiveView, only: [attach_hook: 4]
  import LiveGuard.Allowed, only: [allowed?: 4]
  import LiveGuard.GuardedStages, only: [guarded_stages: 1]
  import LiveGuard.Config

  alias LiveGuard.GuardedStages
  alias Phoenix.LiveView
  alias LiveView.Socket

  @attachable_lifecycle_stages [:handle_params, :handle_event, :handle_info, :handle_async]

  @doc ~S"""
  All attachable LiveView lifecycle stages by LiveGuard.
  """
  @spec attachable_lifecycle_stages() :: [attachable_lifecycle_stages()]
  def attachable_lifecycle_stages(), do: @attachable_lifecycle_stages

  @doc ~S"""
  You can find the documentation of `on_mount/1` [here](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html#on_mount/1).
  """
  @spec on_mount(
          on_mount_name :: :default,
          params :: LiveView.unsigned_params() | :not_mounted_at_router,
          session :: map(),
          socket :: Socket.t()
        ) :: {:cont | :halt, socket :: Socket.t()}
  def on_mount(:default = _on_mount_name, params, session, socket),
    do:
      (allowed?(
         :erlang.map_get(current_user(), socket.assigns),
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

  @spec hook_fn(stage :: :handle_params) ::
          (unsigned_params :: LiveView.unsigned_params(),
           uri :: String.t(),
           socket :: Socket.t() ->
             {:cont | :halt, socket :: Socket.t()})
  defp hook_fn(:handle_params = stage),
    do: fn unsigned_params, uri, socket ->
      (allowed?(
         :erlang.map_get(current_user(), socket.assigns),
         socket.view,
         stage,
         {unsigned_params, uri, socket}
       ) &&
         {:cont, socket}) || {:halt, unauthorized_handler({socket, true})}
    end

  @spec hook_fn(stage :: :handle_event) ::
          (event :: binary(),
           unsigned_params :: LiveView.unsigned_params(),
           socket :: Socket.t() ->
             {:cont | :halt, socket :: Socket.t()})
  defp hook_fn(:handle_event = stage),
    do: fn event, unsigned_params, socket ->
      (allowed?(
         :erlang.map_get(current_user(), socket.assigns),
         socket.view,
         stage,
         {event, unsigned_params, socket}
       ) &&
         {:cont, socket}) || {:halt, unauthorized_handler({socket, false})}
    end

  @spec hook_fn(stage :: :handle_info) ::
          (msg :: term(), socket :: Socket.t() -> {:cont | :halt, socket :: Socket.t()})
  defp hook_fn(:handle_info = stage),
    do: fn msg, socket ->
      (allowed?(
         :erlang.map_get(current_user(), socket.assigns),
         socket.view,
         stage,
         {msg, socket}
       ) &&
         {:cont, socket}) || {:halt, unauthorized_handler({socket, false})}
    end

  @spec hook_fn(stage :: :handle_async) ::
          (name :: atom(), async_fun_result :: {:ok | :exit, term()}, socket :: Socket.t() ->
             {:cont | :halt, socket :: Socket.t()})
  defp hook_fn(:handle_async = stage),
    do: fn name, async_fun_result, socket ->
      (allowed?(
         :erlang.map_get(current_user(), socket.assigns),
         socket.view,
         stage,
         {name, async_fun_result, socket}
       ) &&
         {:cont, socket}) || {:halt, unauthorized_handler({socket, false})}
    end

  @spec unauthorized_handler({socket :: Socket.t(), is_redirect :: boolean()}) :: Socket.t()
  defp unauthorized_handler({socket, is_redirect}),
    do:
      unauthorized_handler()
      |> elem(0)
      |> apply(elem(unauthorized_handler(), 1), [socket, is_redirect])

  @doc ~S"""
  #### _Optional_

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
  @spec before_compile_allowed(env :: map()) :: tuple()
  defmacro before_compile_allowed(_env),
    do: quote(do: def(allowed?(_user, _live_view_module, _stage, _stage_inputs), do: true))

  @doc ~S"""
  #### _Optional_

  This macro can be used with [`@before_compile`](https://hexdocs.pm/elixir/Module.html#module-before_compile) hook.

  It will add a catch-all `guarded_stages/1` function returning the [valid attachable LiveView lifecycle stages](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html#attach_hook/4) (`:handle_params`, `:handle_event`, `:handle_info` and `:handle_async`), to the end the module.

  ## Example

  ```elixir
  defimpl LiveGuard.GuardedStages, for: Atom do
    @before_compile {LiveGuard, :before_compile_guarded_stages}

    # some code...
  end
  ```
  """
  @spec before_compile_guarded_stages(env :: map()) :: tuple()
  defmacro before_compile_guarded_stages(_env),
    do:
      quote(do: def(guarded_stages(_live_view_module), do: unquote(@attachable_lifecycle_stages)))
end

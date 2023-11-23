defprotocol LiveGuard.Allowed do
  @moduledoc ~S"""
  By this protocol you can implement `allowed?/4` functions.
  """

  alias Phoenix.LiveView
  alias LiveView.Socket

  @doc ~S"""
  By this function you can protect the LiveView lifecycle stages.

  You can pattern match by the **user**, **LiveView module**, **LiveView lifecycle stage** and **LiveView lifecycle stage inputs**.
  You can put this file anywhere but `/lib/my_app_web/live/abilities.ex` is recommended.

  **It must return a boolean.**

  ## Example

  ```elixir
  # /lib/my_app_web/live/abilities.ex

  defimpl LiveGuard.Allowed, for: User do
    @before_compile {LiveGuard, :before_compile_allowed}

    def allowed?(
          %User{role: role},
          MyModuleLive,
          :handle_event,
          {"delete_item", _unsigned_params, _socket}
        )
        when role in [:viewer, :customer],
        do: false

    # other `allowed?/4` functions...
  end
  ```
  > Note: As you can see, you don't have to define catch-all `allowed?/4` function because we used `@before_compile {LiveGuard, :before_compile_allowed}` hook. It returns `true`. This is optional.

  If the user is not authenticated you can add the following implementation as below:
  ```elixir
  defimpl LiveGuard.Allowed, for: Atom do
    @before_compile {LiveGuard, :before_compile_allowed}

    def allowed?(nil, MyModuleLive, :handle_event, {"delete_item", _unsigned_params, _socket}),
      do: false

    # other `allowed?/4` functions...
  end
  ```
  """
  @typedoc "A user struct or nil when the user is not authenticated."
  @type t() :: struct() | nil
  @spec allowed?(
          user :: struct() | nil,
          live_view_module :: module(),
          stage :: :mount,
          stage_inputs ::
            {params :: LiveView.unsigned_params() | :not_mounted_at_router, session :: map(),
             socket :: Socket.t()}
        ) :: boolean()
  @spec allowed?(
          user :: struct() | nil,
          live_view_module :: module(),
          stage :: :handle_params,
          stage_inputs ::
            {unsigned_params :: LiveView.unsigned_params(), uri :: String.t(),
             socket :: Socket.t()}
        ) :: boolean()
  @spec allowed?(
          user :: struct() | nil,
          live_view_module :: module(),
          stage :: :handle_event,
          stage_inputs ::
            {event :: binary(), unsigned_params :: LiveView.unsigned_params(),
             socket :: Socket.t()}
        ) :: boolean()
  @spec allowed?(
          user :: struct() | nil,
          live_view_module :: module(),
          stage :: :handle_info,
          stage_inputs :: {msg :: term(), socket :: Socket.t()}
        ) :: boolean()
  def allowed?(user, live_view_module, stage, stage_inputs)
end

defprotocol LiveGuard.GuardedStages do
  @moduledoc ~S"""
  #### _Optional_

  By this protocol you can implement `guarded_stages/1` functions.
  """

  @doc ~S"""
  #### _Optional_

  This function is for optimization.

  By default if you use the `on_mount/4` callback of LiveGuard, it will attach hooks to attachable LiveView lifecycle stages (`:handle_params`, `:handle_event` and `:handle_info`).

  If you need to protect for example only the `:handle_event` LiveView lifecycle stage for an individual LiveView module you can use this function.
  You can put this file anywhere but `/lib/my_app_web/live/guarded_stages.ex` is recommended.

  **It must return a list of [valid attachable LiveView lifecycle stages](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html#attach_hook/4) (unless `:after_render`).**

  ## Example

  ```elixir
  # /lib/my_app_web/live/guarded_stages.ex

  defimpl LiveGuard.GuardedStages, for: Atom do
    @before_compile {LiveGuard, :before_compile_guarded_stages}

    def guarded_stages(MyModuleLive), do: [:handle_event]

    # other `guarded_stages?/1` functions...
  end
  ```
  In this case it will only attach hook to `:handle_event` LiveView lifecycle stage.
  > Note: As you can see, you don't have to define catch-all `guarded_stages/1` function because we used `@before_compile {LiveGuard, :before_compile_guarded_stages}` hook. It returns the attachable LiveView lifecycle stages (`:handle_params`, `:handle_event` and `:handle_info`). This is optional.
  """
  @typedoc "A LiveView module."
  @type t() :: module()
  @spec guarded_stages(live_view_module :: module()) :: [LiveGuard.attachable_lifecycle_stages()]
  def guarded_stages(live_view_module)
end

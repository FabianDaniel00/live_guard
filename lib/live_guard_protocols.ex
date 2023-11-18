defprotocol LiveGuard.Allowed do
  @moduledoc """
  By this protocol you can implement `allowed?/4` functions.
  """

  @fallback_to_any true

  @doc """
  By this function you can protect the LiveView lifecycle stages.

  You can pattern match by the user, LiveView module, LiveView lifecycle stage and LiveView lifecycle stage inputs.
  You can put this file anywhere but I recommend `/lib/my_app_web/live/abilities.ex`.
  It must return boolean.

  ## Example

  ```elixir
  # /lib/my_app_web/live/abilities.ex

  defimpl LiveGuard.Allowed, for: User do
    @before_compile {LiveGuard, :before_compile_allowed}

    def allowed?(
          %User{role: role},
          MyModuleLive,
          :handle_event,
          {"delete_item", _params, _socket}
        )
        when role in [:customer],
        do: false

    # other `allowed?/4` functions
  end
  ```
  > Note: As you can see, you don't have to define catch-all `allowed?/4` function because we used `@before_compile {LiveGuard, :before_compile_allowed}` hook. It returns `true`.
  """
  def allowed?(user, live_view_module, stage, stage_inputs)
end

defprotocol LiveGuard.GuardedStages do
  @moduledoc """
  By this protocol you can implement `guarded_stages/1` functions.
  """

  @doc """
  This function is for optimization.

  By default if you use the `on_mount/4` callback of LiveGuard will attach hooks to all attachable LiveView lifecycle stages (`:handle_params`, `:handle_event`, `:handle_info` and `:after_render`).
  If you need to protect for example only the `:handle_event` LiveView lifecycle stage for an individual LiveView module you can use this function.
  You can put this file anywhere but I recommend `/lib/my_app_web/live/guarded_stages.ex`.
  It must return a list of valid attachable LiveView lifecycle stages.

  ## Example

  ```elixir
  # /lib/my_app_web/live/guarded_stages.ex

  defimpl LiveGuard.GuardedStages, for: Atom do
    @before_compile {LiveGuard, :before_compile_guarded_stages}

    def guarded_stages(MyModuleLive), do: [:handle_event]

    # other `guarded_stages?/1` functions
  end
  ```
  In this case it will only attach hook to `:handle_event` LiveView lifecycle stage.
  > Note: As you can see, you don't have to define catch-all `guarded_stages/1` function because we used `@before_compile {LiveGuard, :before_compile_guarded_stages}` hook. It returns all the attachable LiveView lifecycle stages.
  """
  def guarded_stages(live_view_module)
end

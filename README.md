# LiveGuard

A simple package to protect the LiveView lifecycle stages such as `:mount`, `:handle_params`, `:handle_event`, `:handle_info` and `:after_render`.

## Installation

For the latest master:
```elixir
def deps do
  [
    {:live_guard, github: "FabianDaniel00/live_guard"}
  ]
end
```
For the latest release:
```elixir
def deps do
  [
    {:live_guard, "~> 0.1.0"}
  ]
end
```
Then run `mix deps.get` to fetch the dependencies.

## Config

- `:current_user`

  You need to assign the current user to socket.
  The default assign name for the current user is `:current_user`.
  If you assign the current user as another than `:current_user` you can set in config:
  ```elixir
  config :live_guard, :current_user, :user
  ```

- `:unauthorized_handler`

  This function handles unauthorized LiveView lifecycle stages.
  It's called when the `allowed/4` function return `false`.

  By default it will put an error flash message with text "_You don't have permission to do that!_".

  `:mount`, `:handle_params` and `:after_render` LiveView lifecycle stages needs redirect after it detected as unauthorized.
  In this case by default it will redirect to the home page (`/`).

  You can set a custom handler in the config:
  ```elixir
  config :live_guard, :unauthorized_handler, {MyModule, :my_handle_unauthorized}
  ```
  It called with 2 inputs, first is a `socket`, second is `is_redirect`.

## Usage

LiveGuard provide an `on_mount/4` callback which can be used in Phoenix LiveViews. [Read the docs](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html#on_mount/1).
Since this is an `on_mount` callback you can use it with [`live_session/3`](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.Router.html#live_session/3) to protect a couple routes at once.

```elixir
# lib/my_app_web/router.ex
defmodule MyAppWeb.Router do
  use MyAppWeb, :router

  live_session :default, on_mount: LiveGuard do
    # routes...
  end
end
```
If you want to protect LiveView lifecycle stages in every LiveView you can achive that with the following code:
```elixir
# lib/my_app_web.ex
defmodule MyAppWeb do
  # some code...

  def live_view do
    quote do
      use Phoenix.LiveView, layout: {MyAppWeb.Layouts, :app}

      on_mount LiveGuard

      unquote(html_helpers())
    end
  end

  # some code...
end
```
And if you want to protect individual LiveView you can achive that with the following code:
```elixir
# lib/my_app_web/live/my_module_live.ex
defmodule MyAppWeb.MyModuleLive do
  use MyAppWeb, :live_view

  on_mount LiveGuard

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  # some code...
end
```

#### Implementing

For now you should ask, _okay but how it will know how to protect the LiveView lifecycle stages?_

You need to implement `allowed?/4` protocol functions.
The first input of `allowed/4` is the user, the second is the LiveView module, the third is the LiveView lifecycle stage and the last is LiveView lifecycle stage inputs. In this way you can pattern match to your needings. You can put this file anywhere but I recommend `/lib/my_app_web/live/abilities.ex`.
It must return boolean.

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

If the user is not athenticated you can add the following implementation as below:
```elixir
defimpl LiveGuard.Allowed, for: Atom do
  @before_compile {LiveGuard, :before_compile_allowed}

  def allowed?(nil, MyModuleLive, :handle_event, {"delete_item", _params, _socket}),
    do: false
end
```

#### Optimization

By default if you use the `on_mount/4` callback of LiveGuard will attach hooks to all attachable LiveView lifecycle stages (`:handle_params`, `:handle_event`, `:handle_info` and `:after_render`).
If you need to protect for example only the `:handle_event` LiveView lifecycle stage for an individual LiveView module you can use this function. You can put this file anywhere but I recommend `/lib/my_app_web/live/guarded_stages.ex`.
It must return a list of valid attachable LiveView lifecycle stages.

##### Example

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

## Few words from the author
[GitHub](https://github.com/FabianDaniel00/live_guard)

_This package is inspired by [canary](https://github.com/cpjk/canary)._

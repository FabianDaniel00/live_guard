defmodule LiveGuard.ConfigTest do
  use ExUnit.Case

  alias LiveGuard.Config

  doctest LiveGuard.Config

  test "default" do
    default_configs = Config.default_configs()

    assert default_configs[:current_user] == Config.current_user()
    assert default_configs[:unauthorized_handler] == Config.unauthorized_handler()
  end

  test "custom" do
    current_user = :user
    Application.put_env(:live_guard, :current_user, current_user)
    assert current_user == Config.current_user()

    unauthorized_handler = {DummyTestModule, :handle_unauthorized_stage}
    Application.put_env(:live_guard, :unauthorized_handler, unauthorized_handler)
    assert unauthorized_handler == Config.unauthorized_handler()

    default_configs = Config.default_configs()
    Application.put_env(:live_guard, :current_user, default_configs[:current_user])

    Application.put_env(
      :live_guard,
      :unauthorized_handler,
      default_configs[:unauthorized_handler]
    )
  end
end

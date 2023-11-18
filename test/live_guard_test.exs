defmodule LiveGuardTest do
  use ExUnit.Case
  doctest LiveGuard

  test "greets the world" do
    assert LiveGuard.hello() == :world
  end
end

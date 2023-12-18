defmodule LiveGuard.GuardedStagesTest do
  use ExUnit.Case, async: true

  alias LiveGuard.GuardedStages

  doctest LiveGuard.GuardedStages

  describe "guarded_stages/1" do
    test "correct return" do
      assert [:handle_event, :handle_info] == GuardedStages.guarded_stages(LiveGuardTestLive)

      assert LiveGuard.attachable_lifecycle_stages() ==
               GuardedStages.guarded_stages(DummyTestModule)
    end
  end
end

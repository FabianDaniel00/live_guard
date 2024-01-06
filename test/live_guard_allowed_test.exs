defmodule LiveGuard.AllowedTest do
  use ExUnit.Case, async: true

  import Phoenix.ConnTest
  import Phoenix.LiveViewTest

  alias LiveGuard.Helpers

  @endpoint LiveGuardTestEndpoint

  doctest LiveGuard.Allowed

  describe "allowed?/4" do
    setup do
      conn = build_conn()

      %{conn: conn, live: live_isolated(conn, LiveGuardTestLive)}
    end

    test ":mount", %{conn: conn} do
      assert {:error,
              {:redirect, %{to: "/", flash: %{"error" => Helpers.not_authorized_message()}}}} ==
               live_isolated(conn, LiveGuardTestLive, session: %{"not_allowed" => true})

      assert {:ok, _view, html} =
               live_isolated(conn, LiveGuardTestLive, session: %{"not_allowed" => false})

      assert html =~ "Allowed!"
    end

    # Can't test :handle_params bacause we need to mount live_view from router...

    test ":handle_event", %{live: {:ok, view, _html}} do
      assert "#{get_not_authorized_message()}Not allowed!" == render_click(view, "test-event")

      render_click(view, "change-user-role", %{"role" => :admin})
      render_click(view, "clear-flash")
      assert "Allowed!" == render_click(view, "test-event")
    end

    test ":handle_info", %{live: {:ok, view, _html}} do
      send(view.pid, :test_msg)
      assert render(view) =~ "Not allowed!"

      render_click(view, "change-user-role", %{"role" => :admin})
      send(view.pid, :test_msg)
      assert render(view) =~ "Allowed!"
    end

    test ":handle_async", %{live: {:ok, view, _html}} do
      assert "Not allowed!" == render_click(view, "test-async")

      render_click(view, "change-user-role", %{"role" => :admin})
      assert "Allowed!" == render_click(view, "test-async")
    end
  end

  defp get_not_authorized_message(),
    do: String.replace(Helpers.not_authorized_message(), "'", "&#39;")
end

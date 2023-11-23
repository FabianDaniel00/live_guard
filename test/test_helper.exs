ExUnit.start()

defmodule LiveGuardTestUser do
  defstruct role: :customer
end

defmodule LiveGuardTestLive do
  use Phoenix.LiveView

  alias Phoenix.Flash

  on_mount SetCurrentUserTest
  on_mount LiveGuard

  def mount(_params, %{"role" => role}, socket),
    do:
      {:ok,
       socket
       |> assign(:current_user, %LiveGuardTestUser{role: role})
       |> assign(:not_allowed, true)}

  def mount(_params, %{"not_allowed" => not_allowed}, socket),
    do: {:ok, assign(socket, :not_allowed, not_allowed)}

  def mount(_params, _session, socket), do: {:ok, assign(socket, :not_allowed, true)}

  def render(assigns),
    do: ~H"""
    <%= Flash.get(@flash, :error) %><%= (@not_allowed && "Not allowed!") || "Allowed!" %>
    """

  def handle_event("change-user-role", %{"role" => role}, socket),
    do: {:noreply, assign(socket, :current_user, %LiveGuardTestUser{role: role})}

  def handle_event("clear-flash", _unsigned_params, socket),
    do: {:noreply, clear_flash(socket)}

  def handle_event("test-event", _unsigned_params, socket),
    do: {:noreply, assign(socket, :not_allowed, false)}

  def handle_info(:test_msg, socket),
    do: {:noreply, assign(socket, :not_allowed, false)}
end

defmodule SetCurrentUserTest do
  import Phoenix.Component, only: [assign: 3]

  def on_mount(:default, _params, _session, socket),
    do: {:cont, assign(socket, :current_user, %LiveGuardTestUser{})}
end

defimpl LiveGuard.Allowed, for: LiveGuardTestUser do
  @before_compile {LiveGuard, :before_compile_allowed}

  def allowed?(
        %LiveGuardTestUser{role: role},
        LiveGuardTestLive,
        :mount,
        {_params, %{"not_allowed" => true}, _socket}
      )
      when role in [:customer],
      do: false

  def allowed?(
        %LiveGuardTestUser{role: role},
        LiveGuardTestLive,
        :handle_event,
        {"test-event", _unsigned_params, _socket}
      )
      when role in [:customer],
      do: false

  def allowed?(
        %LiveGuardTestUser{role: role},
        LiveGuardTestLive,
        :handle_info,
        {:test_msg, _socket}
      )
      when role in [:customer],
      do: false
end

defimpl LiveGuard.GuardedStages, for: Atom do
  @before_compile {LiveGuard, :before_compile_guarded_stages}

  def guarded_stages(LiveGuardTestLive), do: [:handle_event, :handle_info]
end

defmodule DummyTestModule do
end

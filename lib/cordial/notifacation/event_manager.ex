defmodule Cordial.Notification.EventManager do
  use GenEvent
  require Logger

  def handle_event(msg, state) do
    msg
    |> inspect
    |> Logger.debug

    {:ok, state}
  end

  def handle_call(msg, state) do
    msg
    |> inspect
    |> Logger.debug

    {:ok, [], state}
  end
end

defmodule Cordial.Notification.AnotherEventManager do
  use GenEvent
  require Logger

  def handle_event({:test, msg}, state) do
    msg
    |> inspect
    |> Logger.debug

    {:ok, state}
  end

  def handle_call({:test, msg}, state) do
    msg
    |> inspect
    |> Logger.debug

    {:ok, msg, state}
  end
end

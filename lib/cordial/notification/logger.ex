defmodule Cordial.Notification.Logger do
  @moduledoc """
  This logger attaches to the Notification system and logs all additional
  calls to the new topics.
  """
  alias Cordial.Notification
  require Logger
  use GenEvent

  @doc "Will register the logger to dynamically listen to all new topics"
  def subscribe_to_all do
    Notification.add_handler(__MODULE__, :notification_add_topic)
    Notification.add_handler(__MODULE__, :notification_add_handler)
    Notification.add_handler(__MODULE__, :notification_remove_handler)
    Notification.add_handler(__MODULE__, :notification_unheard_notify)
    Notification.add_handler(__MODULE__, :notification_call_halted)
    Notification.add_handler(__MODULE__, :notification_call_errored)
  end

  @doc false
  def handle_event({:notification_add_topic, {:notification_add_topic, _}} = input, state) do
    Logger.debug "[notification] handle_event <<#{inspect input}>>"
    {:ok, state}
  end

  @doc false
  def handle_event({:notification_add_topic, {topic, _}} = input, state) do
    Logger.debug "[notification] handle_event <<#{inspect input}>>"
    Notification.add_handler(__MODULE__, topic)
    {:ok, state}
  end

  @doc false
  def handle_event(input, state) do
    Logger.debug "[notification] handle_event <<#{inspect input}>>"
    {:ok, state}
  end

  @doc false
  def handle_call(input, state) do
    Logger.debug "[notification] handle_call <<#{inspect input}>>"
    Notification.map_response :ignore, state
  end

end

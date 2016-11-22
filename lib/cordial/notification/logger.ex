defmodule Cordial.Notification.Logger do
  alias Cordial.Notification
  require Logger
  use GenEvent

  def subscribe_to_all do
    Notification.add_handler(__MODULE__, :notification_add_topic)
  end

  def handle_event(input, _) do
    Logger.info "[notification] handle_event <<#{inspect input}>>"
    Notification.map_response :ok
  end

  def handle_call({:notification_add_topic, {topic, pid}}, _) do
    Logger.info "[notification] Now managing #{topic} on #{inspect(pid)}"
    Notifiction.map_response Notification.add_handler(__MODULE__, topic)
  end

  def handle_call(input, _) do
    Logger.info "[notification] handle_call <<#{inspect input}>>"
    Notifiction.map_response {:ok, input}
  end

end

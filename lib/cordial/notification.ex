defmodule Cordial.Notification do
  @moduledoc """
  Provides a simple implementation of a topic event manager.

  This behavior provides the feature to manages request/response events and
  handlers for a given topic. It also implements simple map and fold operations
  to allow basic managing of the results of several event handlers.

  ## Example Usage

  Start by defining a `GenEvent` module which will handle your events. See the
  documentation for `GenEvent` for details.

      defmodule MyApp.EventHandler do
        use GenEvent

        def handle_event({:example, msg}, _) do
          IO.inspect msg
          {:ok, []}
        end
      end

  Once the module is created, you can start you `Coridal` application and
  register you new handler.

      iex(1)> Cordial.Notification.add_handler(:example, MyApp.EventHandler)

  You can you send `:example` events to your `MyApp.EventHandler`.

      iex(2)> Cordial.Notification.notify(:example, %{})

  Which will send all the the message `%{}` to all you handlers of `:example`.

  You can also run request/responses event management by writing modules
  utilizing the `GenEvent.call` function.

      defmodule MyApp.EventSink do
        use GenEvent

        def handle_call({:collect, msg}, messages) do
          new_state = [msg | messages]
          {:ok, new_state, new_state}
        end

       iex(3)> Cordial.Notification.add_handler(:collect, MyApp.EventSink)
       iex(4)> Cordial.Notification.map(:collect, :thing1)
       [:thing1]
       iex(5)> Cordial.Notification.map(:collect, :thing2)
       [:thing1, :thing2]
  """
  use GenServer
  require Logger

  @doc false
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @doc false
  def init(_) do
    {:ok, %{managers: %{}}}
  end

  @doc "Adds a handler to a topic"
  def add_handler(topic, handler, args \\ []) do
    GenServer.call(__MODULE__, {:add_handler, topic, handler, args})
  end

  @doc "Removes a handler to a topic"
  def remove_handler(topic, handler, args \\ []) do
    GenServer.call(__MODULE__, {:remove_handler, topic, handler, args})
  end

  @doc "Notifies all handlers of the topic"
  def notify(topic, body) do
    GenServer.cast(__MODULE__, {:notify, topic, body})
  end

  @doc "Calls the first handlers of the topic"
  def first(topic, body) do
    GenServer.call(__MODULE__, {:first, topic, body})
  end

  @doc "Calls the all handlers of the topic"
  def map(topic, body) do
    GenServer.call(__MODULE__, {:map, topic, body})
  end

  @doc "Calls the all handlers of the topic, allowing for folding the results"
  def foldl(topic, body, {acc, fun}) do
    __MODULE__
    |> GenServer.call({:map, topic, body})
    |> List.foldl(acc, fun)
  end

  @doc "Calls the all handlers of the topic, allowing for folding the results"
  def foldr(topic, body, {acc, fun}) do
    __MODULE__
    |> GenServer.call({:map, topic, body})
    |> List.foldr(acc, fun)
  end

  @doc false
  def handle_call({:add_handler, topic, handler, args}, _from,
        %{managers: managers} = state) do
    manager = if Map.has_key?(managers, topic) do
      Map.get(managers, topic)
    else
      {:ok, pid} = GenEvent.start_link([])
      Logger.info "Now managing #{topic} on #{inspect(pid)}"
      managers = Map.put(managers, topic, pid)
      pid
    end
    :ok = GenEvent.add_mon_handler(manager, handler, args)
    Logger.info "Now handling #{topic} with #{inspect(handler)}"
    {:reply, :ok, %{state | managers: managers}}
  end

  @doc false
  def handle_call({:remove_handler, topic, handler, args}, _from,
        %{managers: managers} = state) do
    managers
    |> Map.get(topic)
    |> GenEvent.remove_handler(handler, args)
    Logger.info "Now **NOT** handling #{topic} with #{inspect(handler)}"
    {:reply, :ok, state}
  end

  @doc false
  def handle_call({:map, topic, message}, _from, %{managers: managers} = state) do
    manager = Map.get(managers, topic)

    resp = manager
    |> GenEvent.which_handlers
    |> Enum.map(fn(handler) ->
      GenEvent.call(manager, handler, {topic, message})
    end)

    {:reply, resp, state}
  end

  @doc false
  def handle_call({:first, topic, message}, _from,
        %{managers: managers} = state) do
    manager = Map.get(managers, topic)

    handler = manager
    |> GenEvent.which_handlers
    |> List.first

    resp = GenEvent.call(manager, handler, {topic, message})

    {:reply, resp, state}
  end

  @doc false
  def handle_cast({:notify, topic, message}, %{managers: managers} = state) do
    managers
    |> Map.get(topic)
    |> GenEvent.ack_notify({topic, message})

    {:noreply, state}
  end
end

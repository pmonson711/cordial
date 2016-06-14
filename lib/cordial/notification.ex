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

  @doc "Calls the first handlers of the topic"
  def last(topic, body) do
    GenServer.call(__MODULE__, {:last, topic, body})
  end

  @doc "Calls the all handlers of the topic"
  def map(topic, body) do
    GenServer.call(__MODULE__, {:map, topic, body})
  end

  @doc "Calls the all handlers of the topic, allowing for folding the results"
  def foldl(topic, body, {_acc, _fun} = fun_state) do
    __MODULE__
    |> GenServer.call({:foldl, topic, body, fun_state})
  end

  @doc "Calls the all handlers of the topic, allowing for folding the results"
  def foldr(topic, body, {_acc, _fun} = fun_state) do
    __MODULE__
    |> GenServer.call({:foldr, topic, body, fun_state})
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
    {:reply, {:ok, manager}, %{state | managers: managers}}
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

    fun = transform_genevent_call(:map, manager, topic, message)

    resp = manager
    |> GenEvent.which_handlers
    |> Enum.reduce_while([], fun)

    {:reply, resp, state}
  end

  def handle_call({:foldl, topic, message, {acc, fun}}, _from,
        %{managers: managers} = state) do
    manager = Map.get(managers, topic)

    rfun = transform_genevent_call(:foldl, manager, topic, message)

    resp = manager
    |> GenEvent.which_handlers
    |> Enum.reduce_while([], rfun)
    |> List.foldl(acc, fun)

    {:reply, resp, state}
  end

  def handle_call({:foldr, topic, message, {acc, fun}}, _from,
        %{managers: managers} = state) do
    manager = Map.get(managers, topic)

    rfun = transform_genevent_call(:foldr, manager, topic, message)

    resp = manager
    |> GenEvent.which_handlers
    |> Enum.reverse
    |> Enum.reduce_while([], rfun)
    |> List.foldl(acc, fun)

    {:reply, resp, state}
  end

  @doc false
  def handle_call({:first, topic, message}, _from,
        %{managers: managers} = state) do
    manager = Map.get(managers, topic)

    fun = transform_genevent_call_first(:first, manager, topic, message)

    resp = manager
    |> GenEvent.which_handlers
    |> Enum.reduce_while([], fun)

    {:reply, resp, state}
  end

  @doc false
  def handle_call({:last, topic, message}, _from,
        %{managers: managers} = state) do
    manager = Map.get(managers, topic)

    fun = transform_genevent_call_first(:last, manager, topic, message)

    resp = manager
    |> GenEvent.which_handlers
    |> Enum.reverse
    |> Enum.reduce_while([], fun)

    {:reply, resp, state}
  end

  @doc false
  def handle_cast({:notify, topic, message}, %{managers: managers} = state) do
    managers
    |> Map.get(topic)
    |> GenEvent.ack_notify({topic, message})

    {:noreply, state}
  end

  defp transform_genevent_call_first(call, manager, topic, message) do
    fn(handler, _acc) ->
      case GenEvent.call(manager, handler, {topic, message}) do
        {:halt, _value} ->
          log_info(call, message, topic, manager, handler)
          {:cont, []}
        {:error, _value} ->
          log_error(call, message, topic, manager, handler)
          {:cont, []}
        {:ok, value}     -> {:halt, value}
        value            -> {:halt, value}
      end
    end
  end

  defp transform_genevent_call(call, manager, topic, message) do
    fn(handler, trans_acc) ->
      case GenEvent.call(manager, handler, {topic, message}) do
        {:halt, _value} ->
          log_info(call, message, topic, manager, handler)
          {:halt, trans_acc}
        {:error, _value} ->
          log_error(call, message, topic, manager, handler)
          {:cont, trans_acc}
        {:ok, value}     -> {:cont, [value|trans_acc]}
        value            -> {:cont, [value|trans_acc]}
      end
    end
  end

  defp log_error(call_type, message, topic, manager, handler) do
    str1 = "[#{call_type}] :error"
    str2 = "value #{inspect message}"
    str3 = "handed to #{inspect handler}"
    str4 = "for #{topic} on #{manager}"
    Logger.error "#{str1} #{str2} #{str3} #{str4}"
  end

  defp log_info(call_type, message, topic, manager, handler) do
    str1 = "[#{call_type}] :halt"
    str2 = "value #{inspect message}"
    str3 = "handed to #{inspect handler}"
    str4 = "for #{topic} on #{manager}"
    Logger.info "#{str1} #{str2} #{str3} #{str4}"
  end
end

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

        def handle_call({:example, msg}, _) do
          IO.inspect msg
          Cordial.Notification.map_response :ok
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
  @spec add_handler(module, atom, term) :: :ok
  def add_handler(handler, topic, args \\ []) do
    GenServer.call(__MODULE__, {:add_handler, topic, handler, args})
  end

  @doc "Removes a handler to a topic"
  @spec remove_handler(module, atom, term) :: :ok
  def remove_handler(handler, topic, args \\ []) do
    GenServer.call(__MODULE__, {:remove_handler, topic, handler, args})
  end

  @doc "Notifies all handlers of the topic"
  @spec notify(term, atom) :: :ok
  def notify(body, topic) do
    GenServer.cast(__MODULE__, {:notify, topic, body})
    body
  end

  @doc "Calls the first handlers of the topic"
  @spec first(term, atom) :: term
  def first(body, topic) do
    GenServer.call(__MODULE__, {:first, topic, body})
  end

  @doc "Calls the last handlers of the topic"
  @spec last(term, atom) :: term
  def last(body, topic) do
    GenServer.call(__MODULE__, {:last, topic, body})
  end

  @doc "Calls the all handlers of the topic"
  @spec map(term, atom) :: [term]
  def map(body, topic) do
    GenServer.call(__MODULE__, {:map, topic, body})
  end

  @spec foldl(
    term, atom,
    {a, (b, a -> {:cont, a} | {:halt, a})}
  ) ::
  term
  when a: term, b: term
  @doc "Calls the all handlers of the topic, allowing for folding the results"
  def foldl(body, topic, {_acc, _fun} = fun_state) do
    __MODULE__
    |> GenServer.call({:foldl, topic, body, fun_state})
  end

  def foldl(body, topic, acc) do
    __MODULE__
    |> GenServer.call({:foldl, topic, body, {acc, fn x, _acc -> x end}})
  end

  def foldl(body, topic) do
    __MODULE__
    |> GenServer.call({:foldl, topic, body, {body, fn x, _acc -> x end}})
  end

  @spec foldr(
    term, atom,
    {a, (b, a -> {:cont, a} | {:halt, a})}
  ) :: term
  when a: term, b: term
  @doc "Calls the all handlers of the topic, allowing for folding the results"
  def foldr(body, topic, {_acc, _fun} = fun_state) do
    __MODULE__
    |> GenServer.call({:foldr, topic, body, fun_state})
  end

  def foldr(body, topic, acc) do
    __MODULE__
    |> GenServer.call({:foldr, topic, body, {acc, fn x, _acc -> x end}})
  end

  def foldr(body, topic) do
    __MODULE__
    |> GenServer.call({:foldr, topic, body, {body, fn x, _acc -> x end}})
  end

  @doc "Maps a notification response to a GenEvent response."
  @spec map_response(
    :ok |
    :ignore |
    {:ok, term} |
    {:halt, term} |
    {:error, term},
    term)
  ::
  {:ok, {:ok, nil}, term} |
  {:ok, {:ignore, [], term}} |
  {:ok, {:halt, term, term}} |
  {:error, {:error, term}, term}

  def map_response(response, state \\ []) do
    case response do
      :ok -> {:ok, {:ok, nil}, state}
      :ignore -> {:ok, {:ignore, []}, state}
      {:ok, val} -> {:ok, {:ok, val}, state}
      {:halt, val} -> {:ok, {:halt, val}, state}
      {:error, val} -> {:error, {:error, val}, state}
      val -> {:ok, {:ok, val}, state}
    end
  end

  @doc false
  def handle_call({:add_handler, topic, handler, args}, _from,
        %{managers: managers} = state) do
    {new_managers, manager} = if Map.has_key?(managers, topic) do
      {managers, Map.get(managers, topic)}
    else
      {:ok, pid} = GenEvent.start_link([])
      new_managers = Map.put(managers, topic, pid)
      __MODULE__.notify({topic, pid}, :notification_add_topic)
      {new_managers, pid}
    end
    :ok = do_add_mon_handler(manager, handler, args)
    Logger.info "Now handling #{topic} with #{inspect(handler)}"
    {:reply, {:ok, manager}, %{state | managers: new_managers}}
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

  @doc false
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

  @doc false
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
    case Map.get(managers, topic) do
      :nil -> {:reply, :nil, state}
      manager ->
        fun = transform_genevent_call_first(:first, manager, topic, message)

        resp = manager
        |> GenEvent.which_handlers
        |> Enum.reduce_while([], fun)

        {:reply, resp, state}
    end
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
    case Map.get(managers, topic) do
      pid when is_pid(pid) ->
        GenEvent.notify(pid, {topic, message})
      nil ->
        Logger.info "[dev] no one listening to #{topic} but notify was called"
    end

    {:noreply, state}
  end

  defp do_add_mon_handler(manager, handler, args) do
    case GenEvent.add_mon_handler(manager, handler, args) do
      :ok -> :ok
      {:error, :already_present} ->
        :ok
      result -> result
    end
  end

  defp transform_genevent_call_first(call, manager, topic, message) do
    fn(handler, _acc) ->
      case GenEvent.call(manager, handler, {topic, message}) do
        {:ignore, _value} ->
          {:cont, []}
        {:halt, _value} ->
          log_info(call, message, topic, manager, handler)
          __MODULE__.notify({call, message, topic, manager, handler}, :notification_call_halted)
          {:cont, []}
        {:error, _value} ->
          log_error(call, message, topic, manager, handler)
          __MODULE__.notify({call, message, topic, manager, handler}, :notification_call_errored)
          {:cont, []}
        {:ok, value}     -> {:halt, value}
        value            -> {:halt, value}
      end
    end
  end

  defp transform_genevent_call(call, manager, topic, message) do
    fn(handler, trans_acc) ->
      case GenEvent.call(manager, handler, {topic, message}) do
        {:ignore, _value} ->
          {:cont, trans_acc}
        {:halt, _value} ->
          log_info(call, message, topic, manager, handler)
          __MODULE__.notify({call, message, topic, manager, handler}, :notification_call_halted)
          {:halt, trans_acc}
        {:error, _value} ->
          log_error(call, message, topic, manager, handler)
          __MODULE__.notify({call, message, topic, manager, handler}, :notification_call_errored)
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
    str4 = "for #{inspect topic} on #{inspect manager}"
    Logger.error "#{str1} #{str2} #{str3} #{str4}"
  end

  defp log_info(call_type, message, topic, manager, handler) do
    str1 = "[#{call_type}] :info"
    str2 = "value #{inspect message}"
    str3 = "handed to #{inspect handler}"
    str4 = "for #{inspect topic} on #{inspect manager}"
    Logger.info "#{str1} #{str2} #{str3} #{str4}"
  end
end

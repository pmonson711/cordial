defmodule Cordial.NotificationTest do
  use ExUnit.Case, async: true
  import ExUnit.CaptureLog
  alias Cordial.Notification

  @val %{i: :log}
  @expected_response {:expected_response, input: {:test, @val}}

  defmodule TestReceiverOne do
    use GenEvent
    require Logger

    def handle_event(input, _) do
      Logger.info "[event] #{inspect input}"
      {:ok, []}
    end

    def handle_call(input, _) do
      Logger.info "[call] #{inspect input}"
      {:ok, {:expected_response, input: input}, []}
    end
  end

  defmodule TestReceiverTwo do
    use GenEvent
    require Logger

    def handle_event(input, _) do
      Logger.info "[event] #{inspect input}"
      {:ok, []}
    end

    def handle_call(input, _) do
      Logger.info "[call] #{inspect input}"
      {:ok, {:expected_response, input: input}, []}
    end
  end

  setup_all do
    Notification.add_handler(:test, TestReceiverOne)
  end

  test "Can add and remove handler" do
    assert :ok = Notification.add_handler(:test_setup, TestReceiverOne)
    assert :ok = Notification.remove_handler(:test_setup, TestReceiverOne)
  end

  test "Can notify" do
    assert :ok = Notification.notify(:test, @val)
  end

  test "Can map" do
    assert [@expected_response] = Notification.map(:test, @val)
  end

  test "Can fold" do
    fun = fn({:expected_response, input: {:test, x}}, a) ->
      [x|a]
    end
    assert [@val] = Notification.foldl(:test, @val, {[], fun})
    assert [@val] = Notification.foldr(:test, @val, {[], fun})
  end

  test "Can only call one" do
    assert @expected_response = Notification.first(:test, @val)
    assert :ok = Notification.add_handler(:test, TestReceiverTwo)
    assert @expected_response = Notification.first(:test, @val)
    assert :ok = Notification.remove_handler(:test, TestReceiverTwo)
  end
end

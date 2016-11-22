defmodule Cordial.NotificationTest do
  use ExUnit.Case, async: true
  alias Cordial.Notification

  @val %{i: :log}
  @expected_response {:expected_response, input: {:test, @val}}

  defmodule TestReceiverOne do
    use GenEvent

    def handle_event(_, _) do
      {:ok, []}
    end

    def handle_call(input, _) do
      {:ok, {:expected_response, input: input}, []}
    end
  end

  defmodule TestReceiverTwo do
    use GenEvent

    def handle_call(input, _) do
      {:ok, {:expected_response, input: input}, []}
    end
  end

  defmodule Repeater do
    use GenEvent

    def handle_call({_topic, {_status, _val} = input}, _) do
      Cordial.Notification.map_response(input)
    end
  end

  setup_all do
    Notification.add_handler(TestReceiverOne, :test)
    :ok
  end

  test "Can add and remove handler" do
    assert {:ok, _pid} = Notification.add_handler(TestReceiverOne, :test_setup)
    assert :ok = Notification.remove_handler(TestReceiverOne, :test_setup)
  end

  test "Can notify" do
    assert :ok = Notification.notify(@val, :test)
  end

  test "Can map" do
    assert [@expected_response] = Notification.map(@val, :test)
  end

  test "Can fold" do
    fun = fn(@expected_response = x, a) -> [x|a] end
    assert [@expected_response] = Notification.foldl(@val, :test, {[], fun})
    assert [@expected_response] = Notification.foldr(@val, :test, {[], fun})
  end

  test "Can only call one" do
    assert @expected_response = Notification.first(@val, :test)
    assert {:ok, _pid} = Notification.add_handler(TestReceiverTwo, :test)
    assert @expected_response = Notification.first(@val, :test)
    assert @expected_response = Notification.last(@val, :test)
    assert :ok = Notification.remove_handler(TestReceiverTwo, :test)
  end

  test "first should halt after one call" do
    assert {:ok, _pid} = Notification.add_handler(Repeater, :test_setup)
  end
end

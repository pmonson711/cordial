defmodule Cordial.Utils do
  def unwrap_ok_tuple({:ok, value}), do: value
end

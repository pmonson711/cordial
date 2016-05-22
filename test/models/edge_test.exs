defmodule Cordial.EdgeTest do
  use Cordial.ModelCase

  alias Cordial.Edge

  @valid_attrs %{}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Edge.changeset(%Edge{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Edge.changeset(%Edge{}, @invalid_attrs)
    refute changeset.valid?
  end
end

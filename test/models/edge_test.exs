defmodule Cordial.EdgeTest do
  use Cordial.ModelCase

  alias Cordial.Edge

  @valid_attrs %{}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Edge.changeset(%Edge{predicate_id: 0, subject_id: 0, object_id: 0, inserted_by_id: 0, modified_by_id: 0}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Edge.changeset(%Edge{}, @invalid_attrs)
    refute changeset.valid?
  end
end

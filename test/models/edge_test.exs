defmodule Cordial.EdgeTest do
  use Cordial.ModelCase

  alias Cordial.Edge

  @valid_attrs %{predicate_id: 1, subject_id: 1, object_id: 1, inserted_by_id: 1, modified_by_id: 1}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Edge.changeset(%Edge{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Edge.changeset(%Edge{}, @invalid_attrs)
    refute changeset.valid?
  end

  @tag :integration
  test "change can insert" do
    changeset = Edge.changeset(%Edge{}, @valid_attrs)

    assert {:ok, e} = Cordial.Repo.insert changeset
    assert e.id >= 1
  end
end

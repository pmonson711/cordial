defmodule Cordial.ResourceTest do
  use Cordial.ModelCase

  alias Cordial.Resource

  @valid_attrs %{name: "", inserted_by_id: 0, modified_by_id: 0, category_id: 0}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Resource.changeset(%Resource{name: "", inserted_by_id: 0, modified_by_id: 0, category_id: 0}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with valid attributes and publication start" do
    changeset = Resource.changeset(%Resource{}, Map.put(@valid_attrs, :publication_start, {{1999, 01, 01}, {01, 01, 01}}))
    assert changeset.valid?
    assert %{changes: %{publication_start: %Ecto.DateTime{}}} = changeset
  end

  test "changeset with valid attributes and publication end" do
    changeset = Resource.changeset(%Resource{}, Map.put(@valid_attrs, :publication_end, {{1999, 01, 01}, {01, 01, 01}}))
    assert changeset.valid?
    assert %{changes: %{publication_end: %Ecto.DateTime{}}} = changeset
  end

  test "changeset with invalid attributes" do
    changeset = Resource.changeset(%Resource{}, @invalid_attrs)
    refute changeset.valid?
  end
end

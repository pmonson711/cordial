defmodule Cordial.ResourceTest do
  use Cordial.ModelCase

  alias Cordial.Resource

  @valid_attrs %{name: "test_insert", inserted_by_id: 1, modified_by_id: 1, category_id: 1}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Resource.changeset(%Resource{}, @valid_attrs)
    assert changeset.valid?
    refute changeset
    |> Map.get(:changes)
    |> Map.has_key?(:publication_start)
    refute changeset
    |> Map.get(:changes)
    |> Map.has_key?(:publication_end)
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

  @tag :integration
  test "changeset with valid attributes inserts" do
    changeset = Resource.changeset(%Resource{}, @valid_attrs)
    assert changeset.valid?
    refute changeset
    |> Map.get(:changes)
    |> Map.has_key?(:publication_start)
    refute changeset
    |> Map.get(:changes)
    |> Map.has_key?(:publication_end)
    Cordial.Repo.insert! changeset
    resource = %Resource{publication_start: start_dt, publication_end: end_dt} = Cordial.Repo.get_by!(Resource, name: "test_insert")
    assert :eq = Ecto.DateTime.compare(end_dt, Ecto.DateTime.from_erl({{9999, 06, 01}, {0, 0, 0}}))
    assert :lt = Ecto.DateTime.compare(start_dt, Ecto.DateTime.from_erl({{9999, 06, 01}, {0, 0, 0}}))
  end
end

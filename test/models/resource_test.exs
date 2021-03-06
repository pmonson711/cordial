defmodule Cordial.RscTest do
  use Cordial.ModelCase

  alias Cordial.Rsc

  @valid_attrs %{name: "test_insert", inserted_by_id: 1, modified_by_id: 1, category_id: 1}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Rsc.changeset(%Rsc{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with valid attributes and publication start" do
    changeset = Rsc.changeset(%Rsc{}, Map.put(@valid_attrs, :publication_start, {{1999, 01, 01}, {01, 01, 01}}))
    assert changeset.valid?
    assert %{changes: %{publication_start: %Ecto.DateTime{}}} = changeset
  end

  test "changeset with valid attributes and publication end" do
    changeset = Rsc.changeset(%Rsc{}, Map.put(@valid_attrs, :publication_end, {{1999, 01, 01}, {01, 01, 01}}))
    assert changeset.valid?
    assert %{changes: %{publication_end: %Ecto.DateTime{}}} = changeset
  end

  test "changeset with invalid attributes" do
    changeset = Rsc.changeset(%Rsc{}, @invalid_attrs)
    refute changeset.valid?
  end

  @tag :integration
  test "changeset with valid attributes inserts" do
    test_insert
  end

  @tag :integration
  test "changeset with valid attributes inserts has publication start" do
    r = test_insert

    now = :erlang.timestamp
    |> :calendar.now_to_datetime
    |> Ecto.DateTime.from_erl

    now_date = now
    |> Ecto.DateTime.to_date

    # The `to_erl |> from_erl` conversion is used to drop
    # precision to match erlangs time spec
    assert :eq = r.publication_start
    |> Ecto.DateTime.to_erl
    |> Ecto.DateTime.from_erl
    |> Ecto.DateTime.compare(now)

    assert :eq = r.publication_start
    |> Ecto.DateTime.to_date
    |> Ecto.Date.compare(now_date)
  end

  @tag :integration
  test "changeset with valid attributes inserts has publication end" do
    r = test_insert

    end_of_time = {{9999, 06, 01}, {0, 0, 0}}
    |> Ecto.DateTime.from_erl

    assert :eq = r.publication_end
    |> Ecto.DateTime.compare(end_of_time)
  end

  @tag :integration
  test "changeset with valid attributes inserts has version" do
    r = test_insert

    assert r.version == 1
  end

  defp test_insert do
    changeset = Rsc.changeset(%Rsc{}, @valid_attrs)

    assert {:ok, %Rsc{id: id}} = Cordial.Repo.insert(changeset)

    Cordial.Repo.get!(Rsc, id)
  end
end

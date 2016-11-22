defmodule Cordial.IdentityTest do
  use Cordial.ModelCase

  alias Cordial.Identity
  alias Cordial.Rsc

  @valid_attrs %{name: "test", rsc_id: 1, identity_type_id: 1}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Identity.changeset(%Identity{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Identity.changeset(%Identity{}, @invalid_attrs)
    refute changeset.valid?
  end

  @tag :integration
  test "changeset can insert" do
    changeset = Identity.changeset(%Identity{}, @valid_attrs)
    assert {:ok, i} = Cordial.Repo.insert changeset
    assert i.id >= 1
  end

  @tag :integration
  test "can create with resource" do
    rsc = %{name: "identity_insert_test",
            inserted_by_id: 1,
            modified_by_id: 1,
            category_id: 5}
    identity = %{rsc: rsc,
                 identity_type_id: 1}
    multi = Cordial.Utils.Rsc.new %Identity{}, identity

    assert [
      {:identity_rsc, {:insert, rsc_changeset, []}},
      {:identity, {:run, identity_changesetfun}}
    ] = Ecto.Multi.to_list(multi)

    assert rsc_changeset.valid?
    assert {:ok, %Identity{rsc_id: 1}} = identity_changesetfun.(%{identity_rsc: %{id: 1}})
  end

  @tag :integration
  test "can create new with rsc and insert" do
    rsc = %{name: "identity_insert_test",
            inserted_by_id: 1,
            modified_by_id: 1,
            category_id: 2}
    identity = %{rsc: rsc,
                 identity_type_id: 1}
    assert {:ok, %{identity: %Identity{rsc_id: rsc_id},
                   identity_rsc: %Rsc{id: rsc_id}
                  }} = Cordial.Utils.Rsc.new(%Identity{}, identity)
    |> Cordial.Repo.transaction
  end
end

defmodule Cordial.IdentityTest do
  use Cordial.ModelCase

  alias Cordial.Identity

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
end

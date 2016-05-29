defmodule Cordial.IdentityTypeTest do
  use Cordial.ModelCase

  alias Cordial.IdentityType

  @valid_attrs %{name: "test"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = IdentityType.changeset(%IdentityType{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = IdentityType.changeset(%IdentityType{}, @invalid_attrs)
    refute changeset.valid?
  end

  @tag :integration
  test "changeset can insert" do
    changeset = IdentityType.changeset(%IdentityType{}, @valid_attrs)
    assert {:ok, it} = Cordial.Repo.insert changeset
    assert it.id >= 1
  end
end

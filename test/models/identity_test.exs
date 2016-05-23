defmodule Cordial.IdentityTest do
  use Cordial.ModelCase

  alias Cordial.Identity

  @valid_attrs %{name: "test"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Identity.changeset(%Identity{resource_id: 0, type_id: 0}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Identity.changeset(%Identity{}, @invalid_attrs)
    refute changeset.valid?
  end
end

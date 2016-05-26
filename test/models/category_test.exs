defmodule Cordial.CategoryTest do
  use Cordial.ModelCase

  alias Cordial.Category

  @valid_attrs %{resource_id: 1, parent_id: 1}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Category.changeset(%Category{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Category.changeset(%Category{}, @invalid_attrs)
    refute changeset.valid?
  end

  @tag :integration
  test "changeset can insert" do
    changeset = Category.changeset(%Category{}, @valid_attrs)

    assert {:ok, c} = Cordial.Repo.insert changeset
    assert c.id > 1
  end
end

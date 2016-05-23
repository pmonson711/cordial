defmodule Cordial.CategoryTest do
  use Cordial.ModelCase

  alias Cordial.Category

  @valid_attrs %{resource_id: 0, parent_id: 0}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Category.changeset(%Category{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Category.changeset(%Category{}, @invalid_attrs)
    refute changeset.valid?
  end
end

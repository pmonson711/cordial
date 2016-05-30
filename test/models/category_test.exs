defmodule Cordial.CategoryTest do
  use Cordial.ModelCase

  alias Cordial.Category

  @valid_attrs %{rsc_id: 1, parent_id: 1}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Category.changeset(%Category{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Category.changeset(%Category{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "can create new with rsc" do
    rsc = %{name: "category_insert_test",
            inserted_by_id: 1,
            modified_by_id: 1,
            category_id: 2}
    category = %{parent_id: 2,
                 rsc: rsc}
    multi = Category.new %Category{}, category

    assert [
      {:rsc, {:insert, rsc_changeset, []}},
      {:category, {:changeset_fun, :insert, category_changesetfun, []}}
    ] = Ecto.Multi.to_list(multi)

    assert rsc_changeset.valid?
    assert %Ecto.Changeset{changes: %{parent_id: 2, rsc_id: 1}} = category_changesetfun.(%{rsc: %{id: 1}})
  end

  @tag :integration
  test "changeset can insert" do
    changeset = Category.changeset(%Category{}, @valid_attrs)

    assert {:ok, c} = Cordial.Repo.insert changeset
    assert c.id > 1
  end

  @tag :integration
  test "can create new with rsc and insert" do
    rsc = %{name: "category_insert_test",
            inserted_by_id: 1,
            modified_by_id: 1,
            category_id: 2}
    category = %{parent_id: 2,
                 rsc: rsc}

    assert {:ok, %{category: i_cat, rsc: i_rsc}} = Cordial.Repo.transaction Category.new(%Category{}, category)

    assert i_cat.rsc_id == i_rsc.id
  end
end

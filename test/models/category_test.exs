defmodule Cordial.CategoryTest do
  use Cordial.ModelCase

  alias Cordial.Category
  alias Cordial.Rsc

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
    multi = Cordial.Utils.Rsc.new %Category{}, category

    assert [
      {:category_rsc, {:insert, rsc_changeset, []}},
      {:category, {:run, category_changesetfun}}
    ] = Ecto.Multi.to_list(multi)

    assert rsc_changeset.valid?
    assert {:ok, %Category{parent_id: 2, rsc_id: 1}} = category_changesetfun.(%{category_rsc: %{id: 1}})
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

    assert {:ok, %{category: %Category{rsc_id: rsc_id},
                   category_rsc: %Rsc{id: rsc_id}}} = Cordial.Utils.Rsc.new(%Category{}, category)
    |> Cordial.Repo.transaction
  end
end

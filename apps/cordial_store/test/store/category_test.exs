defmodule Cordial.Store.CategoryTest do
  use ExUnit.Case, async: true
  import Ecto.Query

  alias Ecto.Multi
  alias Ecto.Adapters.SQL.Sandbox
  alias Cordial.Repo
  alias Cordial.Store.Category
  alias Cordial.Store.Rsc
  alias Cordial.Store.Transactions

  setup do
    :ok = Sandbox.checkout(Repo)
  end

  def errors_on(model, data) do
    model.__struct__.changeset(model, data).errors
  end

  @valid_attrs %{rsc_id: 1, parent_id: 1}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Category.new(%Category{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Category.new(%Category{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "can create new with rsc" do
    rsc = %{name: "category_insert_test",
            inserted_by_id: 1,
            modified_by_id: 1,
            category_id: 2}
    category = %{parent_id: 2,
                 rsc: rsc}
    multi = Transactions.new_rsc %Category{}, category

    assert [
      {:category_rsc, {:insert, rsc_changeset, []}},
      {:category, {:run, category_changesetfun}}
    ] = Multi.to_list(multi)

    assert rsc_changeset.valid?
    assert {:ok, %Category{parent_id: 2, rsc_id: 1}} = category_changesetfun.(%{category_rsc: %{id: 1}})
  end

  @tag :integration
  test "changeset can insert" do
    changeset = Category.new(%Category{}, @valid_attrs)

    assert {:ok, c} = Repo.insert changeset
    assert c.id > 1
    assert %Category{rsc_id: 1, rsc: %Rsc{id: 1}} = Repo.one(
      from f in Category,
      where: f.id == ^c.id,
      preload: :rsc
    )
  end

  @tag :integration
  test "can create new with rsc and insert" do
    rsc = %{name: "category_insert_test",
            inserted_by_id: 1,
            modified_by_id: 1,
            category_id: 2}
    category = %{parent_id: 2,
                 rsc: rsc}

    inserted = %Category{}
    |> Transactions.new_rsc(category)
    |> Repo.transaction

    assert {:ok, %{category: %Category{rsc_id: rsc_id}, category_rsc: %Rsc{id: rsc_id}}} = inserted
  end

  @tag :integration
  test "can update a category rsc" do
    Category
    |> Repo.get(1)
    |> Repo.preload(:rsc)
    |> Transactions.update_rsc(%{rsc: %{name: "fancy new name", modified_by_id: 1}})
    |> Repo.transaction

    assert %Category{rsc: %Rsc{name: "fancy new name", version: 2}} = Repo.one(
      from c in Category,
      where: c.id == 1,
      preload: :rsc
    )
  end

  @tag :integration
  test "can reset the parent" do
    Category
    |> Repo.get(3)
    |> Category.update_parent(1)
    |> Repo.update!

    assert 1 = Repo.one(
      from c in Category,
      where: c.id == 1,
      select: c.parent_id
    )
  end
end

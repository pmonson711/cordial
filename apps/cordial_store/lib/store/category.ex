defmodule Cordial.Store.Category do
  use Ecto.Schema
  use Arbor.Tree

  import Ecto.Changeset

  alias Cordial.Store.Rsc

  schema "category" do
    belongs_to :rsc, Rsc
    belongs_to :parent, __MODULE__

    timestamps()
  end

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def new(model, params \\ %{}) do
    model
    |> cast(params, ~w(rsc_id parent_id)a)
    |> validate_required(:rsc_id)
    |> foreign_key_constraint(:parent_id)
    |> foreign_key_constraint(:rsc_id)
  end

  def update_parent(model, new_parent_id) do
    model
    |> cast(%{parent_id: new_parent_id}, [:parent_id])
    |> validate_required(:parent_id)
    |> foreign_key_constraint(:parent_id)
  end
end

defmodule Cordial.Store.Rsc do
  use Ecto.Schema

  import Ecto.Changeset

  alias Cordial.Store.Identity
  alias Cordial.Store.Category

  schema "rsc" do
    field :name
    field :is_authoritative, :boolean, default: false
    field :is_protected, :boolean, default: false
    field :publication_start, Ecto.DateTime
    field :publication_end, Ecto.DateTime
    field :version, :integer, default: 1
    belongs_to :visible_for, Identity
    belongs_to :inserted_by, Identity
    belongs_to :modified_by, Identity
    belongs_to :category, Category

    timestamps()
  end

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def new(model, params \\ %{}) do
    model
    |> cast(params, ~w(name inserted_by_id category_id is_authoritative
        is_protected publication_start publication_end)a)
    |> validate_required(~w(name inserted_by_id category_id)a)
    |> put_change(:modified_by_id, params.inserted_by_id)
    |> validate_constraints
  end

  def update(model, params \\ %{}) do
    model
    |> cast(params, ~w(name modified_by_id is_authoritative is_protected
        publication_start publication_end version)a)
    |> validate_required(~w(modified_by_id)a)
    |> optimistic_lock(:version)
    |> validate_constraints
  end

  defp validate_constraints(changeset) do
    changeset
    |> foreign_key_constraint(:inserted_by_id)
    |> foreign_key_constraint(:modified_by_id)
    |> foreign_key_constraint(:visible_for_id)
    |> foreign_key_constraint(:category_id)
  end
end

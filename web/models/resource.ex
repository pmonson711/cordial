defmodule Cordial.Rsc do
  use Cordial.Web, :model
  alias Cordial.Identity
  alias Cordial.Category

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

    timestamps
  end

  @required_fields ~w(name inserted_by_id modified_by_id category_id)
  @optional_fields ~w(is_authoritative is_protected publication_start
    publication_end version)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> foreign_key_constraint(:inserted_by_id)
    |> foreign_key_constraint(:modified_by_id)
    |> foreign_key_constraint(:visible_for_id)
    |> foreign_key_constraint(:category_id)
  end
end

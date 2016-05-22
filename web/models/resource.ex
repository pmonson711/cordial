defmodule Cordial.Resource do
  use Cordial.Web, :model
  alias Cordial.Identity
  alias Cordial.Category

  schema "resource" do
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

  @required_fields ~w()
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> clean_publication_start
    |> clean_publication_end
  end

  defp clean_publication_start(%Ecto.Changeset{changes: %{ publication_start: nil }, model: %{ publication_start: nil }} = changeset) do
    changeset
    |> delete_change(:publication_start)
  end

  defp clean_publication_end(%Ecto.Changeset{changes: %{ publication_end: nil }, model: %{ publication_end: nil }} = changeset) do
    changeset
    |> delete_change(:publication_end)
  end
end

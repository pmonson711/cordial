defmodule Cordial.Category do
  use Cordial.Web, :model
  alias Cordial.Rsc
  alias Cordial.Category

  schema "category" do
    belongs_to :rsc, Rsc
    belongs_to :parent, __MODULE__

    timestamps
  end

  @required_fields ~w(rsc_id parent_id)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> foreign_key_constraint(:parent_id)
    |> foreign_key_constraint(:rsc_id)
  end
end

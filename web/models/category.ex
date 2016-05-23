defmodule Cordial.Category do
  use Cordial.Web, :model
  alias Cordial.Resource

  schema "category" do
    belongs_to :resource, Resource
    belongs_to :parent, __MODULE__

    timestamps
  end

  @required_fields ~w(resource_id parent_id)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end

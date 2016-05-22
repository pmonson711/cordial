defmodule Cordial.Edge do
  use Cordial.Web, :model
  alias Cordial.Resource
  alias Cordial.Identity

  schema "edge" do
    belongs_to :subject, Resource
    belongs_to :predicate, Resource
    belongs_to :object, Resource
    belongs_to :inserted_by, Identity
    belongs_to :modified_by, Identity
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
  end
end

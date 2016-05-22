defmodule Cordial.Identity do
  use Cordial.Web, :model
  alias Cordial.Resource
  alias Cordial.IdentityType

  schema "identity" do
    belongs_to :resource, Resource
    belongs_to :type, IdentityType

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

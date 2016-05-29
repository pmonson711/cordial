defmodule Cordial.Identity do
  use Cordial.Web, :model
  alias Cordial.Resource
  alias Cordial.IdentityType

  schema "identity" do
    belongs_to :resource, Resource
    belongs_to :identity_type, IdentityType

    timestamps
  end

  @required_fields ~w(resource_id identity_type_id)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> foreign_key_constraint(:resource_id)
    |> foreign_key_constraint(:identity_type_id)
  end
end

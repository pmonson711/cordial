defmodule Cordial.Identity do
  use Cordial.Web, :model
  alias Cordial.Rsc
  alias Cordial.IdentityType

  schema "identity" do
    belongs_to :rsc, Rsc
    belongs_to :identity_type, IdentityType

    timestamps
  end

  @required_fields ~w(rsc_id identity_type_id)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> foreign_key_constraint(:rsc_id)
    |> foreign_key_constraint(:identity_type_id)
  end
end

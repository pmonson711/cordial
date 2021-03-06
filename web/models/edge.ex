defmodule Cordial.Edge do
  use Cordial.Web, :model
  alias Cordial.Rsc
  alias Cordial.Identity

  schema "edge" do
    belongs_to :subject, Rsc
    belongs_to :predicate, Rsc
    belongs_to :object, Rsc
    belongs_to :inserted_by, Identity
    belongs_to :modified_by, Identity
    timestamps
  end

  @required_fields ~w(subject_id predicate_id object_id inserted_by_id
    modified_by_id)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> foreign_key_constraint(:predicate_id)
    |> foreign_key_constraint(:subject_id)
    |> foreign_key_constraint(:object_id)
    |> foreign_key_constraint(:inserted_by_id)
    |> foreign_key_constraint(:modified_by_id)
  end
end

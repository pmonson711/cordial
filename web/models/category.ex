defmodule Cordial.Category do
  use Cordial.Web, :model
  alias Cordial.Resource
  alias Ecto.Multi

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
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> foreign_key_constraint(:parent_id)
    |> foreign_key_constraint(:resource_id)
  end

  def new(model, params \\ %{}) do
    Multi.new
    |> Multi.insert(:resource, Cordial.Resource.changeset(%Cordial.Resource{}, params.resource))
    |> Multi.insert(:category, fn resource_inserted ->
      case resource_inserted do
        %{resource: %{id: id}} ->
          Cordial.Category.changeset(model, Map.put(params, :resource_id, id))
      end
    end)
  end
end

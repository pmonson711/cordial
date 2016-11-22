defmodule Cordial.Utils.Rsc do
  alias Cordial.Repo
  alias Cordial.Rsc
  alias Cordial.Category
  alias Cordial.Identity
  alias Ecto.Multi

  def new(%Category{} = model, params) do
    Multi.new
    |> Multi.insert(:category_rsc, Rsc.changeset(%Rsc{}, params.rsc))
    |> Multi.run(:category, fn %{category_rsc: %{id: id}} ->
      model
      |> Category.changeset(Map.put(params, :rsc_id, id))
      |> Repo.insert
    end)
  end

  def new(%Identity{} = model, params) do
    Multi.new
    |> Multi.insert(:identity_rsc, Rsc.changeset(%Rsc{}, params.rsc))
    |> Multi.run(:identity, fn %{identity_rsc: %{id: id}} ->
      model
      |> Identity.changeset(Map.put(params, :rsc_id, id))
      |> Repo.insert
    end)
  end
end

defmodule Cordial.Store.Transactions do
  alias Cordial.Repo
  alias Cordial.Store.Rsc
  alias Cordial.Store.Category
  alias Cordial.Store.Identity
  alias Ecto.Multi

  def new_rsc(%Category{} = params), do: new_rsc(%Category{}, params)
  def new_rsc(%Identity{} = params), do: new_rsc(%Identity{}, params)

  def new_rsc(%Category{} = model, params) do
    Multi.new
    |> Multi.insert(:category_rsc, Rsc.new(%Rsc{}, params.rsc))
    |> Multi.run(:category, fn %{category_rsc: %{id: id}} ->
      model
      |> Category.new(Map.put(params, :rsc_id, id))
      |> Repo.insert
    end)
  end

  def new_rsc(%Identity{} = model, params) do
    Multi.new
    |> Multi.insert(:identity_rsc, Rsc.new(%Rsc{}, params.rsc))
    |> Multi.run(:identity, fn %{identity_rsc: %{id: id}} ->
      model
      |> Identity.new(Map.put(params, :rsc_id, id))
      |> Repo.insert
    end)
  end

  def update_rsc(%Category{rsc: rsc_model}, params) do
    Multi.new
    |> Multi.update(:category_rsc, Rsc.update(rsc_model, params.rsc))
  end

  def update_rsc(%Identity{rsc: rsc_model}, params) do
    Multi.new
    |> Multi.update(:identity_rsc, Rsc.update(rsc_model, params.rsc))
  end
end

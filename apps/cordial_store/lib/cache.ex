defmodule Cordial.Cache do
  use GenServer

  import Ecto.Query

  alias Cordial.Repo
  alias Cordial.Store.Category
  alias Cordial.Store.Rsc

  @default_ttl 43200

  def start_link(name) do
    GenServer.start_link __MODULE__, %{state: :started, cache: name, ttl: @default_ttl}
  end

  def init(state) do
    cache_protected(state)
    cache_categories(state)
    {:ok, %{state | state: :init}}
  end

  # convert to handle_call
  def get_rsc(id) do
    case :depcache.get(id, :depcache) do
      {:ok, rsc} -> rsc
      :undefined -> fetch_rsc_by_id(id)
    end
  end

  def cache_categories(state) do
    Category
    |> category_joins
    |> category_select
    |> Repo.all
    |> walk_categories(state)
  end

  def cache_protected(state) do
    Rsc
    |> where([r], r.is_protected == true)
    |> rsc_joins
    |> rsc_select
    |> Repo.all
    |> walk_rsc(state)
  end

  def fetch_rsc_by_id(id) do
    Rsc
    |> rsc_joins
    |> rsc_select
    |> Repo.get(id)
    |> walk_rsc(%{ttl: 3600, cache: :depcache})
  end

  def walk_categories(categories, state) do
    for cat <- categories do
      :depcache.set(cat.id, cat.rsc, state.ttl, [:category | ["cat_#{cat.id}" | cat.cache]], state.cache)
      :depcache.set("cat_#{cat.id}", cat, state.ttl, [:category | [cat.id | cat.cache]], state.cache)
    end
  end

  def walk_rsc(resources, state) do
    for rsc <- resources do
      :depcache.flush(rsc.id, state.cache)
      :depcache.set(rsc.id, rsc.rsc, state.ttl, rsc.cache, state.cache)
    end
  end

  # need to include edges
  defp category_joins(query) do
    query
    |> join(:left, [c], r in assoc(c, :rsc))
    |> join(:left, [_, r], v in assoc(r, :visible_for))
    |> join(:left, [_, _, v], vr in assoc(v, :rsc))
    |> join(:left, [c, _, _, _], c in assoc(c, :parent))
    |> join(:left, [_, _, _, _, p], pr in assoc(p, :rsc))
  end

  # need to include edges
  defp category_select(query) do
    query
    |> select([_, r, _, vr, _, pr], %{id: r.id,
                                     parent_id: pr.id,
                                     name: r.name,
                                     cache: [r.visible_for_id, pr.id],
                                     rsc: %{
                                       id: r.id,
                                       name: r.name,
                                       visible_for: vr.name
                                     }})
  end

  # need to include edges
  defp rsc_joins(query) do
    query
    |> join(:left, [r], v in assoc(r, :visible_for))
    |> join(:left, [_, v], vr in assoc(v, :rsc))
  end

  defp rsc_select(query) do
    query
    |> select([r, _, vr], %{id: r.id,
                           name: r.name,
                           cache: [r.visible_for_id],
                           rsc: %{
                             id: r.id,
                             name: r.name,
                             visible_for: vr.name
                           }})
  end
end

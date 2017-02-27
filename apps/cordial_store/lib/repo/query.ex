defmodule Cordial.Repo.Query do
  import Ecto.Query

  def full_rsc_preload do
    [category: basic_category_preload(),
     visible_for: [:identity_type, :rsc],
     inserted_by: [:identity_type, :rsc],
     modified_by: [:identity_type, :rsc]]
  end

  def full_rsc_field_preload do
    {:rsc, full_rsc_preload()}
  end

  def basic_category_preload do
    [{:rsc, basic_rsc_field_preload()}]
  end

  def basic_rsc_field_preload do
    [visible_for: [:identity_type, :rsc],
     inserted_by: [:identity_type, :rsc],
     modified_by: [:identity_type, :rsc]]
  end

  def preload_rsc(query) do
    query
    |> preload(^full_rsc_preload())
  end

  def preload_rsc_field(query) do
    query
    |> preload(^full_rsc_field_preload())
  end
end

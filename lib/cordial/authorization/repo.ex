defmodule Cordial.Authorization.Repo do
  alias Cordial.{Repo, Rsc}
  import Ecto.Query

  def is_enabled(user_id) do
    query = from r in Rsc,
      select: fragment("(now() at time zone 'UTC') BETWEEN ? AND ?",
        r.publication_start,
        r.publication_end),
      where: r.id == ^user_id
    case Repo.one(query) do
      :nil -> false
      enabled -> enabled
    end
  end
end

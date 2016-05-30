defmodule Cordial.Repo.Migrations.InsertDefaults do
  use Ecto.Migration
  require Cordial.Repo
  alias Cordial.Repo
  import Ecto.Query

  def up do
    Repo.insert %Cordial.IdentityType{ id: 1, name: "system" }

    Repo.insert %Cordial.Rsc{ id: 1, name: "admin" }
    Repo.insert %Cordial.Identity { id: 1, rsc_id: 1, identity_type_id: 1 }

    Repo.insert %Cordial.Rsc{ id: 2, name: "world" }
    Repo.insert %Cordial.Identity { id: 2, rsc_id: 2, identity_type_id: 1 }

    Repo.insert %Cordial.Rsc{ id: 3, name: "meta" }
    Repo.insert %Cordial.Category{ id: 1, rsc_id: 3, parent_id: 1 }

    Repo.insert %Cordial.Rsc{ id: 4, name: "category" }
    Repo.insert %Cordial.Category{ id: 2, rsc_id: 4, parent_id: 1 }
    
    Repo.insert %Cordial.Rsc{ id: 5, name: "thing" }
    Repo.insert %Cordial.Category{ id: 3, rsc_id: 5, parent_id: 3 }


    Repo.update_all( Cordial.Rsc, set: [visible_for_id: 2, inserted_by_id: 1, modified_by_id: 1, category_id: 2])

    alter table(:rsc) do
      modify :visible_for_id, :integer, null: true
      modify :inserted_by_id, :integer, null: true
      modify :modified_by_id, :integer, null: true
      modify :category_id, :integer, null: true
    end

    (from c in Cordial.Category,
      select: fragment("setval(?, ?)", "category_id_seq", max(c.id)))
      |> Repo.one!

    (from r in Cordial.Rsc,
      select: fragment("setval(?, ?)", "rsc_id_seq", max(r.id)))
      |> Repo.one!

    (from i in Cordial.Identity,
      select: fragment("setval(?, ?)", "identity_id_seq", max(i.id)))
      |> Repo.one!

    (from it in Cordial.IdentityType,
      select: fragment("setval(?, ?)", "identity_type_id_seq", max(it.id)))
      |> Repo.one!
  end

  def down do
  end
end

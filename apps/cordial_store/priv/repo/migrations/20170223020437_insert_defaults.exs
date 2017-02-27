defmodule Cordial.Repo.Migrations.InsertDefaults do
  use Ecto.Migration
  require Cordial.Repo
  alias Cordial.Repo
  import Ecto.Query

  def up do
    Repo.insert %Cordial.Store.IdentityType{id: 1, name: "system"}

    Repo.insert %Cordial.Store.Rsc{id: 1, name: "admin"}
    Repo.insert %Cordial.Store.Identity {id: 1, rsc_id: 1, identity_type_id: 1}

    Repo.insert %Cordial.Store.Rsc{id: 2, name: "world"}
    Repo.insert %Cordial.Store.Identity {id: 2, rsc_id: 2, identity_type_id: 1}

    Repo.insert %Cordial.Store.Rsc{id: 3, name: "meta"}
    Repo.insert %Cordial.Store.Category{id: 1, rsc_id: 3}

    Repo.insert %Cordial.Store.Rsc{id: 4, name: "category"}
    Repo.insert %Cordial.Store.Category{id: 2, rsc_id: 4, parent_id: 1}

    Repo.insert %Cordial.Store.Rsc{id: 5, name: "thing"}
    Repo.insert %Cordial.Store.Category{id: 3, rsc_id: 5}


    Repo.update_all(Cordial.Store.Rsc, set: [visible_for_id: 2, inserted_by_id: 1,
                                             modified_by_id: 1, category_id: 2,
                                             is_protected: true,
                                             is_authoritative: true])

    alter table(:rsc) do
      modify :visible_for_id, :integer, null: true
      modify :inserted_by_id, :integer, null: true
      modify :modified_by_id, :integer, null: true
      modify :category_id, :integer, null: true
    end

    Repo.one!(
      from c in Cordial.Store.Category,
      select: fragment("setval(?, ?)", "category_id_seq", max(c.id))
    )

    Repo.one!(
      from r in Cordial.Store.Rsc,
      select: fragment("setval(?, ?)", "rsc_id_seq", max(r.id))
    )

    Repo.one!(
      from i in Cordial.Store.Identity,
      select: fragment("setval(?, ?)", "identity_id_seq", max(i.id))
    )

    Repo.one!(
      from it in Cordial.Store.IdentityType,
      select: fragment("setval(?, ?)", "identity_type_id_seq", max(it.id))
    )
  end

  def down do
  end
end

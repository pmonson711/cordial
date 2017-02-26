defmodule Cordial.Repo.Migrations.CreateGone do
  use Ecto.Migration

  def up do
    create table(:rsc_snapshot) do
      add :name, :string, null: false
      add :old_id, :integer, null: false
      add :category, :string, null: false
      add :category_names, :string, null: false
      add :category_delimiter, :string, null: false
      add :document, :json, null: false
      timestamps()
    end

    create table(:rsc_gone) do
      add :rsc_snapshot_id, references(:rsc_snapshot), null: false
      add :new_id, :integer
    end
  end

  def down do
    drop table(:rsc_gone)
    drop table(:rsc_snapshot)
  end
end

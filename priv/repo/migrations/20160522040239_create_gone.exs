defmodule Cordial.Repo.Migrations.CreateGone do
  use Ecto.Migration

  def up do
    create table(:resource_snapshot) do
      add :name, :string, null: false
      add :old_id, :integer, null: false
      add :category, :string, null: false
      add :category_names, :string, null: false
      add :category_delimiter, :string, null: false
      add :document, :json, null: false
      timestamps
    end

    create table(:resource_gone) do
      add :resource_snapshot_id, references(:resource_snapshot), null: false
      add :new_id, :integer
    end
  end

  def down do
    drop table(:resource_gone)
    drop table(:resource_snapshot)
  end
end

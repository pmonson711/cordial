defmodule Cordial.Repo.Migrations.CreateBaseTables do
  use Ecto.Migration

  def up do
    create table(:resource) do
      add :name, :string, null: false
      add :is_authoritative, :boolean, default: false, null: false
      add :is_protected, :boolean, default: false, null: false
      add :publication_start, :datetime, default: fragment("(now() at time zone 'UTC')")
      add :publication_end, :datetime, default: fragment("'9999-06-01 00:00:00'::timestamp")
      add :version, :integer, default: 1, null: false
      timestamps
    end

    create table(:category) do
      add :resource_id, references(:resource), null: false
      add :parent_id, references(:category), null: false
      timestamps
    end

    create table(:identity_type) do
      add :name, :string, null: false
      timestamps
    end

    create table(:identity) do
      add :resource_id, references(:resource), null: false
      add :verification_key, :binary
      add :identity_type_id, references(:identity_type), null: false
      add :is_verified, :boolean, default: false, null: false
      add :is_unique, :boolean, default: false, null: false
      timestamps
    end

    alter table(:resource) do
      add :visible_for_id, references(:identity), null: true
      add :inserted_by_id, references(:identity), null: true
      add :modified_by_id, references(:identity), null: true
      add :category_id, references(:category), null: true
    end

    create index(:resource, [:category_id, :name], unique: true)
  end

  def down do
    alter table(:resource) do
      remove :visible_for_id
      remove :inserted_by_id
      remove :modified_by_id
      remove :category_id
    end

    alter table(:identity) do
      remove :resource_id
    end

    drop table(:category)
    drop table(:resource)
    drop table(:identity)
    drop table(:identity_type)
  end
end

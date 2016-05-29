defmodule Cordial.Repo.Migrations.CreateEdges do
  use Ecto.Migration

  def change do
    create table(:edge) do
      add :subject_id, references(:resource), null: false
      add :predicate_id, references(:resource), null: false
      add :object_id, references(:resource), null: false
      add :inserted_by_id, references(:identity), null: false
      add :modified_by_id, references(:identity), null: false
      timestamps
    end

    create index(:edge, [:object_id, :predicate_id, :subject_id], unique: true)
    create index(:edge, [:subject_id, :predicate_id, :object_id], unique: true)

    create table(:predicate_category) do
      add :resource_id, references(:resource), null: false
      add :source_category_id, references(:category), null: false
      add :destination_category_id, references(:category), null: false
      add :inserted_by_id, references(:identity), null: false
      add :modified_by_id, references(:identity), null: false
      timestamps
    end
  end
end

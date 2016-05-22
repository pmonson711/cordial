defmodule Cordial.Repo.Migrations.CreateUri do
  use Ecto.Migration

  def change do
    create table(:uri) do
      add :uri, :string, null: false
      add :resource_id, references(:resource), null: false
      timestamps
    end
    create index(:uri, [:uri], unique: true)
  end
end

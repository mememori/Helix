defmodule Helix.Log.Repo.Migrations.InitialModels do
  use Ecto.Migration

  def change do
    create table(:logs, primary_key: false) do
      add :log_id, :inet, primary_key: true

      add :server_id, :inet, null: false
      add :entity_id, :inet, null: false

      add :message, :string, null: false
      add :crypto_version, :integer

      timestamps()
    end

    create index(:logs, [:server_id, :entity_id])

    create table(:revisions, primary_key: false) do
      add :revision_id, :inet, primary_key: true

      add :log_id, references(:logs, column: :log_id, type: :inet, on_delete: :delete_all)

      add :entity_id, :inet, null: false

      add :message, :string, null: false
      add :forge_version, :integer
    end
  end
end
defmodule Platform.Repo.Migrations.CreatePlatform.Accounts.Player do
  use Ecto.Migration

  def change do
    create table(:accounts_players) do
      add :username, :string
      add :score, :integer

      timestamps()
    end

  end
end

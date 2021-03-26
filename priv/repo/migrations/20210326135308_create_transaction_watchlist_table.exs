defmodule DevChallengeRyan.Repo.Migrations.CreateTransactionWatchlistTable do
  use Ecto.Migration

  def up do
    create table(:transaction_watchlists, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :txid, :string
      add :status, :string, size: 1

      timestamps()
    end
  end

  def down do
    drop table(:transaction_watchlists)
  end
end

defmodule DevChallengeRyanWeb.Schemas.TransactionWatchlist do
  @moduledoc false

  use DevChallengeRyanWeb.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "transaction_watchlists" do
    field :txid, :string
    field :status, :string

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :txid,
      :status
    ])
  end
end

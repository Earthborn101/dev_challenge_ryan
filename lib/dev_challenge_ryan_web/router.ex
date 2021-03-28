defmodule DevChallengeRyanWeb.Router do
  use DevChallengeRyanWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", DevChallengeRyanWeb do
    pipe_through :api

    scope "/api" do
      scope "/v1", V1 do
        post "/add-transaction-id", BlockChainController, :add_transaction_id

        get "/check-for-pending-transactions",
            BlockChainController,
            :check_for_pending_transactions
      end
    end
  end
end

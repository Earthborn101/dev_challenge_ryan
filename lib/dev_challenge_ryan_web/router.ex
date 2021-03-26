defmodule DevChallengeRyanWeb.Router do
  use DevChallengeRyanWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", DevChallengeRyanWeb do
    pipe_through :api

    scope "api" do
      scope "v1", V1 do
        post "/check-status", BlockChainController, :check_status
      end
    end
  end
end

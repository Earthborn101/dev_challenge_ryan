defmodule DevChallengeRyanWeb.V1.BlockChainController do
  use DevChallengeRyanWeb, :controller

  alias DevChallengeRyanWeb.Contexts.BlockChainContext
  alias DevChallengeRyanWeb.Contexts.UtilityContext
  alias DevChallengeRyanWeb.Contexts.ValidationContext
  alias DevChallengeRyanWeb.BlockChainView

  def check_status(conn, params) do
    :check_status
    |> BlockChainContext.validate_params(params)
    |> ValidationContext.valid_changeset()
    |> BlockChainContext.check_status(conn)
    |> return_result(conn)
  end

  defp return_result({:error, changeset}, conn) do
    conn
    |> put_status(200)
    |> put_view(BlockChainView)
    |> render("error.json", errors: UtilityContext.transform_error_message(changeset))
  end

  defp return_result({:ok, params}, conn) do
    conn
    |> put_status(200)
    |> put_view(BlockChainView)
    |> render("success.json", result: params)
  end
end

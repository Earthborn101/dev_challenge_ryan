defmodule DevChallengeRyanWeb.V1.BlockChainController do
  use DevChallengeRyanWeb, :controller

  alias DevChallengeRyan.Contexts.BlockChainContext
  alias DevChallengeRyan.Contexts.UtilityContext
  alias DevChallengeRyan.Contexts.ValidationContext
  alias DevChallengeRyanWeb.BlockChainView

  def add_transaction_id(conn, params) do
    :add_transaction_id
    |> BlockChainContext.validate_params(params)
    |> ValidationContext.valid_changeset()
    |> BlockChainContext.add_transaction_id(conn)
    |> return_result(conn)
  end

  def check_for_pending_transactions(conn, _params) do
    return = BlockChainContext.get_watch_transactions()

    return
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

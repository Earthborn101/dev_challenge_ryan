defmodule DevChallengeRyanWeb.BlockChainController do
  use DevChallengeRyanWeb.ConnCase

  test "Get Pending transactions", %{conn: conn} do
    conn = get(conn, "/api/v1/check-for-pending-transactions")
    response = json_response(conn, 200)["message"]

    assert response == "No Pending transactions"
  end

  test "Add transaction id error/ Enter txid", %{conn: conn} do
    conn = post(conn, "api/v1/add-transaction-id", %{})
    response = json_response(conn, 200)["txid"]

    assert response == "Enter txid"
  end
end

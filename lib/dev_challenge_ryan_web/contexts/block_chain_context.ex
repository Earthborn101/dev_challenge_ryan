defmodule DevChallengeRyanWeb.Contexts.BlockChainContext do
  @moduledoc false

  import Ecto.Query, warn: false

  ### ALIAS CONTEXTS
  alias DevChallengeRyanWeb.Contexts.UtilityContext

  ### ALIAS Request
  alias DevChallengeRyanWeb.Request

  ### ALIAS SCHEMAS
  alias DevChallengeRyan.Schemas.TransactionWatchlist
  
  ### ALIAS Changeset
  alias Ecto.Changeset

  ### -- Start of validate params -- ###
  def validate_params(:add_transaction_id, params) do
    fields = %{
      txid: :string
    }

    {%{}, fields}
    |> Changeset.cast(params, Map.keys(fields))
    |> Changeset.validate_required(
      [
        :txid
      ],
      message: "Enter txid"
    )
    |> UtilityContext.is_valid_changeset_map()
  end

  ### -- End of validate params -- ###

  ### -- 
  def add_transaction_id({:error, changeset}, _conn), do: {:error, changeset}

  def add_transaction_id({params, changeset}, conn) do
    url = Request.process_request_url("transaction", :blocknative_url)
    api_key = UtilityContext.get_url_or_value(:api_key)

    fields =
      params
      |> Map.put(:apiKey, api_key)
      |> Map.put(:blockchain, "ethereum")
      |> Map.put(:network, "main")
      |> Map.put(:hash, "#{params[:txid]}")
      |> Map.delete(:txid)

    conn
    |> Request.post(url, fields, [])
    |> check_if_suscribe(params, changeset)
  end

  defp check_if_suscribe({:ok, %{"msg" => "success"}}, params, changeset) do

  end

  defp check_if_suscribe({:bad_request, _msg}, _params, changeset) do
    {
      :error,
      changeset
      |> Changeset.add_error(
        :txid,
        "Tx id is invalid"
      )
    }
  end

  defp check_if_suscribe(_, _params, changeset) do
    {
      :error,
      changeset
      |> Changeset.add_error(
        :message,
        "Something went wrong. Please try again later."
      )
    }
  end
end

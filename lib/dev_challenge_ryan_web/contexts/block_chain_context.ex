defmodule DevChallengeRyanWeb.Contexts.BlockChainContext do
  @moduledoc false

  import Ecto.Query, warn: false

  ### ALIAS CONTEXTS
  alias DevChallengeRyanWeb.Contexts.UtilityContext

  ### ALIAS Request
  alias DevChallengeRyanWeb.Request

  ### ALIAS SCHEMAS
  alias DevChallengeRyanWeb.Schemas.TransactionWatchlist
  
  ### ALIAS Changeset
  alias Ecto.Changeset

  ### ALIAS Repo
  alias DevChallengeRyan.Repo

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
    |> validate_tx_id_if_exist()
    |> UtilityContext.is_valid_changeset_map()
  end

  defp validate_tx_id_if_exist(%{
    changes: %{
      txid: txid
    }
  } = changeset) do
    transaction_id =
      TransactionWatchlist
      |> Repo.get_by(txid: txid)
  
    if is_nil(transaction_id) do
      changeset
    else
      changeset
      |> Changeset.add_error(
        :txid,
        "TX id already exist"
      )
    end
  end
  defp validate_tx_id_if_exist(changeset), do: changeset
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
    fields =
      params
      |> Map.put(:status, "P")
    
    %TransactionWatchlist{}
    |> TransactionWatchlist.changeset(fields)
    |> Repo.insert()

    {:ok, %{message: "Successfully suscribe to #{params.txid}"}}
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

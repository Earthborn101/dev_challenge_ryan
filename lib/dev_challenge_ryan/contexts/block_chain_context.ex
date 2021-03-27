defmodule DevChallengeRyan.Contexts.BlockChainContext do
  @moduledoc false

  import Ecto.Query, warn: false

  ### ALIAS Backgroun Job
  alias DevChallengeRyanWeb.BackgroundJob

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

  def validate_params(:get_watch_transactions, params) do
    fields = %{
      page: :integer,
      size: :integer,
      order: :string
    }

    {%{}, fields}
    |> Changeset.cast(params, Map.keys(fields))
    |> Changeset.validate_required(
      [
        :page
      ],
      message: "Enter page"
    )
    |> Changeset.validate_required(
      [
        :size
      ],
      message: "Enter size"
    )
    |> Changeset.validate_required(
      [
        :order
      ],
      message: "Enter order"
    )
    |> Changeset.validate_inclusion(
      :order,
      [
        "asc",
        "desc"
      ],
      message: "Order is invalid. Allowed values ['asc', 'desc']"
    )
    |> Changeset.validate_number(
      :page,
      greater_than: 0,
      message: "Page must be greater than 0"
    )
    |> Changeset.validate_number(
      :size,
      greater_than: 0,
      message: "Size must not be greater than 0"
    )
    |> Changeset.validate_number(
      :size,
      less_than: 101,
      message: "Size must be less than or equal to 100"
    )
    |> UtilityContext.is_valid_changeset()
  end

  defp validate_tx_id_if_exist(
         %{
           changes: %{
             txid: txid
           }
         } = changeset
       ) do
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

  ### -- Start of Add transaction -- ###
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
    BackgroundJob.send_notification(params)
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

  ## -- End of Add transaction -- ##

  ## -- Start of Get watched transactions -- ##
  def get_watch_transactions({:error, changeset}, _conn), do: {:error, changeset}

  def get_watch_transactions(params, conn) do
    url = Request.process_request_url("transaction", :blocknative_url)
    api_key = UtilityContext.get_url_or_value(:api_key)

    url =
      "#{url}/#{api_key}/ethereum/main?page=#{params.page}&size=#{params.size}&order=#{
        params.order
      }"

    conn
    |> Request.get(url, [])
    |> get_return_result()
  end

  defp get_return_result({:ok, %{"items" => items}}), do: {:ok, items}

  defp get_return_result(_) do
    {:error, %{errors: [message: {"Something went wrong. Please try again", []}]}}
  end

  ## -- Start of Check Transaction -- ##
  def check_transaction_notification(params) do
    Process.sleep(1_000)

    url =
      :etherscan_url
      |> UtilityContext.get_url_or_value()
      |> set_query_params(params)

    %{}
    |> Request.get(url, [])
    |> raise
  end

  defp set_query_params(url, params) do
    etherscan_key =
      :ether_api_key
      |> UtilityContext.get_url_or_value()

    "#{url}?module=transaction&action=getstatus&txhash=#{params.txid}&apikey=#{etherscan_key}"
  end

  ## -- End of Check Transaction -- ##
end

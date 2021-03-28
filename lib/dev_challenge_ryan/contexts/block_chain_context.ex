defmodule DevChallengeRyan.Contexts.BlockChainContext do
  @moduledoc false

  @type changeset() :: map()
  @type params() :: map()

  import Ecto.Query, warn: false

  ### ALIAS Backgroun Job
  alias DevChallengeRyanWeb.BackgroundJob

  ### ALIAS CONTEXTS
  alias DevChallengeRyan.Contexts.UtilityContext

  ### ALIAS Request
  alias DevChallengeRyanWeb.Request

  ### ALIAS Changeset
  alias Ecto.Changeset

  ### -- Start of validate params -- ###
  @spec validate_params(atom(), params) :: tuple()
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
    |> validate_tx_id_if_running_in_background()
    |> UtilityContext.is_valid_changeset_map()
  end

  defp validate_tx_id_if_running_in_background(
         %{
           changes: %{
             txid: txid
           }
         } = changeset
       ) do
    check_return = BackgroundJob.call_ongoing()

    if Enum.empty?(check_return) do
      changeset
    else
      check_return
      |> Enum.map(fn tx_id -> tx_id.txid end)
      |> Enum.filter(&(&1 == txid))
      |> Enum.empty?()
      |> check_tx_return(changeset)
    end
  end

  defp validate_tx_id_if_running_in_background(changeset), do: changeset

  defp check_tx_return(true, changeset), do: changeset

  defp check_tx_return(false, changeset) do
    changeset
    |> Changeset.add_error(:txid, "Already pending in the background")
  end

  ### -- End of validate params -- ###

  ### -- Start of Add transaction -- ###
  def add_transaction_id({:error, changeset}, _conn), do: {:error, changeset}

  def add_transaction_id({params, changeset}, conn) do
    url = Request.process_request_url("transaction", :blocknative_url)
    api_key = UtilityContext.get_url_or_value(:api_key_2)

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

  defp check_if_suscribe({:ok, %{"msg" => "success"}}, params, _changeset) do
    notify_slack_new_watched_address(params)
    BackgroundJob.add_notification(params)
    BackgroundJob.run_notification(params)
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
  def get_watch_transactions do
    check_return = BackgroundJob.call_ongoing()

    if Enum.empty?(check_return) do
      {:ok, %{message: "No Pending transactions"}}
    else
      return =
        check_return
        |> Enum.map(fn txid -> txid.txid end)

      {:ok, %{pending_transactions: return}}
    end
  end

  ## -- End of Get watched transactions -- ##

  ## -- Start of check watch transactions -- ##
  defp check_watch_transactions(
         %{
           page: page,
           size: size,
           order: order
         },
         conn
       ) do
    url = Request.process_request_url("transaction", :blocknative_url)
    api_key = UtilityContext.get_url_or_value(:api_key_2)
    url = "#{url}/#{api_key}/ethereum/main?page=#{page}&size=#{size}&order=#{order}"

    conn
    |> Request.get(url, [])
  end

  defp check_watch_transactions(_params, conn) do
    url = Request.process_request_url("transaction", :blocknative_url)
    api_key = UtilityContext.get_url_or_value(:api_key_2)
    url = "#{url}/#{api_key}/ethereum/main?page=1&size=100&order=desc"

    conn
    |> Request.get(url, [])
  end

  ## -- End of check watch transactions -- ##

  ## -- Start of Check Transaction -- ##
  def check_transaction_notification(params) do
    Process.sleep(10_000)

    url =
      "api/conversations.history"
      |> Request.process_request_url(:slack_url)
      |> set_query_params()

    slack_token = UtilityContext.get_url_or_value(:slack_token_2)

    %{}
    |> Request.get(url, [{"Authorization", "Bearer #{slack_token}"}])
    |> get_message_latest(params)
  end

  defp set_query_params(url) do
    "#{url}?channel=C01S70289AT"
  end

  defp get_message_latest({:ok, return}, params) do
    text = return["messages"]

    text
    |> find_first_with_txid(params)
  end

  defp find_first_with_txid([return | tails], params) do
    text = return["text"]

    if String.contains?(text, params.txid) do
      text
      |> check_status(params)
    else
      find_first_with_txid(tails, params)
    end
  end

  defp find_first_with_txid(_, params), do: params

  defp check_status(text, params) do
    status_map =
      text
      |> String.trim_leading("```{")
      |> String.trim_trailing("}```")
      |> String.split([","])
      |> Enum.map(fn x ->
        x
        |> String.trim_leading()
        |> String.trim()
        |> String.replace("\"", "")
        |> String.split([": "])
      end)
      |> Enum.filter(fn a -> check_pattern(a) end)
      |> Map.new(fn [a, b] -> {a, b} end)

    if status_map["status"] == "pending" do
      check_time(params)
    else
      get_transation_status(status_map, params)
    end
  end

  defp check_pattern([a, _b]), do: a == "status"
  defp check_pattern(_), do: nil

  defp check_time(
         %{
           start_time: start_time
         } = params
       ) do
    diff = Timex.diff(Timex.now(), start_time, :minute)

    if diff >= 2 do
      IO.puts("#{params.txid} is still ongoing")
      notify_transaction_id_is_still_pending(params)
      params = Map.put(params, :start_time, Timex.now())

      params
      |> check_transaction_notification()
    else
      IO.puts("#{params.txid} goes here")
      check_transaction_notification(params)
    end
  end

  defp get_transation_status(%{"status" => "confirmed"}, params),
    do: notify_webhook_status(params, "confirmed")

  defp get_transation_status(%{"status" => "dropped"}, params),
    do: notify_webhook_status(params, "dropped")

  defp get_transation_status(%{"status" => "cancel"}, params),
    do: notify_webhook_status(params, "cancel")

  defp get_transation_status(_, params),
    do: notify_webhook_status(params, "failed")

  ## -- End of Check Transaction -- ##

  ## -- Start of Slacked Notifications -- ##
  defp notify_slack_new_watched_address(params) do
    url = UtilityContext.get_url_or_value(:slack_webhook)

    body = %{
      text: "Hi value customer. \n\n
      A new TX id '#{params.txid}' is added to the watched list.\n 
      Please wait while we verify status \n\n
      Thank you. Kind regards \n
      Dev Team"
    }

    %{}
    |> Request.post(url, body, [])
  end

  defp notify_transaction_id_is_still_pending(params) do
    url = UtilityContext.get_url_or_value(:slack_webhook)

    body = %{
      text: "Hi value customer. \n\n
      TX id '#{params.txid}' is still ongoing. \n\n 
      Thank you. Kind regards \n
      Dev Team"
    }

    %{}
    |> Request.post(url, body, [])
  end

  defp notify_webhook_status(params, error)
       when error in ["failed"] do
    url = UtilityContext.get_url_or_value(:slack_webhook)

    body = %{
      text: "Hi value customer. \n\n
      TX id '#{params.txid}' has encountered an error. \n
      Dropped txid.\n\n 
      Thank you. Kind regards \n
      Dev Team"
    }

    %{}
    |> Request.post(url, body, [])
  end

  defp notify_webhook_status(params, string) do
    url = UtilityContext.get_url_or_value(:slack_webhook)

    body = %{
      text: "Hi value customer. \n\n
      TX id '#{params.txid}' is complete. Tx id is #{transform_status(string)}.\n\n 
      Thank you. Kind regards \n
      Dev Team"
    }

    %{}
    |> Request.post(url, body, [])
  end

  defp transform_status("cancel"), do: "cancelled"
  defp transform_status(string), do: string
  ## -- End of Slacked Notifications -- ##
end

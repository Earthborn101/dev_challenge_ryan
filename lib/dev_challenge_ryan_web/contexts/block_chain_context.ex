defmodule DevChallengeRyanWeb.Contexts.BlockChainContext do
  @moduledoc false

  import Ecto.Query, warn: false

  ### ALIAS CONTEXTS
  alias DevChallengeRyanWeb.Contexts.UtilityContext

  ### ALIAS Request
  alias DevChallengeRyanWeb.Request

  ### ALIAS Changeset
  alias Ecto.Changeset

  ### -- Start of validate params -- ###
  def validate_params(:check_status, params) do
    fields = %{
      txid: :string
    }

    {%{}, fields}
    |> Changeset.cast(params, Map.keys(fields))
    |> Changeset.validate_required(
      [
        :txid
      ],
      message: "Enter tx id"
    )
    |> UtilityContext.is_valid_changeset()
  end

  ### -- End of validate params -- ###

  ### -- 
  def check_status({:error, changeset}), do: {:error, changeset}

  def check_status(params, conn) do
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
  end
end

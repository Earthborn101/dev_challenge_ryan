defmodule DevChallengeRyanWeb.BackgroundJob do
  use GenServer
  @moduledoc false

  alias DevChallengeRyan.Contexts.BlockChainContext

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: TransactionJob)
  end

  def init(state) do
    # Schedule work to be performed at some point
    {:ok, state}
  end

  def call_ongoing do
    GenServer.call(TransactionJob, :get_pending_transaction_ids)
  end

  def add_notification(args) do
    GenServer.cast(TransactionJob, {:check_transaction_id, args})
  end

  def run_notification(args) do
    GenServer.cast(TransactionJob, {:run_pending_ids, args})
  end

  @impl true
  def handle_cast({:check_transaction_id, args}, state) do
    state = state ++ [args]
    {:noreply, state}
  end

  def handle_cast({:run_pending_ids, args}, state) do
    params =
      args
      |> Map.put(:start_time, Timex.now())

    BlockChainContext.check_transaction_notification(params)

    state = Enum.filter(state, &(&1.txid !== args.txid))

    {:noreply, state}
  end

  @imp true
  def handle_call(:get_pending_transaction_ids, _from, state) do
    {:reply, state, state}
  end

  def handle_call(:get_pending_transaction_ids, _from, state) do
    {:noreply, state}
  end

  def handle_info(_, state) do
    {:noreply, state}
  end
end

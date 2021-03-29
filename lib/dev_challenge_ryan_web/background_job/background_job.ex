defmodule DevChallengeRyanWeb.BackgroundJob do
  use GenServer
  @moduledoc false

  alias DevChallengeRyan.Contexts.BlockChainContext

  def start_link do
    GenServer.start_link(__MODULE__, [], name: TransactionJob)
  end

  def init(state) do
    # Schedule work to be performed at some point
    check_ongoing_work(state)
    {:ok, state}
  end

  def handle_info(:work, state) do
    check_ongoing_work(state)
  end

  def handle_info(_, state) do
    {:noreply, state}
  end

  defp check_ongoing_work([] = state) do
    Process.send_after(self(), :work, 5_000)
    {:noreply, state}
  end

  defp check_ongoing_work([head | tails]) do
    head
    |> BlockChainContext.check_transaction_notification()
    |> check_job_return(tails)
  end

  defp check_job_return({:ok, _params}, state) do
    Process.send_after(self(), :work, 5_000)
    {:noreply, state}
  end

  defp check_job_return({:pending, params}, state) do
    state = state ++ [params]
    Process.send_after(self(), :work, 5_000)
    {:noreply, state}
  end

  def call_ongoing do
    GenServer.call(TransactionJob, :get_pending_transaction_ids, 10_000)
  end

  def add_notification(args) do
    GenServer.cast(TransactionJob, {:add_notification, args})
  end

  @impl true
  def handle_cast({:add_notification, args}, state) do
    state = state ++ [args]
    {:noreply, state}
  end

  @imp true
  def handle_call(:get_pending_transaction_ids, _from, state) do
    {:reply, state, state}
  end

  def handle_call(:get_pending_transaction_ids, _from, state) do
    {:noreply, state}
  end
end

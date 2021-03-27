defmodule DevChallengeRyanWeb.BackgroundJob do
  use GenServer
  @moduledoc false

  alias DevChallengeRyanWeb.Contexts.BlockChainContext

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok)
  end

  def init(state) do
    # Schedule work to be performed at some point
    {:ok, state}
  end

  def send_notification(args) do
    {:ok, pid} = start_link(:ok)
    GenServer.cast(pid, {:check_transaction_id, args})
  end

  @impl true
  def handle_cast({:check_transaction_id, args}, state) do
    BlockChainContext.check_transaction_notification(args)
    {:noreply, state}
  end

  def handle_info(_, state) do
    {:noreply, state}
  end
end

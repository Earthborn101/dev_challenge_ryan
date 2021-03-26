defmodule DevChallengeRyanWeb.BackgroundJob do
  use GenServer
  @moduledoc false

  def start_link do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    # Schedule work to be performed at some point
    schedule_work()
    {:ok, state}
  end

  def handle_info(:work, state) do
    # Do the work you desire here
    # Reschedule once more
    schedule_work()
    {:noreply, state}
  end

  def handle_info(_, state) do
    {:noreply, state}
  end

  defp schedule_work do
    Process.send_after(self(), :work, 10_000)
    IO.puts("This is a test env")
  end
end

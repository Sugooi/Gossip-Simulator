defmodule GossipSimulator.GossipNode do
  use GenServer

  @moduledoc """
  #Gossip Simulator Node
  """

  def start_link(node_index, neighbours) do
    rumor_count = 0

    GenServer.start_link(__MODULE__, {rumor_count, neighbours},
      name: String.to_atom("worker_node_" <> to_string(node_index))
    )
  end

  def init({rumor_count, neighbours}) do
    {:ok, {rumor_count, neighbours}}
  end

  def spread_rumor(neighbours) do
    next_worker_name = "worker_node_" <> to_string(Enum.random(neighbours))
    # IO.inspect(String.to_atom(next_worker_name))
    # IO.inspect(["Node: ", self()])
    GenServer.cast(String.to_atom(next_worker_name), {:spread_rumor, :ok})
    GenServer.cast(self(), {:spread_rumor, :ok})
  end

  def handle_cast({:spread_rumor, :ok}, {rumor_count, neighbours}) do
    cond do
      rumor_count < 10 ->
        # IO.inspect([self(), "Received Rumor #{rumor_count} time"])
        spread_rumor(neighbours)
        {:noreply, {rumor_count + 1, neighbours}}

      rumor_count == 10 ->
        # IO.inspect([self(), "stopped transmitting"])
        send(:global.whereis_name(:mainproc), {:converged, self()})
        {:noreply, {rumor_count + 1, neighbours}}

      rumor_count > 10 ->
        {:noreply, {rumor_count, neighbours}}
    end
  end
end

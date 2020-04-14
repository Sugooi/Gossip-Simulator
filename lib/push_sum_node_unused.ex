defmodule GossipSimulator.PushSumNodeV1 do
  use GenServer

  @moduledoc """
  #Gossip Simulator Node
  """

  def start_link(node_index, neighbours) do
    s = node_index
    w = 1

    GenServer.start_link(__MODULE__, [nil, nil, [s, w], neighbours],
      name: String.to_atom("worker_node_" <> to_string(node_index))
    )
  end

  def init([state1, state2, state3, neighbours]) do
    {:ok, [state1, state2, state3, neighbours]}
  end

  def spread_rumor([_state1, _state2, state3, neighbours]) do
    next_worker_name = "worker_node_" <> to_string(Enum.random(neighbours))
    # IO.inspect(String.to_atom(next_worker_name))
    # IO.inspect(["Node: ", self()])
    # divide its own self
    GenServer.cast(self(), :divide_own)

    GenServer.cast(
      String.to_atom(next_worker_name),
      {:spread_rumor, [Enum.at(state3, 0) / 2, Enum.at(state3, 1) / 2]}
    )
  end

  def handle_cast({:spread_rumor, [s, w]}, [state1, state2, state3, neighbours]) do
    # this is running for more than 2 times, which means we have atlease three states stored
    try do
      if state1 != nil and state2 != nil do
        ratio1 = Enum.at(state1, 0) / Enum.at(state1, 1)
        ratio2 = Enum.at(state2, 0) / Enum.at(state2, 1)
        ratio3 = Enum.at(state3, 0) / Enum.at(state3, 1)
        # if diff is really small
        if abs(ratio1 - ratio2) < :math.pow(10, -10) and abs(ratio2 - ratio3) < :math.pow(10, -10) do
          # stop
          IO.inspect("Converged")
          send(:global.whereis_name(:mainproc), {:converged, self()})
          {:noreply, [state1, state2, state3, neighbours]}
        else
          # else continue
          staten = state2
          staten_1 = state3
          staten_2 = [Enum.at(state3, 0) + s, Enum.at(state3, 1) + w]
          spread_rumor([staten, staten_1, staten_2, neighbours])
          {:noreply, [staten, staten_1, staten_2, neighbours]}
        end
      else
        staten = state2
        staten_1 = state3
        staten_2 = [Enum.at(state3, 0) + s, Enum.at(state3, 1) + w]
        spread_rumor([staten, staten_1, staten_2, neighbours])
        {:noreply, [staten, staten_1, staten_2, neighbours]}
      end
    rescue
      _ -> spread_rumor([state1, state2, state3, neighbours])
    end
  end

  def handle_cast(:divide_own, [_state1, state2, state3, neighbours]) do
    staten = state2
    staten_1 = state3
    staten_2 = [Enum.at(state3, 0) / 2, Enum.at(state3, 1) / 2]
    IO.inspect(staten_2)
    {:noreply, [staten, staten_1, staten_2, neighbours]}
  end
end

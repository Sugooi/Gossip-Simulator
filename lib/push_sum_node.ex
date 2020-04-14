defmodule GossipSimulator.PushSumNode do
  use GenServer, restart: :transient

  @moduledoc """
  #Gossip Simulator Node
  """

  def start_link(node_index, neighbours, nodecount) do
    s = node_index
    w = 1
    counter = 0
    running = true

    GenServer.start_link(__MODULE__, [s, w, counter, neighbours, running, nodecount],
      name: String.to_atom("worker_node_" <> to_string(node_index))
    )
  end

  def init([s, w, counter, neighbours, running, nodecount]) do
    # IO.inspect([self(), s, w])
    {:ok, [s, w, counter, neighbours, running, nodecount]}
  end

  def spread_rumor([s, w, neighbours]) do
    next_worker_name = "worker_node_" <> to_string(Enum.random(neighbours))

    if(GenServer.whereis(String.to_atom(next_worker_name)) != nil) do
      GenServer.cast(
        String.to_atom(next_worker_name),
        {:spread_rumor, [s, w]}
      )
    end
  end

  def handle_cast({:spread_rumor, [s, w]}, [
        old_s,
        old_w,
        counter,
        neighbours,
        running,
        start_time
      ]) do
    counter1 = counter

    if counter1 < 3 and running do
      # IO.inspect([self(), s, w])
      old_ratio = old_s / old_w
      new_s = (s + old_s) / 2
      new_w = (w + old_w) / 2
      counter1 = counter
      new_ratio = new_s / new_w
      # IO.inspect(["First:", self(), counter1])

      counter1 =
        if abs(old_ratio - new_ratio) < :math.pow(10, -10) do
          counter1 = counter1 + 1
        else
          if counter1 > 0 do
            counter1 = 0
          end

          counter1
        end

      # IO.inspect(["Second:", self(), counter1])

      temp_list = [new_s, new_w, counter1, neighbours, running, start_time]
      # IO.inspect([self(), new_ratio])
      _new_list = spread_rumor([new_s, new_w, neighbours])
      {:noreply, temp_list}
    else
      # Process.exit(self(), :normal)
      IO.inspect([self(), s, w])
      terminate("no", [old_s, old_w, counter1, neighbours, false, start_time])
      # send(:global.whereis_name(:mainproc), {:converged, self()})

      {:noreply, [old_s, old_w, counter1, false]}
    end
  end

  def terminate(_reason, [old_s, old_w, _counter, _neighbours, _running, start_time]) do
    IO.puts("Terminated..with converged value: ")
    IO.puts(old_s / old_w)
    IO.puts("Converged Time #{System.system_time(:millisecond) - start_time}ms")
    System.halt(0)
  end

  def handle_cast(:divide_own, [_state1, state2, state3, neighbours]) do
    staten = state2
    staten_1 = state3
    staten_2 = [Enum.at(state3, 0) / 2, Enum.at(state3, 1) / 2]
    IO.inspect(staten_2)
    {:noreply, [staten, staten_1, staten_2, neighbours]}
  end
end

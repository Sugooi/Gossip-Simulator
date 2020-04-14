defmodule GossipSimulator.MainApp do
  use Application

  @moduledoc """
  Documentation for GossipSimulator.MainApp
  """

  @doc """
  Gossip Simulator

  ## Examples

      iex> GossipSimulator.MainApp.start()
      :ok

  """
  def start(_type, _args) do
    args = System.argv()
    {node_count, topology_type, algorithm_type} = process_args(args)
    GossipSimulator.Supervisor.start_link(node_count, topology_type, algorithm_type)
    # Saurabh start
    convergence_task = Task.async(fn -> converging(0, 0.9 * node_count) end)
    :global.register_name(:mainproc, convergence_task.pid)
    :global.register_name(:failurehelper, self())
    start_time = System.system_time(:millisecond)
    #
    initiate_gossip(algorithm_type, node_count)
    # Saurabh start
    fail_helper(0, 0.9 * node_count)
    Task.await(convergence_task, :infinity)
    time_diff = System.system_time(:millisecond) - start_time
    IO.puts("Time taken to achieve convergence: #{time_diff} milliseconds")
    System.halt(0)
    {:ok, self()}
  end

  def converging(nodes_converged, stopping_threshold) do
    # Receive convergence messages for both algorithms
    if(nodes_converged < stopping_threshold) do
      receive do
        {:converged, _pid} ->
          # IO.puts("#{inspect(pid)} Converged #{numNodes}")
          converging(nodes_converged + 1, stopping_threshold)
          # after
          #   5000 ->
          #     IO.puts("Convergence could not be reached for #{nodes_converged}")
          #     # mock process shutdown
          #     send(
          #       :global.whereis_name(:failurehelper),
          #       {:DOWN, :random, :process, :random, :cantconverge}
          #     )
          #
          #     converging(nodes_converged + 1, stopping_threshold)
      end
    else
      # IO.puts("#{nodes_converged} nodes converged ")
    end
  end

  def fail_helper(numNodes, stopping_threshold) do
    if(numNodes > stopping_threshold) do
      receive do
        {:DOWN, _, :process, pid, :killed} ->
          IO.puts("#{inspect(pid)} killed")
          fail_helper(numNodes, stopping_threshold)

        {:DOWN, _, :process, _pid, _reason} ->
          fail_helper(numNodes + 1, stopping_threshold)
      end
    else
      nil
    end
  end

  def initiate_gossip(algorithm_type, node_count) do
    cond do
      algorithm_type == "gossip" ->
        GossipSimulator.GossipNode.spread_rumor(1..node_count)

      algorithm_type == "push-sum" ->
        GenServer.cast(:worker_node_1, {:spread_rumor, [0, 0]})
    end
  end

  defp process_args(args) do
    node_count = String.to_integer(Enum.at(args, 0))
    topology_type = Enum.at(args, 1)
    algorithm_type = Enum.at(args, 2)

    check_args(node_count, topology_type, algorithm_type)

    IO.inspect(
      "nodes : #{node_count}, topology : #{topology_type}, algorithm : #{algorithm_type}"
    )

    {node_count, topology_type, algorithm_type}
  end

  defp check_args(node_count, topology_type, algorithm_type) do
    status = true

    if node_count < 1 do
      IO.puts("node count should be greater than 1")
      status = false
      System.halt(0)
    end

    topology_options = ["full", "line", "rand2D", "3Dtorus", "honeycomb", "randhoneycomb"]

    if(topology_type not in topology_options) do
      IO.inspect(
        "Incorrect topology specified: #{topology_type}. Topology options are: #{topology_options}"
      )

      status = false
      System.halt(0)
    end

    algorithm_options = ["gossip", "push-sum"]

    if(algorithm_type not in algorithm_options) do
      IO.puts(
        "Incorrect algorithm specified: #{algorithm_type}. Algorithm options are: #{
          algorithm_options
        }"
      )

      status = false
      System.halt(0)
    end

    status
  end
end

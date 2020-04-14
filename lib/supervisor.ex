defmodule GossipSimulator.Supervisor do
  use Supervisor

  def start_link(node_count, topology_type, algorithm_type) do
    Supervisor.start_link(__MODULE__, {node_count, topology_type, algorithm_type})
  end

  def init({node_count, topology_type, algorithm_type}) do
    topology = generate_topology(node_count, topology_type)
    worker_nodes = create_worker_nodes(node_count, algorithm_type, topology)
    supervise(worker_nodes, strategy: :one_for_one)
  end

  defp generate_topology(node_count, topology_type) do
    cond do
      topology_type == "full" ->
        GossipSimulator.FullTopology.generate(node_count)

      topology_type == "line" ->
        GossipSimulator.LineTopology.generate(node_count)

      topology_type == "rand2D" ->
        GossipSimulator.Random2DTopology.generate(node_count)

      topology_type == "honeycomb" ->
        GossipSimulator.HoneycombTopology.generate(node_count)

      topology_type == "randhoneycomb" ->
        GossipSimulator.HoneycombRandomTopology.generate(node_count)

      topology_type == "3Dtorus" ->
        GossipSimulator.TorusTopology.generate(node_count)
    end
  end

  defp create_worker_nodes(_node_count, algorithm_type, topology) do
    start_time = System.system_time(:millisecond)

    cond do
      algorithm_type == "gossip" ->
        for {node_index, neighbours} <- topology,
            do:
              worker(GossipSimulator.GossipNode, [node_index, neighbours],
                id: "worker_" <> to_string(node_index)
              )

      algorithm_type == "push-sum" ->
        for {node_index, neighbours} <- topology,
            do:
              worker(
                GossipSimulator.PushSumNode,
                [node_index, neighbours, start_time],
                id: "worker_" <> to_string(node_index)
              )
    end
  end
end

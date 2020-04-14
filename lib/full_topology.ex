defmodule GossipSimulator.FullTopology do
  def generate(node_count) do
    nodes = Enum.to_list(1..node_count)

    topology =
      for i <- nodes,
          do: {i, Enum.filter(nodes, fn t -> t != i end)}

    topology
  end
end

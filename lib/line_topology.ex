defmodule GossipSimulator.LineTopology do
  def generate(node_count) do
    nodes = Enum.to_list(1..node_count)

    topology =
      for i <- nodes,
          Enum.at(nodes, i + 1),
          do: {Enum.at(nodes, i), [Enum.at(nodes, i - 1), Enum.at(nodes, i + 1)]}

    topology = [{1, [2]}] ++ topology ++ [{node_count, [node_count - 1]}]
    topology
  end
end

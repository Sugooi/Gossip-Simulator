defmodule GossipSimulator.Random2DTopology do
  def generate(node_count) do
    nodes = Enum.to_list(1..node_count)

    points = Enum.map(nodes, fn _i -> {:rand.uniform(), :rand.uniform()} end)

    _topology =
      for node_index <- nodes,
          do:
            {node_index,
             Enum.filter(nodes, fn i ->
               is_neighbour(Enum.at(points, node_index - 1), Enum.at(points, i - 1)) and
                 i != node_index
             end)}
  end

  defp is_neighbour({x1, y1}, {x2, y2}) do
    tolerance = 0.1

    if :math.sqrt(:math.pow(x1 - x2, 2) + :math.pow(y1 - y2, 2)) < tolerance do
      true
    else
      false
    end
  end
end

defmodule GossipSimulator.TorusTopology do
  def generate(node_count) do
    nodes_list = Enum.to_list(1..node_count)
    row_node_count = round(Float.ceil(:math.pow(node_count, 1 / 3)))
    planar_node_count = round(:math.pow(row_node_count, 2))

    grid_node_count = row_node_count * row_node_count * row_node_count

    topology =
      for node_index <- 1..grid_node_count,
          do:
            {node_index,
             calculate_neighbours(
               node_index,
               grid_node_count,
               planar_node_count,
               row_node_count,
               nodes_list
             )}

    topology
  end

  def calculate_neighbours(
        node_index,
        grid_node_count,
        planar_node_count,
        row_node_count,
        nodes_list
      ) do
    positiveX =
      if node_index + 1 <= grid_node_count and rem(node_index, row_node_count) != 0 do
        node_index + 1
      else
        node_index - row_node_count + 1
      end

    negativeX =
      if node_index - 1 >= 1 and rem(node_index - 1, row_node_count) != 0 do
        node_index - 1
      else
        node_index + row_node_count - 1
      end

    positiveY =
      if(
        rem(node_index, planar_node_count) != 0 &&
          planar_node_count - row_node_count >= rem(node_index, planar_node_count)
      ) do
        node_index + row_node_count
      else
        node_index - planar_node_count + row_node_count
      end

    negativeY =
      if(
        planar_node_count - row_node_count * (row_node_count - 1) <
          rem(node_index - 1, planar_node_count) + 1
      ) do
        node_index - row_node_count
      else
        node_index + planar_node_count - row_node_count
      end

    positiveZ =
      if(node_index + planar_node_count <= grid_node_count) do
        node_index + planar_node_count
      else
        node_index - planar_node_count * (row_node_count - 1)
      end

    negativeZ =
      if(node_index - planar_node_count >= 1) do
        node_index - planar_node_count
      else
        node_index + planar_node_count * (row_node_count - 1)
      end

    neighbours = [
      Enum.at(nodes_list, positiveX - 1),
      Enum.at(nodes_list, negativeX - 1),
      Enum.at(nodes_list, positiveY - 1),
      Enum.at(nodes_list, negativeY - 1),
      Enum.at(nodes_list, positiveZ - 1),
      Enum.at(nodes_list, negativeZ - 1)
    ]

    neighbours = Enum.filter(neighbours, fn node_index -> node_index != nil end)
    neighbours
  end
end

defmodule GossipSimulator.HoneycombTopologyV1 do
  def generate(node_count) do
    nodes_along_X = trunc(Float.ceil(:math.sqrt(node_count / 2)))
    nodes_along_Y = 2 * nodes_along_X

    node_count = nodes_along_X * nodes_along_Y

    IO.inspect("Honeycomb topology : actual node count is #{node_count}\n")
    nodes = Enum.to_list(1..node_count)

    _topology =
      for i <- nodes,
          do: {i, node_neighbours(i, nodes_along_Y)}
  end

  defp node_neighbours(node_index, nodes_along_Y) do
    y_step = rem(node_index, nodes_along_Y)
    x_step = round((node_index - y_step) / nodes_along_Y) + 1

    is_odd = fn x -> rem(x, 2) != 0 end

    # TODO : handle floating nodes
    cond do
      y_step == 1 ->
        if is_odd.(x_step) do
          [node_index + 1, node_index + nodes_along_Y]
        else
          [node_index - nodes_along_Y, node_index + 1]
        end

      y_step == nodes_along_Y ->
        if is_odd.(x_step) do
          [node_index - nodes_along_Y, node_index - 1]
        else
          [node_index - 1, node_index + nodes_along_Y]
        end

      true ->
        if is_odd.(x_step) do
          if is_odd.(y_step) do
            [node_index - 1, node_index + 1, node_index + nodes_along_Y]
          else
            [node_index - 1, node_index + 1, node_index - nodes_along_Y]
          end
        else
          if is_odd.(y_step) do
            [node_index - 1, node_index + 1, node_index - nodes_along_Y]
          else
            [node_index - 1, node_index + 1, node_index + nodes_along_Y]
          end
        end
    end
  end
end

defmodule GossipSimulator.HoneycombRandomTopology do
  def generate(node_count) do
    nodes_along_X = trunc(Float.floor(:math.sqrt(node_count)))
    # nodes_along_Y = trunc(Float.ceil(node_count / nodes_along_X))

    nodes = Enum.to_list(1..node_count)

    topology =
      for i <- nodes,
          do:
            {i,
             node_neighbours(i, nodes_along_X)
             |> filter_invalid_node_indexes({1, node_count})
             |> add_random_neighbour({1, node_count})}

    topology
  end

  def filter_invalid_node_indexes(node_indexes, {actual_index_start, actual_index_end}) do
    Enum.filter(node_indexes, fn i -> i >= actual_index_start and i <= actual_index_end end)
  end

  def add_random_neighbour(neighbourlist, {actual_index_start, actual_index_end}) do
    neighbourlist ++ [Enum.random(actual_index_start..actual_index_end)]
  end

  defp node_neighbours(node_index, nodes_along_X) do
    y_step = trunc(Float.ceil(node_index / nodes_along_X))
    x_step = rem(node_index, nodes_along_X)

    is_odd = fn x -> rem(x, 2) != 0 end

    cond do
      (x_step == 1 or x_step == 0) and is_odd.(y_step) ->
        [node_index - nodes_along_X, node_index + nodes_along_X]

      is_odd.(y_step) and is_odd.(x_step) ->
        [node_index - nodes_along_X, node_index + nodes_along_X, node_index - 1]

      is_odd.(y_step) and !is_odd.(x_step) ->
        [node_index - nodes_along_X, node_index + nodes_along_X, node_index + 1]

      !is_odd.(y_step) and !is_odd.(x_step) ->
        [node_index - nodes_along_X, node_index + nodes_along_X, node_index - 1]

      !is_odd.(y_step) and is_odd.(x_step) ->
        [node_index - nodes_along_X, node_index + nodes_along_X, node_index + 1]
    end
  end
end

defmodule Guards do
  # Uses the sentinel values of
  # :guard
  # :empty
  # :locked

  # Is this space valid for visiting, on the board + empty.
  defp is_valid({_board, rows, cols}, {r, c}) when r < 0 or c < 0 or r >= rows or c >= cols do
    false
  end
  defp is_valid({board, _rows, _cols}, {r, c}) do
    value(board, {r, c}) == :empty
  end

  # Returns the value of a space on the board
  def value(board, {r, c}) when is_map(board) do
    Map.get(Map.get(board, r), c)
  end

  # Converts :guard to 0, for next value calsulations
  def int_value(:guard), do: 0
  def int_value(x), do: x

  # All potential neighbors, could be off the board or invalid.
  def neighbors({r, c}) do
    [{r - 1, c}, {r + 1, c}, {r, c - 1}, {r, c + 1}]
  end

  # Remove points that are off the board or already assigned.
  def filter_neighbors(points, {board, rows, cols}) do
    List.foldl(points, [],
      fn {r, c}, acc ->
        if is_valid({board, rows, cols}, {r, c}), do: acc ++ [{r, c}], else: acc
      end)
  end

  # Searches the board for location of :guard cells
  def find_guards(rtn, _row, []), do: rtn
  def find_guards(rtn, row, [{col, :guard}|tail]) do
    find_guards(rtn ++ [{row, col}], row, tail)
  end
  def find_guards(rtn, row, [{_col, _}|tail]) do
    find_guards(rtn, row, tail)
  end
  def find_guards([]), do: []
  def find_guards([{row, cols} | rows]) do
    find_guards([], row, Map.to_list(cols)) ++ find_guards(rows)
  end
  def find_guards(board) when is_map(board) do
    find_guards(Map.to_list(board))
  end

  # Updates a space by updating the whole board
  defp update_space(board, {r, c}, value) do
    Map.update!(board, r, fn map -> Map.update!(map, c, fn _ -> value end) end)
  end

  defp visit_neighbors([], acc, board, _) do
    {acc, board}
  end
  defp visit_neighbors([{r, c} | tail], acc, board, val) do
    case value(board, {r, c}) do
      :empty -> visit_neighbors(tail, acc ++ [{r, c}], update_space(board, {r, c}, val), val)
      _ -> visit_neighbors(tail, acc, board, val)
    end
  end

  # Queue is empty
  defp search([], {board, _, _}), do: board
  # Process the first item in the queue
  defp search([{r, c} | tail], {board, rows, cols}) do
    # Visit neighbors 1 level deep.
    {visited, board} = neighbors({r, c})
      |> filter_neighbors({board, rows, cols})
      |> visit_neighbors([], board, int_value(value(board, {r, c})) + 1)
    # Append newly visited items to the end of the queue, pass updated board.
    search(tail ++ visited, {board, rows, cols})
  end

  # Search the board and fill in :empty spaces
  def search({board, rows, cols}) do
    # Seed the BFS search w/ the location of all the guards.
    find_guards(board)
     |> search({board, rows, cols})
  end

  def print_row([]) do
  end
  def print_row([row|tail]) do
    IO.inspect(Map.values(row))
    print_row(tail)
  end
  def print(board) do
    Map.values(board) |> print_row()
  end
end

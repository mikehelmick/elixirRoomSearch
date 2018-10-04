defmodule GuardsTest do
  use ExUnit.Case
  doctest Guards

  test "get value" do
    board = Map.new(
      [{0, Map.new([{0, 0}, {1, 1}])},
       {1, Map.new([{0 ,2}, {1 ,3}])}
      ]
    )
    assert Guards.value(board, {0, 0}) == 0
    assert Guards.value(board, {0, 1}) == 1
    assert Guards.value(board, {1, 0}) == 2
    assert Guards.value(board, {1, 1}) == 3
  end

  test "calcs neighbors" do
    assert Guards.neighbors({4, 5}) ==
      [{3, 5}, {5, 5}, {4, 4}, {4, 6}]
  end

  test "filter neighbors" do
    board = Map.new(
      [{0, Map.new([{0, :empty},  {1, :guard}])},
       {1, Map.new([{0, :locked}, {1 ,2}     ])}
      ]
    )
    assert Guards.filter_neighbors(
      [{0, 0}, {0, 1}, {1, 0}, {1, 1}], {board, 2, 2}) ==
        [{0, 0}]
  end

  test "find guards" do
    board = Map.new(
      [{0, Map.new([{0, :empty},  {1, :guard}])},
       {1, Map.new([{0, :guard}, {1 ,2}     ])}
      ]
    )
    assert Guards.find_guards(board) == [{0, 1}, {1, 0}]
  end

  test "search" do
    board = Map.new(
      [{0, Map.new([{0, :empty},  {1, :empty},  {2, :empty}])},
       {1, Map.new([{0, :guard},  {1, :locked}, {2, :empty}])},
       {2, Map.new([{0, :empty},  {1, :empty},  {2, :guard}])},
      ]
    )
    solution = Map.new(
      [{0, Map.new([{0, 1},      {1, 2},       {2, 2}])},
       {1, Map.new([{0, :guard}, {1, :locked}, {2, 1}])},
       {2, Map.new([{0, 1},      {1, 1},       {2, :guard}])},
      ]
    )
    answer = Guards.search({board, 3, 3})
    assert answer == solution
  end
end

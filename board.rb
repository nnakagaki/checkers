require 'piece'

class Board
  def initialize
    new_board
  end

  def new_board
    @board = Array.new(10) { Array.new(10) }
    place_pieces
  end

  def place_pieces
    @board.each_with_index do |row, row_index|
      unless row_index == 4 || row_index == 5
        color = row_index < 5 ? :b | :r
        row.each do |el|
          el =
  end

end
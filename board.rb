# require_relative 'piece'
load 'piece.rb'
require 'colorize'

class Board
  def initialize
    new_board
  end

  def new_board
    @board = Array.new(10) { Array.new(10) }
    # place_pieces
    @board[1][1] = Piece.new([1,1], self, :r)
    @board[8][8] = Piece.new([8,8], self, :b)
  end

  def place_pieces
    @board.each_with_index do |row, row_index|
      unless row_index == 4 || row_index == 5
        color = row_index < 5 ? :b : :r
        row.each_index do |col_index|
          loc = [row_index, col_index]
          if (loc[0] + loc[1]).odd?
            @board[row_index][col_index] = Piece.new(loc, self, color)
          end
        end
      end
    end
  end

  def move(from, to)
    piece = self[from]
    if piece
      if piece.moves[:slide].include?(to)
        piece.perform_slide(to)
      elsif piece.moves[:jump].include?(to)
        piece.perform_jump(to)
      end
    end
  end

  def over?
    red = false
    blue = false
    @board.flatten.compact.each do |piece|
      piece.color == :r ? red = true : blue = true
    end

    if ( red && !blue ) || ( !red && blue )
      return true
    end

    false
  end

  def [](loc)
    @board[loc[0]][loc[1]]
  end

  def []=(loc, piece)
    @board[loc[0]][loc[1]] = piece
  end

  def draw
    render = ""

    @board.each_with_index do |row, i|
      if i == 0
        render += "     #{10 - i}║ "
      else
        render += "     #{10 - i} ║ "
      end

      row.each_with_index do |piece, j|
        square = piece.icon if piece
        square = ' ' unless piece
        if piece
          square = piece.color == :r ? square.light_red : square.light_blue
        end
        render += (i + j).even? ? " #{square} ".on_white : " #{square} "
      end
      render += " " + "║" + "\n"
    end

    render += " " * 7 + "╚" + "═" * 32 + "╝" + "\n"
    render = " " * 7 + "╔" + "═" * 32 + "╗" + "\n" + render
    render += " " * 9
    ('A'..'J').each { |letter| render += " #{letter} " }

    system('clear')
    puts "\n" * 8
    puts render
  end

  def inspect

  end

end
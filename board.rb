# require_relative 'piece'
load 'piece.rb'
require 'colorize'

class NoPieceError < ArgumentError
end

class NoMoveError < ArgumentError
end

class NotYourPieceError < ArgumentError
end

class Board
  def initialize(player)
    @p = player
    new_board
  end

  def new_board
    @board = Array.new(10) { Array.new(10) }
    place_pieces
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
    piece = self[from] #
    if piece
      if piece.moves[:slide].include?(to)
        piece.perform_slide(to)
      elsif piece.moves[:jump].include?(to)
        piece.perform_jump(to)
        extra_jump(piece, to)
      end
    end
  end

  def extra_jump(piece, to)
    jump_options = piece.moves[:jump]
    if jump_options.count > 0
      draw
      puts " Would you like to take another piece? (y/n)"
      answer = gets.chomp.downcase
      if answer == ?y
        puts " Your options are #{jump_options}"
        from = to
        begin
          to = @p.get_piece_move_to
          raise ArgumentError unless jump_options.include?(to)
        rescue ArgumentError
          puts " Cannot jump there! Try again..."
        end
        move(from, to)
      end
    end
  end

  def valid_from?(from,turn) #
    raise NoPieceError unless self[from]
    raise NoMoveError if self[from].all_moves.empty?
    raise NotYourPieceError unless self[from].color == turn
  end

  def valid_to?(from,to,turn)
    raise NoMoveError unless self[from].all_moves.include?(to)
  end

  def over?
    red = false
    blue = false
    @board.flatten.compact.each do |piece| #all
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
    render += "\n" * 2

    render = " Type 's' to save and 'exit' to return to main menu!\n\n" + render

    system('clear')
    puts "\n" * 8
    puts render
  end

  def inspect

  end

end
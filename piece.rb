class Piece
  UP_MOVE = [[1, 1], [1, -1]]
  DOWN_MOVE = [[-1, 1], [-1, -1]]

  attr_reader :color

  def initialize(loc, board, color)
    @loc, @board, @color = loc, board, color
    @king = false
    moves

  end

  def move_diffs
    UP_MOVE + DOWN_MOVE if @king
    UP_MOVE if color == :r
    UP_MOVE if color == :b
  end

  def opposite_color
    color == :r ? :b | :r
  end

  def moves
    @curr_moves = Hash.new([])
    move_diff.each do |dy, dx|
      move = [@loc[0] + dy, @loc[1] + dx]
      board_piece = board[move]
      if board_piece.empty?
        @curr_moves[:slide] << move
      elsif board_piece.color == opposite_color
        move = [@loc[0] + dy, @loc[1] + dx]
        board_piece = board[move]
        if board_piece.empty?
          @curr_moves[:jump] << move
        end
      end
    end
  end

  def perform_slide(move)
    raise MoveError unless @curr_moves[:slide].include?(move)
    @loc = move

    make_king?(move)

    moves
  end

  def perform_jump(move)
    raise MoveError unless @curr_moves[:jump].include?(move)
    jumped_loc = [(@loc[0] + move[0]) / 2, (@loc[1] + move[1]) / 2]
    board[jumped_loc] = nil
    @loc = move

    make_king?(move)

    moves
  end

  def make_king?(move)
    @king = true if move[1] == king_row
  end

  def king_row
    color == :r ? 0 : 9
  end


end
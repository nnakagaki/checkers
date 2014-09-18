class Piece
  UP_MOVE = [[1, 1], [1, -1]]
  DOWN_MOVE = [[-1, 1], [-1, -1]]

  attr_reader :color, :icon

  def initialize(loc, board, color)
    @loc, @board, @color = loc, board, color
    @king = false
    @icon = '⚉'
  end

  def move_diffs
    return UP_MOVE + DOWN_MOVE if @king
    return DOWN_MOVE if color == :r
    return UP_MOVE if color == :b
  end

  def opposite_color
    color == :r ? :b : :r
  end

  def moves
    moves = { slide: [], jump: [] }
    move_diffs.each do |dy, dx|
      move = [@loc[0] + dy, @loc[1] + dx]
      next unless inside_board?(move)
      board_piece = @board[move]
      if board_piece.nil?
        moves[:slide] << move
      elsif board_piece.color == opposite_color
        move = [@loc[0] + dy * 2, @loc[1] + dx * 2]
        board_piece = @board[move]
        unless board_piece
          moves[:jump] << move
        end
      end
    end

    moves
  end

  def inside_board?(move)
    return false unless move[0].between?(0,9)
    return false unless move[1].between?(0,9)
    true
  end

  def perform_slide(move)
    # raise MoveError unless moves[:slide].include?(move)
    @board[@loc] = nil
    @loc = move
    @board[@loc] = self

    p make_king?(move)
    p make_king if @king
  end

  def perform_jump(move)
    # raise MoveError unless moves[:jump].include?(move)
    jumped_loc = [(@loc[0] + move[0]) / 2, (@loc[1] + move[1]) / 2]
    @board[jumped_loc] = nil
    @board[@loc] = nil
    @loc = move
    @board[@loc] = self

    make_king?(move)
    make_king if @king
  end

  def make_king?(move)
    @king = true if move[0] == king_row
  end

  def make_king
    @icon = '♕'
  end

  def king_row
    color == :r ? 0 : 9
  end


end
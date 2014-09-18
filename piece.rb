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
    color == :r ? DOWN_MOVE : UP_MOVE
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

  def all_moves
    moves[:slide] + moves[:jump]
  end

  def inside_board?(move)
    move.all? {|el| el.between?(0,9)}
  end

  def perform_slide(move)
    move_piece(move)
    make_king(move)
  end

  def perform_jump(move)
    jumped_loc = [(@loc[0] + move[0]) / 2, (@loc[1] + move[1]) / 2]
    @board[jumped_loc] = nil
    move_piece(move)
    make_king(move)
  end

  def move_piece(move)
    @board[@loc] = nil
    @loc = move
    @board[@loc] = self
  end

  def make_king(move)
    if move[0] == king_row
      @king = true
      @icon = '♕'
    end
  end

  def king_row
    color == :r ? 0 : 9
  end


end
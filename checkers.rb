load 'board.rb'

class Checkers
  def initialize
    @p = HumanPlayer.new
    play
  end

  def play
    board = Board.new
    until board.over?
      board.draw
      from = @p.get_piece_to_move
      to = @p.get_piece_move_to
      board.move(from, to)
    end

    board.draw
    puts "Game Over"
  end

end

class HumanPlayer
  ASSIGNMENTS =
                {
                  ?A => 0,
                  ?B => 1,
                  ?C => 2,
                  ?D => 3,
                  ?E => 4,
                  ?F => 5,
                  ?G => 6,
                  ?H => 7,
                  ?I => 8,
                  ?J => 9,
                  "10" => 0,
                  ?9 => 1,
                  ?8 => 2,
                  ?7 => 3,
                  ?6 => 4,
                  ?5 => 5,
                  ?4 => 6,
                  ?3 => 7,
                  ?2 => 8,
                  ?1 => 9
                }

  def intialize

  end

  def get_piece_to_move
    message = "Which piece do you want to move? (D4)"
    error_message = "You can't move that!"
    prompt(message, error_message) do |input|
      input.upcase =~ /(^[A-J][1-9]$)|(^[A-J][1][0]$)/
      return input_parser(input.upcase)
    end
  end

  def get_piece_move_to
    message = "Where to you want to move it? (A10)"
    error_message = "You can't move that!"
    user_input = prompt(message, error_message) do |input|
      input.upcase =~ /(^[A-J][1-9]$)|(^[A-J][1][0]$)/
      return input_parser(input.upcase)
    end
  end

  def input_parser(input)
    input = input.split("")
    [ASSIGNMENTS[input[1]], ASSIGNMENTS[input[0]]]
  end

  def prompt(message, error_message, &prc)
    puts message
    begin
      input = gets.chomp
      raise ArgumentError unless prc.call(input)
    rescue ArgumentError
      puts error_message
      retry
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  c = Checkers.new
end
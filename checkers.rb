load 'board.rb'
load 'read_key.rb'
require 'yaml'

class NamingError < ArgumentError
end

class ExistingFileError < ArgumentError
end

class Checkers
  attr_reader :board, :players, :turn

  def initialize
    @board = nil
    @players = nil
    welcome
  end

  def play
    until board.over?
      board.draw

      begin
        from = @players[@turn].get_piece_to_move

        if from == ?S
          return save
        elsif from == "EXIT"
          return welcome
        end

        board.valid_from?(from,@turn)
      rescue NoMoveError
        puts " That piece cannot move..."
        retry
      rescue NoPieceError
        puts " There is not piece there..."
        retry
      rescue NotYourPieceError
        color_str = @turn == :r ? "red" : "blue"
        puts " That is not your piece... Your color is #{color_str}!"
        retry
      end

      begin
        to = @players[@turn].get_piece_move_to
        if to == ?S
          return save
        elsif to == "EXIT"
          return welcome
        end

        board.valid_to?(from,to,@turn)
      rescue NoMoveError
        puts " That piece cannot move there..."
        retry
      end
      board.move(from, to)
      @turn = @turn == :r ? :b : :r
    end

    board.draw
    puts " Game Over"
  end

  def play_new
    @board = Board.new(@p)
    @players = { r: HumanPlayer.new(:r), b: HumanPlayer.new(:b) }
    @turn = :r
    play
  end

  def play_old
    puts " What file would you like to load?"
    begin
      filename = "./saves/" + gets.chomp + ".yml"
      if filename.downcase == './saves/exit.yml'
        return exit
      end
      game = YAML::load_file(filename)
    rescue Errno::ENOENT
      puts "There is no such save file! Try again or type exit to cancel."
      retry
    end
    @board = game.board
    @players = game.players
    @turn = game.turn
    play
  end

  def exit
    welcome
  end

  def save
    puts " What would you like to name the save file?"
    begin
      filename = "./saves/" + gets.chomp + ".yml"
      raise NamingError if filename == './saves/exit.yml'
      raise ExistingFileError if File.exists?(filename)
    rescue NamingError
      puts " Cannot name file exit. Try another name!"
      retry
    rescue ExistingFileError
      answer = @p.replace_file
      if answer == ?y

      else
        puts " What would you like to name the save file?"
        retry
      end
    end

    File.write(filename, self.to_yaml)
  end

  def welcome
    draw_menu

    temp = true
    @p = HumanPlayer.new(:r,temp)

    choice = @p.menu_choice
    if choice == ?n #
      play_new
    else
      play_old
    end
  end

  def draw_menu
    system('clear')
    puts "\n" * 5
    indent = 10
    puts " " * indent + "       WELCOME."
    puts " " * indent + "          TO"
    puts " " * indent + "THE WORLD OF CHECKERS!"
    puts "\n" * 2

    puts " " * (indent + 4) + "n => New Game"
    puts " " * (indent + 4) + "l => Load"
    puts "\n" * 2
    print " " * (indent + 10)
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

  def initialize(color, temp = false)
    @color = color

    if temp
      @name = ""
    else
      get_name
    end
  end

  def get_name
    color_str = @color == :r ? "Red player" : "Blue player"
    message = " #{color_str} enter your name!  "
    message = @color == :r ? message.red : message.blue
    print message
    @name = gets.chomp
  end

  def menu_choice
    message = ""
    error_message = " No such command! (n for new game, l to load)  "
    prompt(message, error_message) do |input|
      next false unless input.downcase =~ /^[nl]$/
      @user_input = input.downcase
    end

    @user_input
  end

  def replace_file
    message = " There is a file with that name already. Replace? (y/n)\n"
    error_message = " Please answer with y for yes or n for no.\n"
    prompt(message, error_message) do |input|
      next false unless input.downcase =~ /^[yn]$/
      @user_input = input.downcase
    end

    @user_input
  end

  def get_piece_to_move
    message = " #{@name}, which piece do you want to move? (ex. D4)  "
    message = @color == :r ? message.red : message.blue
    error_message = " Wrong syntax! input letter and number (ex. F8)  "
    get_piece_prompt(message, error_message)
  end

  def get_piece_move_to
    message = " #{@name}, where do you want to move it? (A10)    "
    message = @color == :r ? message.red : message.blue
    error_message = " Wrong syntax! input letter and number (ex. F8)"
    get_piece_prompt(message, error_message)
  end

  def get_piece_prompt(message, error_message)
    prompt(message, error_message) do |input|
      regex = /(^[A-J][1-9]$)|(^[A-J][1][0]$)|(^[S]$)|(^[E][X][I][T]$)/
      next false unless input.upcase =~ regex
      if input.upcase == ?S || input.upcase == "EXIT"
        @user_input = input.upcase
      else
        @user_input = input_parser(input.upcase)
      end
    end

    @user_input
  end

  def input_parser(input)
    input = input.split("")
    if input.count == 3
      input = [input[0], input[1] + input[2]]
    end

    [ASSIGNMENTS[input[1]], ASSIGNMENTS[input[0]]]
  end

  def prompt(message, error_message, &prc)
    print message
    begin
      input = gets.chomp
      raise ArgumentError unless prc.call(input)
    rescue ArgumentError
      print error_message
      retry
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  c = Checkers.new
end

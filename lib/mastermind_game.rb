require_relative 'mastermind_row'
require_relative 'mastermind_cli'
require_relative 'mastermind_bot'

# Define underlying mechanics of the game
class MastermindGame
  MAX_TURNS = 16

  attr_reader :row, :bot, :max_turns, :played_turns, :player_score

  def initialize(width = 4, number_of_colors = 6, max_turns = 8)
    @row = MastermindRow.new(width, number_of_colors)
    @cli = MastermindCLI.new(self)
    @bot = MastermindBot.new(@row)

    @pegs = { colored: 0, white: 0 }

    max_turns = 8 unless accept_turns?(max_turns)
    @max_turns = max_turns

    @played_turns = 0
    @player_score = 0
  end

  def pegs
    @pegs.clone
  end

  def accept_turns?(turns)
    return false unless turns.is_a?(Integer) && turns.positive?

    turns <= MAX_TURNS
  end

  def accept_pegs?(colored = 0, white = 0)
    return false unless colored.is_a?(Integer) && white.is_a?(Integer)
    return false if colored.negative? || white.negative?

    colored + white <= @row.width
  end

  def modify_turns(new_turns)
    return false unless accept_turns?(new_turns)

    @max_turns = new_turns
    true
  end

  def modify_pegs(colored = 0, white = 0)
    return false unless accept_pegs?(colored, white)

    @pegs[:colored] = colored
    @pegs[:white] = white
    true
  end

  def reset_pegs
    modify_pegs(0, 0)
  end

  def update_colored_pegs(dummy_code)
    @row.guess.each_with_index do |color, index|
      next unless color == dummy_code[index]

      @pegs[:colored] += 1
      dummy_code[index] = nil
    end
  end

  def update_white_pegs(dummy_code)
    @row.guess.each_with_index do |color, index|
      next if dummy_code[index].nil?

      found_index = dummy_code.find_index(color)
      next unless found_index

      @pegs[:white] += 1
      dummy_code[found_index] = -1 # Make search for this element unavailable
    end
  end

  def update_pegs
    return false if @row.unfinished_guess?

    reset_pegs
    dummy_code = @bot.code

    update_colored_pegs(dummy_code)
    update_white_pegs(dummy_code)
    true
  end

  def update_after_guess
    return @played_turns unless update_pegs

    @played_turns += 1
  end

  def win?
    @bot.correct_guess?(@row.guess)
  end

  def round_end?
    return true if @played_turns >= @max_turns
    return true if win?

    false
  end

  def reset_round
    @played_turns = 0
    @row.reset_guess
    @bot.generate_code
  end

  def add_score
    @player_score += 1
  end

  def play_cli
    @cli.play_once
  end
end

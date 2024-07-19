require_relative 'mastermind_row'
require_relative 'mastermind_cli'
require_relative 'mastermind_bot'

# Define underlying mechanics of the game
class MastermindGame
  MAX_TURNS = 12

  attr_reader :row, :bot, :max_turns, :played_turns, :player_score

  def initialize(width = 4, number_of_colors = 6, max_turns = 8)
    @row = MastermindRow.new(width, number_of_colors)
    @cli = MastermindCLI.new(self)
    @bot = MastermindBot.new(self)

    @pegs = { colored: 0, white: 0 }

    max_turns = 8 unless self.class.accept_turns?(max_turns)
    @max_turns = max_turns

    @played_turns = 0
    @player_score = 0
  end

  def pegs
    @pegs.clone
  end

  def self.accept_turns?(turns)
    return false unless turns.is_a?(Integer) && turns.positive?

    turns <= MAX_TURNS
  end

  def accept_pegs?(colored = 0, white = 0)
    return false unless colored.is_a?(Integer) && white.is_a?(Integer)
    return false if colored.negative? || white.negative?

    colored + white <= @row.width
  end

  def modify_turns(new_turns)
    return false unless self.class.accept_turns?(new_turns)

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

  def self.respond_colored_pegs(guess, code)
    colored_pegs = 0
    guess.each_with_index do |color, index|
      next unless color == code[index]

      colored_pegs += 1
      code[index] = nil
    end
    colored_pegs
  end

  def self.respond_white_pegs(guess, code)
    white_pegs = 0
    guess.each_with_index do |color, index|
      next if code[index].nil?

      found_index = code.find_index(color)
      next unless found_index

      white_pegs += 1
      code[found_index] = -1 # Make search for this element unavailable
    end
    white_pegs
  end

  def self.respond_pegs(guess, code)
    dummy_code = code.clone
    colored_pegs = respond_colored_pegs(guess, dummy_code)
    white_pegs = respond_white_pegs(guess, dummy_code)
    { colored: colored_pegs, white: white_pegs }
  end

  def update_pegs
    return false if @row.unfinished_guess?

    @pegs = self.class.respond_pegs(@row.guess, @bot.code)
    true
  end

  def update_after_guess
    return @played_turns unless update_pegs

    @played_turns += 1
  end

  def win?
    correct_guess = @bot.correct_guess?(@row.guess)

    @bot.guesser? ? !correct_guess : correct_guess
  end

  def round_end?
    return true if @played_turns >= @max_turns
    return true if @bot.correct_guess?(@row.guess)

    false
  end

  def reset_round
    @played_turns = 0
    @row.reset_guess
    @bot.reset_guess
    @bot.generate_code
  end

  def add_score
    @player_score += 1
  end

  def reset_score
    @player_score = 0
  end

  def play_cli(loop: true)
    @cli.play_once unless loop
    @cli.play_loop if loop
  end
end

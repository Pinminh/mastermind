require_relative 'mastermind_game'
require_relative 'mastermind_row'

# Manage automatic guesses and codes
class MastermindBot
  attr_reader :row, :game

  def initialize(game)
    @guesser = false

    @game = game

    @code = Array.new(@game.row.width)
    @prng = Random.new
    generate_code

    @all_possible_codes = Enumerator.new do |yielder|
      (0...@game.row.number_of_colors)
        .to_a.repeated_permutation(@game.row.width) { |perm| yielder << perm }
    end

    @guess = @poss = nil
    reset_guess
  end

  def guess
    @guess.clone
  end

  def code
    @code.clone
  end

  def guesser?
    @guesser
  end

  def toggle_bot
    @guesser = !@guesser
  end

  def generate_code
    return @code if guesser?

    @code.each_with_index do |_, index|
      @code[index] = @prng.rand(@game.row.number_of_colors)
    end
    @code
  end

  def receive_code(new_code)
    return false unless guesser?
    return false unless @game.row.accept_guess?(new_code)

    @code = new_code
    true
  end

  def correct_guess?(guess)
    return false unless @game.row.accept_guess?(guess)

    guess == @code
  end

  def choose_possbile_guess
    poss_length = 0
    @poss.each { poss_length += 1 }
    desired_index = poss_length / 2

    @poss.each_with_index { |guess, idx| return guess if idx == desired_index }
    nil
  end

  def get_next_guess(current_guess, response)
    @poss = @poss.select do |possible_code|
      MastermindGame.respond_pegs(current_guess, possible_code) == response
    end
    choose_possbile_guess
  end

  def update_next_guess
    @guess = get_next_guess(@guess, @game.pegs)
  end

  def reset_guess
    @poss = @all_possible_codes.clone

    half_width1 = @game.row.width / 2
    half_width2 = @game.row.width - half_width1

    color1 = 0
    color2 = @game.row.number_of_colors <= 1 ? 0 : 1

    @guess = Array.new(half_width1, color1) + Array.new(half_width2, color2)
  end
end

require_relative 'mastermind_row'

# Manage automatic guesses and codes
class MastermindBot
  attr_reader :row

  def initialize(row)
    @row = row

    @code = Array.new(@row.width)
    @prng = Random.new
    generate_code
  end

  def code
    @code.clone
  end

  def generate_code
    @code.each_with_index do |_, index|
      @code[index] = @prng.rand(@row.number_of_colors)
    end
    @code
  end

  def correct_guess?(guess)
    return false unless @row.accept_guess?(guess)

    guess == @code
  end
end

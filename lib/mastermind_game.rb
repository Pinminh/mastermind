require_relative 'mastermind_row'
require_relative 'mastermind_cli'

# Define underlying mechanics of the game
class MastermindGame
  attr_reader :row

  def initialize(width = 4, number_of_colors = 6, initial_turns = 8)
    raise 'number of colors exceeded limit' if number_of_colors > 12
    raise 'width exceeded limit' if width > 32

    @row = MastermindRow.new(width, number_of_colors)
    @initial_turns = initial_turns
    @played_turns = 0
    @player_score = 0

    @prng = Random.new
    @cli = MastermindCLI.new(self)
  end

  def reconfigure_turns(initial_turns)
    return false unless initial_turns.positive?

    @initial_turns = initial_turns
    true
  end

  def random_code
    new_code = @row.width.times.reduce([]) do |code, _|
      random_color = @prng.rand(row.number_of_colors)
      code.push(random_color)
    end

    @row.change_code(new_code)
    new_code
  end

  def update_played_state
    @played_turns += 1
    @row.update_feedback
  end

  def put_whole_guess(input)
    return false unless @row.accept_code?(input)

    input.each_with_index do |color, index|
      @row.write_color_at(index, color)
    end

    update_played_state
  end

  def feedback
    @row.feedback
  end

  def round_end?
    return true if @played_turns >= @initial_turns
    return true if @row.correct_guess?

    false
  end

  def reset_round
    @played_turns = 0
    @row.reset_guess
    random_code
  end

  def add_score
    @player_score += 1
  end

  def play_cli
    @cli.play_once
  end
end

require_relative 'mastermind_game'
require_relative 'mastermind_message'

# Manage interactions through terminal with the rows
class MastermindCLI
  include MastermindMessage

  CLR_CODE = %i[red green blue yellow cyan white
                tomato orange magenta aqua lime violet].freeze
  CLR_CHAR = %w[r g b y c w t o m a l v].freeze
  ROW_COLORS = 6

  def initialize(game = nil)
    game = MastermindGame.new unless game.is_a?(MastermindGame)
    @game = game

    @guess_hist = []
    @pegs_hist = []
  end

  def clear_terminal
    system('clear') || system('cls')
  end

  def print_guide
    clear_terminal
    puts guide_text(@game.row.width, @game.row.number_of_colors)
    gets
    clear_terminal
  end

  def cut_guess(guess)
    guess.map! { |char| CLR_CHAR.find_index(char.downcase) }

    raise 'invalid width' unless guess.length == @game.row.width
    raise 'invalid color' unless @game.row.accept_guess?(guess)
  end

  def ask_for_guess
    print input_prompt_text
    guess = gets.chomp.gsub(' ', '').chars
    cut_guess(guess)
    guess
  end

  def interpret_pegs
    pegs = @game.pegs
    colored = pegs[:colored]
    white = pegs[:white]
    gray = @game.row.width - colored - white
    Array.new(colored, 1) + Array.new(white, 0) + Array.new(gray, nil)
  end

  def reset_history
    @game.reset_round
    @guess_hist.clear
    @pegs_hist.clear
  end

  def process_guess
    guess = ask_for_guess
  rescue RuntimeError => e
    puts error_text(e, @game.row.width)
    retry
  else
    @game.row.put_guess(guess)
    @game.update_after_guess

    @guess_hist.push(guess)
    @pegs_hist.push(interpret_pegs)
  end

  def loop_play_round
    loop do
      print history_text(@guess_hist, @pegs_hist)
      print colors_guide_text(@game.row.width, @game.row.number_of_colors)
      print input_guide_text

      process_guess

      clear_terminal
      break if @game.round_end?
    end
  end

  def conclude_round
    puts "\n"
    puts result_text(@game.win?)
    puts right_answer_text(@game.bot.code) unless @game.win?
    puts
  end

  def play_once
    print_guide
    loop_play_round

    print history_text(@guess_hist, @pegs_hist)
    conclude_round
    reset_history
  end
end

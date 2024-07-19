require_relative 'mastermind_game'
require_relative 'mastermind_message'

# Manage interactions through terminal with the rows
class MastermindCLI
  include MastermindMessage

  CLR_CODE = %i[red green darkblue yellow cyan white
                tomato orange magenta].freeze
  CLR_CHAR = %w[r g b y c w t o m].freeze
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
    puts guide_text(@game.row.width, @game.row.number_of_colors)
  end

  def cut_guess(guess)
    guess.map! { |char| CLR_CHAR.find_index(char.downcase) }

    raise 'invalid width' unless guess.length == @game.row.width
    raise 'invalid color' unless @game.row.accept_guess?(guess)
  end

  def ask_for_role
    puts role_guide_text
    response = ''
    loop do
      print input_role_prompt_text
      response = gets.chomp.gsub(' ', '').downcase.slice(0, 3)
      break if %w[y n].include?(response[0]) || %w[yes no].include?(response)
    end

    @game.bot.toggle_bot if %w[y yes].include?(response)
    nil
  end

  def ask_for_code
    print input_code_prompt_text

    code = gets.chomp.gsub(' ', '').chars
    cut_guess(code)
    code
  end

  def process_role
    ask_for_role
    clear_terminal
    return unless @game.bot.guesser?

    puts colors_guide_text(@game.row.width, @game.row.number_of_colors)
    puts input_guide_text

    begin
      code = ask_for_code
    rescue RuntimeError => e
      puts error_text(e, @game.row.width)
      retry
    else
      @game.bot.receive_code(code)
      clear_terminal
    end
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

  def process_guess(guess)
    @game.row.put_guess(guess)
    @game.update_after_guess

    @guess_hist.push(guess)
    @pegs_hist.push(interpret_pegs)
  end

  def process_human_guess
    guess = ask_for_guess
  rescue RuntimeError => e
    puts error_text(e, @game.row.width)
    retry
  else
    process_guess(guess)
  end

  def process_bot_guess
    sleep 1
    process_guess(@game.bot.guess)
    @game.bot.update_next_guess
  end

  def process_game
    process_human_guess unless @game.bot.guesser?
    process_bot_guess if @game.bot.guesser?
  end

  def loop_play_round
    loop do
      print history_text(@guess_hist, @pegs_hist)
      puts colors_guide_text(@game.row.width, @game.row.number_of_colors)
      print input_guide_text

      process_game

      clear_terminal
      $stdout.flush
      break if @game.round_end?
    end
  end

  def conclude_round
    puts "\n"
    puts result_text(@game.win?, @game.bot.guesser?)
    puts right_answer_text(@game.bot.code) unless @game.win?
    puts
  end

  def process_configuration
  end

  def play_once
    process_configuration

    clear_terminal
    print_guide
    process_role

    loop_play_round

    print history_text(@guess_hist, @pegs_hist)
    conclude_round
    reset_history
  end
end

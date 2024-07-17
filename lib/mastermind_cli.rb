require 'rainbow/refinement'
require_relative 'mastermind_game'

# Manage interactions through terminal with the rows
class MastermindCLI
  CLR_CODE = %i[red green blue yellow cyan white
                tomato orange magenta aqua lime violet].freeze
  CLR_CHAR = %w[r g b y c w t o m a l v].freeze
  SLOT_SYMBOL = "\u25A0".freeze
  PEG_SYMBOL = "\u2022".freeze
  ROW_COLORS = 6

  def initialize(game)
    raise 'wrong type of game object' unless game.is_a?(MastermindGame)

    @game = game
    @game.random_code

    @guesses = []
    @feedbacks = []
  end

  def clear_terminal
    system('clear') || system('cls')
  end

  def print_guide_on_peg
    gray_peg_title = Rainbow("Gray pegs #{PEG_SYMBOL}").darkslategray
    white_peg_title = Rainbow("White pegs #{PEG_SYMBOL}").white
    orange_peg_title = Rainbow("Orange pegs #{PEG_SYMBOL}").orange

    puts ' - After each guess, there is a row of small pegs whose color ' \
         'indicates how good your guess is:'
    puts "    1. #{gray_peg_title} means that one of your colors isn't correct."
    puts "    2. #{white_peg_title} means that one of your colors is correct, " \
         "though its position isn't."
    puts "    3. #{orange_peg_title} means that one of your colors is correct,  " \
         'so is its position.'
  end

  def print_available_colors
    @game.row.number_of_colors.times do |index|
      clr_symb = CLR_CODE[index]
      clr_title = Rainbow("#{clr_symb} #{PEG_SYMBOL}").color(clr_symb)

      indent = '  '
      indent = "\t" if (index % ROW_COLORS).zero?
      print indent + clr_title.to_s
      print "\n" if index % ROW_COLORS == ROW_COLORS - 1
    end
  end

  def print_guide_on_color
    puts " - You must find #{@game.row.width} colors, each color is chosen " \
         "from these #{@game.row.number_of_colors} choices of colors, namely:"
    print_available_colors
    puts ' - You can choose one color multiple times for different slots.'
  end

  def print_guide_on_guess
    print_guide_on_color
    puts ' - For each of these colors, you should write your guess with their ' \
         "first alphabet character.\nFor example, 'rgbcwy' means 'red-green-" \
         'blue-cyan-white-yellow\'.'
  end

  def print_guide
    clear_terminal
    puts " - You need to guess correctly #{@game.row.width} colors in a row."

    print_guide_on_peg
    print_guide_on_guess
    $stdout.flush

    puts "\n\nPress Enter to continue..."
    gets
    clear_terminal
  end

  def ask_for_guess
    print 'Enter your guess: '
    $stdout.flush
    gets.chomp.gsub(' ', '').chars.map { |char| CLR_CHAR.find_index(char) }
  end

  def print_guess(guess)
    print "\t"
    guess.each do |index|
      color_symb = CLR_CODE[index]
      print Rainbow(SLOT_SYMBOL).color(color_symb)
      print ' '
      print Rainbow(SLOT_SYMBOL).color(color_symb)
      print '   '
    end
    print '  '
  end

  def print_feedback(feedback)
    feedback.each do |color|
      if color.nil?
        print Rainbow(PEG_SYMBOL).darkslategray
        next
      end
      print Rainbow(PEG_SYMBOL).white if color.zero?
      print Rainbow(PEG_SYMBOL).orange if color == 1
    end
    print "\n"
  end

  def print_history
    @guesses.each_with_index do |guess, index|
      print "\n"
      print_guess(guess)
      print_feedback(@feedbacks[index])
      print_guess(guess)
      print "\n"
    end
    $stdout.flush
  end

  def reset_history
    @game.reset_round
    @guesses.clear
    @feedbacks.clear
  end

  def process_guess
    guess = ask_for_guess
    @game.put_whole_guess(guess)

    @guesses.push(guess)
    @feedbacks.push(@game.feedback)
  end

  def loop_play_round
    loop do
      print_history
      print_guide_on_color

      process_guess
      clear_terminal
      break if @game.round_end?
    end
  end

  def play_once
    print_guide
    loop_play_round

    print_history
    puts @game.row.correct_guess? ? 'Haiz... You won' : 'Ah ha... Loser'
    reset_history
  end
end

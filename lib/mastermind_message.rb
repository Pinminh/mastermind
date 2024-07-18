require 'rainbow/refinement'

# Manage long texts and messages
module MastermindMessage
  SLOT_SYMBOL = "\u25A0".freeze
  PEG_SYMBOL = "\u2022".freeze

  COLORS = %i[red green blue yellow cyan white
              tomato orange magenta aqua lime violet].freeze
  CLR_CHAR = %w[r g b y c w t o m a l v].freeze
  COLORS_PER_ROW = 6

  def pegs_guide_text
    gray_head   = Rainbow("1. Gray pegs #{PEG_SYMBOL}").darkslategray
    white_head  = Rainbow("2. White pegs #{PEG_SYMBOL}").white
    orange_head = Rainbow("3. Orange pegs #{PEG_SYMBOL}").orange

    prompt     = ' - After each guess, there is a row of small pegs whose ' \
                 "color indicates how good your guess is:\n"
    gray_peg   = "   #{gray_head} means that one of your colors isn't correct\n"
    white_peg  = "   #{white_head} means that one of your colors is correct, " \
                 "though its position isn't\n"
    orange_peg = "   #{orange_head} means that one of your colors is correct" \
                 ", so is its position\n"
    prompt + gray_peg + white_peg + orange_peg
  end

  def available_colors_text(number_of_colors)
    available_colors = ''

    number_of_colors.times do |index|
      color_symbol = COLORS[index]
      color_tag = Rainbow("#{color_symbol} #{SLOT_SYMBOL}").color(color_symbol)

      indent = '      '
      indent = "\t" if (index % COLORS_PER_ROW).zero?

      available_colors += indent + color_tag.to_s
      available_colors += "\n" if index % COLORS_PER_ROW == COLORS_PER_ROW - 1
    end

    available_colors
  end

  def input_guide_text
    ' - For each of these colors, you should write your guess with ' \
      "their first alphabet character.\nFor example, 'rgbcwy' means " \
      "'red-green-blue-cyan-white-yellow'.\n"
  end

  def colors_guide_text(width, number_of_colors)
    general = " - You must find #{width} colors, each color is chosen " \
              "from these #{number_of_colors} choices of colors, namely:\n"
    bonus = " - You can choose one color multiple times for different slots.\n"
    general + available_colors_text(number_of_colors) + bonus
  end

  def guide_text(width, number_of_colors)
    goal = " - You need to guess correctly #{width} colors in a row."
    pegs = pegs_guide_text
    colors = colors_guide_text(width, number_of_colors)
    input = input_guide_text
    navigation = "\n\nPress Enter to continue...\n"

    goal + pegs + colors + input + navigation
  end

  def input_prompt_text
    'Type your guess here: '
  end

  def guess_text(guess)
    row = "\t"
    guess.each do |index|
      color_symb = COLORS[index]
      row += "#{Rainbow(SLOT_SYMBOL).color(color_symb)} "
      row += "#{Rainbow(SLOT_SYMBOL).color(color_symb)}   "
    end
    row += '  '
  end

  def pegs_text(interpreted_pegs)
    text = ''
    interpreted_pegs.each do |color|
      text += Rainbow(PEG_SYMBOL).darkslategray if color.nil?
      text += Rainbow(PEG_SYMBOL).white if !color.nil? && color.zero?
      text += Rainbow(PEG_SYMBOL).orange if color == 1
    end
    text += "\n"
  end

  def history_text(guesses, pegs)
    hist = ''
    guesses.each_with_index do |guess, index|
      guess_text = guess_text(guess)
      pegs_text = pegs_text(pegs[index])
      hist += "\n#{guess_text + pegs_text + guess_text}\n"
    end
    hist
  end

  def error_text(error, width)
    perr = Rainbow(' ! <Error>').color(:crimson)

    case error.to_s
    when 'invalid width'
      "#{perr} Your guess must be #{width} wide!"
    when 'invalid color'
      "#{perr} Only colors listed above are valid!"
    else
      "#{perr} Some errors have occured!"
    end
  end

  def result_text(result)
    win_text = Rainbow("\tGeez... You won!\n").color(:gold)
    lose_text = Rainbow("\tAhha... Loser!\n").color(:red)

    result ? win_text : lose_text
  end

  def right_answer_text(code)
    prompt = Rainbow(' - The real answer is here...').color(:gold)
    half_row = guess_text(code)
    "\n#{prompt}\n\n#{half_row}\n#{half_row}"
  end
end

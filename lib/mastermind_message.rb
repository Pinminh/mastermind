require 'rainbow/refinement'

# Manage long texts and messages
module MastermindMessage
  SLOT_SYMBOL = "\u25A0".freeze
  PEG_SYMBOL = "\u2022".freeze

  COLORS = %i[red green darkblue yellow cyan white tomato orange magenta].freeze
  CLR_CHAR = %w[r g d y c w t o m].freeze
  ROW_COLS = 6

  def role_guide_text
    'In this game, you can play as guesser or as code creator. ' \
      'In the latter case, game bot will be the guesser instead.'
  end

  def input_role_prompt_text
    role_text = ' ? Do you want to be code creator (let the bot guess)? ' \
                'Type yes (y) or no (n): '
    Rainbow(role_text).gold
  end

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
      indent = "\t" if (index % ROW_COLS).zero?

      available_colors += indent + color_tag.to_s
      available_colors += "\n" if index % ROW_COLS == ROW_COLS - 1
    end

    available_colors += "\n" if (number_of_colors - 1) % ROW_COLS == ROW_COLS - 1
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
    bonus = "\n - You can choose one color multiple times for different slots.\n"
    general + available_colors_text(number_of_colors) + bonus
  end

  def guide_text(width, number_of_colors)
    goal = " - You need to guess correctly #{width} colors in a row."
    pegs = pegs_guide_text
    colors = colors_guide_text(width, number_of_colors)
    input = input_guide_text

    "#{goal + pegs + colors}\n#{input}\n"
  end

  def input_code_prompt_text
    Rainbow(' ? Type your created code here: ').gold
  end

  def input_prompt_text
    Rainbow(' ? Type your guess here: ').gold
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

  def result_text(result, bot_mode)
    win_text = Rainbow('<!Congratulation! You win !>').lime
    lose_text = Rainbow('<! Learn more! You lose !>').crimson

    if bot_mode
      win_text = Rainbow('<! Bot beat you! Bot win !>').crimson
      lose_text = Rainbow('<! Congratulation! Bot lose !>').lime
    end

    "\t <#{result ? win_text : lose_text}>\n"
  end

  def right_answer_text(code)
    prompt = Rainbow(' ! The real answer is here...').gold
    half_row = guess_text(code)
    "\n#{prompt}\n\n#{half_row}\n#{half_row}"
  end
end

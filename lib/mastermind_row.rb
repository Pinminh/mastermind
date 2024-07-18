# Manage data interactions corresponding each guessing row
class MastermindRow
  MAX_WIDTH = 12
  MAX_COLOR = 12

  attr_reader :width, :number_of_colors

  def initialize(width = 4, number_of_colors = 6)
    width = 4 unless MastermindRow.accept_width?(width)
    number_of_colors = 6 unless MastermindRow.accept_max_color?(number_of_colors)

    @width = width
    @number_of_colors = number_of_colors

    @guess = Array.new(@width)
  end

  def self.accept_width?(width)
    return false unless width.is_a?(Integer) && width.positive?

    width <= MastermindRow::MAX_WIDTH
  end

  def self.accept_max_color?(max_color)
    return false unless max_color.is_a?(Integer) && max_color.positive?

    max_color <= MastermindRow::MAX_COLOR
  end

  def accept_position?(position)
    position >= 0 && position < @width
  end

  def accept_color?(color)
    return false unless color.is_a?(Integer)

    color >= 0 && color < @number_of_colors
  end

  def accept_guess?(guess)
    return false unless guess.is_a?(Array) && guess.length == @width

    guess.each do |color|
      return false unless accept_color?(color)
    end

    true
  end

  def guess
    @guess.clone
  end

  def unfinished_guess?
    @guess.include?(nil)
  end

  def reconfigure(width = 4, number_of_colors = 6)
    return false unless accept_width?(width)
    return false unless accept_max_color?(number_of_colors)

    @guess = Array.new(@width) if width != @width || number_of_colors != @number_of_colors

    @width = width
    @number_of_colors = number_of_colors
    true
  end

  def write_color_at(position, color)
    return false unless accept_position?(position) && accept_color?(color)

    @guess[position] = color
    true
  end

  def erase_color_at(position)
    return nil unless accept_position?(position)

    erased_value = @guess[position]
    @guess[position] = nil
    erased_value
  end

  def put_guess(guess)
    return false unless accept_guess?(guess)

    @guess = guess
  end

  def reset_guess
    @guess = Array.new(@width)
  end
end

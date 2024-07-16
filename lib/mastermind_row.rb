class MastermindRow
  attr_reader :width, :number_of_colors

  def initialize(width = 4, number_of_colors = 6)
    @width = width
    @number_of_colors = number_of_colors
    @truth_code = nil

    @guess = Array.new(@width)
    @feedback = Array.new(@width)
  end

  def accept_code?(code)
    return false if code.length != @width

    code.each do |color|
      return false unless color.is_a?(Integer)
      return false if color.negative? || color >= number_of_colors
    end

    true
  end

  def accept_position?(position)
    position >= 0 && position < @width
  end

  def accept_color?(color)
    return false unless color.is_a?(Integer)

    color >= 0 && color < number_of_colors
  end

  def clear_row
    @guess.map! { nil }
    @feedback.map! { nil }
    nil
  end

  def change_code(new_code)
    return false unless accept_code?(new_code)

    @truth_code = new_code
    true
  end

  def reconfigure(width = 4, number_of_colors = 6)
    @width = width
    @number_of_colors = number_of_colors
    @truth_code = nil

    @guess = Array.new(@width)
    @feedback = Array.new(@width)
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

  def update_feedback
    return false if @guess.include?(nil)

    @guess.each_with_index do |color, index|
      @feedback[index] = @truth_code.include?(color) ? 0 : nil
      @feedback[index] = 1 if color == @truth_code[index]
    end

    @feedback.shuffle!
    true
  end
end

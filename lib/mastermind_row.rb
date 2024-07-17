# Manage data interactions corresponding each guessing row
class MastermindRow
  attr_reader :width, :number_of_colors

  def initialize(width = 4, number_of_colors = 6)
    @width = width
    @number_of_colors = number_of_colors
    @truth_code = nil

    @guess = Array.new(@width)
    @feedback = Array.new(@width)
  end

  def reconfigure(width = 4, number_of_colors = 6)
    return false unless width.is_a?(Integer) && number_of_colors.is_a?(Integer)
    return false unless width.positive? && number_of_colors.positive?

    if width != @width || number_of_colors != @number_of_colors
      @guess = Array.new(@width)
      @feedback = Array.new(@width)
      @truth_code = nil
    end

    @width = width
    @number_of_colors = number_of_colors
    true
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

  def update_absolute_feedback(truth_code)
    @guess.each_with_index do |guess_color, index|
      next unless guess_color == truth_code[index]

      truth_code[index] = nil
      @feedback[index] = 1
    end
  end

  def update_relative_feedback(truth_code)
    @guess.length.times do |index|
      next if truth_code[index].nil?

      truth_index = truth_code.find_index(@guess[index])
      @feedback[index] = truth_index ? 0 : nil
      truth_code[truth_index] = -1 if truth_index
    end
  end

  def update_feedback
    return false if @guess.include?(nil)

    @feedback.map! { nil }
    truth_code = @truth_code.map(&:clone)

    update_absolute_feedback(truth_code)
    update_relative_feedback(truth_code)

    @feedback.shuffle!
    true
  end

  def feedback
    @feedback.map(&:clone)
  end

  def correct_guess?
    raise 'incomplete guess' unless update_feedback

    @feedback.each { |peg| return false unless peg == 1 }
    true
  end

  def reset_guess
    @guess = Array.new(@width)
    @feedback = Array.new(@width)
  end
end

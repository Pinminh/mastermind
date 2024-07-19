require_relative 'lib/mastermind_game'

num_slots = 4
num_colors = 9
num_turns = 6

game = MastermindGame.new(num_slots, num_colors, num_turns)

game.play_cli

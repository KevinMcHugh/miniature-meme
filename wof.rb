require 'faker'
require 'pry'
class Wheel
  attr_reader :value
  def initialize
    @value = 0
  end
  def spin
    # todo: jackpot, lose_a_turn, :free_spin
    @spaces ||= [3500, 300, 600, :bankrupt, 800, 550, 400, 300, 900, 500, 900, :bankrupt, 600, 400, 300, 800, 350, 450, 700, 300, 600]
    @value = @spaces.sample
  end
end
class Player
  attr_reader :name, :brain, :wheel, :money
  def initialize(brain, wheel, name=nil)
    @name = name || Faker::Name.name
    @money = 0
    @brain = brain
    @wheel = wheel
  end
  def take_turn(puzzle)
    choice = brain.choose(puzzle)
    puts "#{@name} has chosen to #{choice}!"
    if choice == 'solve'
      brain.solve(puzzle)
    else
      pick_letter(puzzle, choice)
    end
  end

  def add(amount)
    @money += amount
    puts "#{name}: You have a total of $#{money}"
  end

  def pick_letter(puzzle, choice)
    if choice == 'spin'
      spin_value = wheel.spin
      puts "Ticktickticktick \ntick tick tick tick \ntick   tick    tick    tick"
      if spin_value.is_a? Numeric
        puts "#{@name} has spun a #{spin_value}!"
        brain.pick_letter(puzzle)
      elsif spin_value == :bankrupt
        puts "BANKRUPT! #{@name} is bankrupt!!!"
        @money = 0
        nil
      end
    elsif choice == 'buy'
      brain.pick_letter(puzzle)
    end
  end
end
class AIBrain
  def choose(puzzle)
    'spin'
  end

  def pick_letter(puzzle)
    (consonants - puzzle.guessed_letters).sample
  end

  def consonants; 'bcdfghjklmnpqrstvwxyz'.split(''); end
  def solve(puzzle)
    ''
  end
end
class HumanBrain

  def choose(puzzle)
    puts current_state(puzzle)
    choice = 0
    until choice != 0
      puts 'You can:'
      puts '1) spin,'
      puts '2) buy a vowel, or'
      puts '3) solve the puzzle'
      choice = input.to_i
    end
    ['spin','buy','solve'][choice - 1]
  end

  def pick_letter(puzzle)
    current_state(puzzle)
    puts 'Please pick a letter'
    input
  end

  def solve(puzzle)
    puts current_state(puzzle)
    puts 'You clear your throat. Shakily, as though from another body, you hear yourself say:'
    puts "I'd like to solve the puzzle, Pat."
    input
  end

  def current_state(puzzle)
    "The puzzle is currently: #{puzzle.puzzle.upcase}"
  end

  def input
    inp = gets
    inp.downcase.chomp
  end
end
class Game
  attr_reader :puzzle, :wheel, :players
  def initialize(name=nil)
    @puzzle = Puzzle.new
    @wheel  = Wheel.new
    ai = AIBrain.new
    human = HumanBrain.new
    @players = [Player.new(ai,wheel), Player.new(ai,wheel), Player.new(human,wheel, name)]
  end

  def vowels; ['a','e','i','o','u']; end

  def play
    puts "Lets's welcome tonight's players: #{players.map(&:name)}!"
    previous_player = nil
    while true
      players.each do |player|
        take_next_turn = true
        while take_next_turn
          puts player_start_turn_message(player, previous_player)
          choice = player.take_turn(puzzle)
          if choice
            if puzzle.solved_by?(choice)
              end_game(player)
              return player
            end
            if choice.length == 1
              take_next_turn = give_or_take_money(player, choice)
              previous_player = player
            else
              take_next_turn = false
              puts "Sorry, #{player.name}, #{choice} is incorrect."
            end
          else
            take_next_turn = false
          end
        end
      end
    end
  end

  def player_start_turn_message(player, previous_player)
    player == previous_player ? "#{player.name} gets to go again!" : "Alright, time for #{player.name}!"
  end

  def give_or_take_money(player, choice)
    puts "Are there any #{choice}s?"
    letters_revealed = puzzle.reveal(choice)
    puts "There are #{letters_revealed} #{choice}s!"
    if vowels.include?(choice)
      value = -250 * letters_revealed
    else
      value = letters_revealed * wheel.value
    end
    if !value.zero?
      puts "So that will #{value > 0 ? 'earn' : 'cost'} #{player.name} $#{value}"
      player.add(value)
    end

    letters_revealed > 0
  end

  def end_game(winner)
    @winner = winner
    puts "That's correct! Congratulations, #{winner.name}, you've won!"
    puts "Here's all the scores for tonight's game:"
    players.each do |player|
      puts "#{player.name}: scored #{player.money}!"
    end
  end
end
class Puzzle
  attr_reader :revealed_letters, :guessed_letters
  def initialize
    @revealed_letters = []
    @guessed_letters  = []
    @puzzle = Faker::Company.catch_phrase.downcase
  end

  def solved_by?(guess)
    @puzzle == guess&.downcase
  end

  def reveal(letter)
    @guessed_letters << letter
    count = 0
    if !revealed_letters.include?(letter)
      count = @puzzle.scan(letter).count
      revealed_letters << letter
    end
    count
  end

  def puzzle
    @puzzle.gsub(' ', '&').gsub(/[#{unrevealed}]/, '*').gsub('&', ' ')
  end

  private
  def unrevealed
    @puzzle.split('') - revealed_letters
  end
end
puts 'Enter your name:'
name = gets.chomp
game = Game.new(name)
game.play

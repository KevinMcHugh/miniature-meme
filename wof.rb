require 'pp'
require 'pry'
class Wheel
  attr_reader :value
  def initialize
    @value = 0
  end
  def spin
    @value = (0..10).to_a.sample
  end
end
class Player
  attr_reader :brain, :wheel, :money
  def initialize(brain, wheel)
    @name = Random.rand
    @money = 0
    @brain = brain
    @wheel = wheel
  end
  def take_turn(puzzle)
    choice = brain.choose(puzzle)
    if choice == 'solve'
      brain.solve(puzzle)
    else
      if choice == 'spin'
        wheel.spin
      end
      brain.pick_letter(puzzle)
    end
  end

  def deduct(amount)
    @money -= amount
  end
  def add(amount)
    @money += amount
  end
end
class AIBrain
  attr_reader :count
  def initialize
    @count = -1
  end

  def choose(puzzle)
    @count += 1
    if count > 2
      'solve'
    else
      'spin'
    end
  end

  def pick_letter(puzzle)
    if count == 0
      'l'
    elsif count == 1
      'r'
    else
      'a'
    end
  end

  def solve(puzzle)
    'Fartzilla'
  end
end
class Game
  attr_reader :puzzle, :wheel, :players
  def initialize
    @puzzle = Puzzle.new
    @wheel  = Wheel.new
    ai = AIBrain.new
    @players = [Player.new(ai,wheel), Player.new(ai,wheel), Player.new(ai,wheel)]
  end

  def vowels; ['a','e','i','o','u']; end

  def play
    while true
      players.each do |player|
        puts puzzle.puzzle

        take_next_turn = true
        while take_next_turn
          choice = player.take_turn(puzzle)
          puts choice.to_s
          return player if puzzle.solved_by?(choice)
          take_next_turn = give_or_take_money(player, choice)
        end
      end
    end
  end

  def give_or_take_money(player, choice)
    letters_revealed = puzzle.reveal(choice)
    if vowels.include?(choice)
      player.deduct(letters_revealed * 2)
    else
      player.add(letters_revealed * wheel.value)
    end
    letters_revealed > 0
  end
end
class Puzzle
  attr_reader :revealed_letters
  def initialize
    @revealed_letters = []
    @guessed_letters  = []
    @puzzle = 'Fartzilla'
  end

  def solved_by?(guess)
    @puzzle == guess
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
    @puzzle.gsub(/[#{unrevealed}]/, '*')
  end

  private
  def unrevealed
    @puzzle.split('') - revealed_letters
  end
end
game = Game.new
game.play
puts game.players.map { |p| p.money }

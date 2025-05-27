# snake_game.cr
# Author: Sanne Karibo
# Simple terminal Snake Game in Crystal

require "io/console"

WIDTH = 64
HEIGHT = 24
MAX_LENGTH = 100

Point = Tuple(Int32, Int32)

class SnakeGame
  def initialize
    @snake = (0...5).map { |i| {20 - i, 10} }
    @dir = 1 # 1=right,2=down,3=left,4=up
    @score = 0
    @game_over = false
    generate_food
  end

  def generate_food
    loop do
      @food = {rand(WIDTH), rand(HEIGHT)}
      break unless @snake.includes?(@food)
    end
  end

  def clear_screen
    print "\e[2J\e[H"
  end

  def draw
    clear_screen
    puts "Score: #{@score}"
    HEIGHT.times do |y|
      WIDTH.times do |x|
        pos = {x, y}
        if pos == @snake[0]
          print "O"
        elsif @snake.includes?(pos)
          print "o"
        elsif pos == @food
          print "X"
        else
          print " "
        end
      end
      puts
    end
  end

  def move_snake
    return if @game_over
    head = @snake[0]
    new_head = case @dir
               when 1 then {head[0] + 1, head[1]}
               when 2 then {head[0], head[1] + 1}
               when 3 then {head[0] - 1, head[1]}
               when 4 then {head[0], head[1] - 1}
               else head
               end

    if new_head[0] < 0 || new_head[0] >= WIDTH || new_head[1] < 0 || new_head[1] >= HEIGHT || @snake.includes?(new_head)
      @game_over = true
      return
    end

    @snake.unshift(new_head)
    if new_head == @food
      @score += 10
      generate_food
      @snake = @snake.take(MAX_LENGTH)
    else
      @snake.pop
    end
  end

  def run
    puts "Snake Game - Created by Sanne Karibo"
    puts "Use WASD keys + Enter to move. Press Enter to start..."
    STDIN.gets

    until @game_over
      draw
      if IO.select([STDIN], [], [], 0.15)
        input = STDIN.gets.strip.downcase
        case input
        when "d"
          @dir = 1 if @dir != 3
        when "s"
          @dir = 2 if @dir != 4
        when "a"
          @dir = 3 if @dir != 1
        when "w"
          @dir = 4 if @dir != 2
        end
      end
      move_snake
    end

    draw
    puts "Game Over! Final Score: #{@score}"
    puts "Press Enter to exit..."
    STDIN.gets
  end
end

SnakeGame.new.run

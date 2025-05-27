# snake_game.exs
# Author: Sanne Karibo
# Terminal snake game in Elixir

defmodule SnakeGame do
  @width 64
  @height 24
  @max_length 100

  defstruct snake: [], dir: :right, food: {0, 0}, score: 0, game_over: false

  def start do
    snake = Enum.map(0..4, fn i -> {20 - i, 10} end)
    food = generate_food(snake)
    game = %__MODULE__{snake: snake, food: food}
    IO.puts "Snake Game - Created by Sanne Karibo"
    IO.puts "Use WASD keys to move. Press Enter to start..."
    IO.gets("")

    loop(game)
  end

  defp loop(%{game_over: true, score: score}) do
    IO.puts "Game Over! Final Score: #{score}"
  end

  defp loop(game) do
    draw(game)
    input = IO.gets("") |> String.trim()
    game = update_direction(game, input)
    game = move_snake(game)
    :timer.sleep(150)
    loop(game)
  end

  defp generate_food(snake) do
    food = { :rand.uniform(@width) - 1, :rand.uniform(@height) - 1 }
    if food in snake do
      generate_food(snake)
    else
      food
    end
  end

  defp update_direction(game, input) do
    dir = game.dir
    cond do
      input == "d" and dir != :left -> %{game | dir: :right}
      input == "s" and dir != :up -> %{game | dir: :down}
      input == "a" and dir != :right -> %{game | dir: :left}
      input == "w" and dir != :down -> %{game | dir: :up}
      true -> game
    end
  end

  defp move_snake(%{game_over: true} = game), do: game

  defp move_snake(game) do
    [{hx, hy} | _] = game.snake
    new_head = case game.dir do
      :right -> {hx + 1, hy}
      :down -> {hx, hy + 1}
      :left -> {hx - 1, hy}
      :up -> {hx, hy - 1}
    end

    cond do
      out_of_bounds?(new_head) or new_head in game.snake ->
        %{game | game_over: true}

      new_head == game.food ->
        new_snake = [new_head | game.snake]
        new_food = generate_food(new_snake)
        %{game | snake: new_snake, food: new_food, score: game.score + 10}

      true ->
        new_snake = [new_head | Enum.slice(game.snake, 0..-2)]
        %{game | snake: new_snake}
    end
  end

  defp out_of_bounds?({x, y}) do
    x < 0 or x >= @width or y < 0 or y >= @height
  end

  defp draw(game) do
    IO.write("\e[H\e[2J") # clear screen
    IO.puts("Score: #{game.score}")
    for y <- 0..(@height - 1) do
      row =
        for x <- 0..(@width - 1) do
          cond do
            {x, y} == hd(game.snake) -> "O"
            {x, y} in tl(game.snake) -> "o"
            {x, y} == game.food -> "X"
            true -> " "
          end
        end
        |> Enum.join("")
      IO.puts(row)
    end
  end
end

SnakeGame.start()

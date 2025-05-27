# snake_game.nim
# Author: Sanne Karibo
# Simple console Snake Game in Nim

import os, terminal, strutils, times, random

const
  width = 64
  height = 24
  maxLength = 100

type
  Point = object
    x, y: int

var
  snake: array[0..maxLength-1, Point]
  length = 5
  dir = 1  # 1=right,2=down,3=left,4=up
  food: Point
  score = 0
  gameOver = false

proc clearScreen() =
  stdout.write("\x1b[2J\x1b[H")

proc generateFood() =
  while true:
    food.x = rand(width)
    food.y = rand(height)
    var collide = false
    for i in 0..<length:
      if snake[i] == food:
        collide = true
        break
    if not collide: break

proc draw() =
  clearScreen()
  echo "Score: ", score
  for y in 0..<height:
    for x in 0..<width:
      var printed = false
      for i in 0..<length:
        if snake[i].x == x and snake[i].y == y:
          if i == 0:
            stdout.write("O")
          else:
            stdout.write("o")
          printed = true
          break
      if not printed:
        if food.x == x and food.y == y:
          stdout.write("X")
        else:
          stdout.write(" ")
    stdout.write("\n")

proc moveSnake() =
  if gameOver: return
  var newHead = snake[0]
  case dir:
  of 1: newHead.x += 1
  of 2: newHead.y += 1
  of 3: newHead.x -= 1
  of 4: newHead.y -= 1

  if newHead.x < 0 or newHead.x >= width or newHead.y < 0 or newHead.y >= height:
    gameOver = true
    return

  for i in 0..<length:
    if snake[i] == newHead:
      gameOver = true
      return

  # Shift snake body
  for i in countdown(length-1, 1):
    snake[i] = snake[i-1]

  snake[0] = newHead

  if newHead == food:
    if length < maxLength:
      length.inc()
      snake[length-1] = snake[length-2]
    score += 10
    generateFood()

proc readKey(): char =
  let oldEcho = terminal.getEcho()
  let oldRaw = terminal.getRaw()
  terminal.setEcho(false)
  terminal.setRaw(true)
  var c = stdin.readChar()
  terminal.setEcho(oldEcho)
  terminal.setRaw(oldRaw)
  return c

proc main() =
  # Initialize snake
  for i in 0..<length:
    snake[i] = Point(x: 20 - i, y: 10)
  generateFood()
  clearScreen()
  echo "Snake Game - Created by Sanne Karibo"
  echo "Use WASD keys to move. Press 'q' to quit. Press any key to start..."
  discard readKey()

  while not gameOver:
    draw()
    if stdin.ready():
      let c = readKey()
      case c:
      of 'd': if dir != 3: dir = 1
      of 's': if dir != 4: dir = 2
      of 'a': if dir != 1: dir = 3
      of 'w': if dir != 2: dir = 4
      of 'q': gameOver = true
      else: discard
    moveSnake()
    sleep(100)

  draw()
  echo "Game Over! Final Score: ", score

when isMainModule:
  main()

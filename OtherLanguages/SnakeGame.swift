//
// SnakeGame.swift
// Author: Sanne Karibo
// Simple console Snake game in Swift
//

import Foundation

let width = 64
let height = 24
let maxLength = 100

enum Direction: Int {
    case right = 1, down, left, up
}

struct Point: Equatable {
    var x: Int
    var y: Int
}

class SnakeGame {
    var snake: [Point] = []
    var direction: Direction = .right
    var food: Point
    var score = 0
    var gameOver = false

    init() {
        // Initialize snake in the middle
        for i in 0..<5 {
            snake.append(Point(x: 20 - i, y: 10))
        }
        food = Point(x: Int.random(in: 0..<width), y: Int.random(in: 0..<height))
    }

    func generateFood() {
        food = Point(x: Int.random(in: 0..<width), y: Int.random(in: 0..<height))
        while snake.contains(food) {
            food = Point(x: Int.random(in: 0..<width), y: Int.random(in: 0..<height))
        }
    }

    func moveSnake() {
        guard !gameOver else { return }
        var newHead = snake[0]
        switch direction {
        case .right: newHead.x += 1
        case .down: newHead.y += 1
        case .left: newHead.x -= 1
        case .up: newHead.y -= 1
        }

        // Check collisions
        if newHead.x < 0 || newHead.x >= width || newHead.y < 0 || newHead.y >= height {
            gameOver = true
            return
        }
        if snake.contains(newHead) {
            gameOver = true
            return
        }

        snake.insert(newHead, at: 0)

        if newHead == food {
            score += 10
            generateFood()
        } else {
            snake.removeLast()
        }
    }

    func draw() {
        var grid = Array(repeating: Array(repeating: " ", count: width), count: height)

        for p in snake {
            if p == snake[0] {
                grid[p.y][p.x] = "O" // Head
            } else {
                grid[p.y][p.x] = "o" // Body
            }
        }
        grid[food.y][food.x] = "X"

        print("\u{001B}[2J") // Clear screen

        print("Score: \(score)")
        for row in grid {
            print(row.joined())
        }
        if gameOver {
            print("\nGame Over! Final Score: \(score)")
            print("Press Enter to exit...")
        }
    }

    func start() {
        print("Snake Game - Created by Sanne Karibo")
        print("Use WASD keys to move. Press Enter to start...")
        _ = readLine()

        while !gameOver {
            draw()

            // Non-blocking input hack: just blocking for simplicity
            if let input = readLine() {
                switch input.lowercased() {
                case "d": if direction != .left { direction = .right }
                case "s": if direction != .up { direction = .down }
                case "a": if direction != .right { direction = .left }
                case "w": if direction != .down { direction = .up }
                default: break
                }
            }

            moveSnake()

            usleep(150_000) // 150ms delay
        }
        draw()
        _ = readLine()
    }
}

let game = SnakeGame()
game.start()

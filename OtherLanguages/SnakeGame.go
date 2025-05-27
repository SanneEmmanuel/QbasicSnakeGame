// snake_game.go
// Author: Sanne Karibo
// Simple terminal Snake game in Go

package main

import (
	"bufio"
	"fmt"
	"math/rand"
	"os"
	"os/exec"
	"runtime"
	"time"
)

const (
	width     = 64
	height    = 24
	maxLength = 100
)

type Point struct {
	x, y int
}

type Game struct {
	snake    []Point
	dir      int // 1=right,2=down,3=left,4=up
	food     Point
	score    int
	gameOver bool
}

func clearScreen() {
	switch runtime.GOOS {
	case "windows":
		cmd := exec.Command("cmd", "/c", "cls")
		cmd.Stdout = os.Stdout
		cmd.Run()
	default:
		fmt.Print("\033[2J\033[H")
	}
}

func (g *Game) init() {
	for i := 0; i < 5; i++ {
		g.snake = append(g.snake, Point{20 - i, 10})
	}
	g.dir = 1
	g.generateFood()
}

func (g *Game) generateFood() {
	rand.Seed(time.Now().UnixNano())
	for {
		x := rand.Intn(width)
		y := rand.Intn(height)
		if !g.contains(x, y) {
			g.food = Point{x, y}
			break
		}
	}
}

func (g *Game) contains(x, y int) bool {
	for _, p := range g.snake {
		if p.x == x && p.y == y {
			return true
		}
	}
	return false
}

func (g *Game) moveSnake() {
	head := g.snake[0]
	var newHead Point
	switch g.dir {
	case 1:
		newHead = Point{head.x + 1, head.y}
	case 2:
		newHead = Point{head.x, head.y + 1}
	case 3:
		newHead = Point{head.x - 1, head.y}
	case 4:
		newHead = Point{head.x, head.y - 1}
	}

	if newHead.x < 0 || newHead.x >= width || newHead.y < 0 || newHead.y >= height {
		g.gameOver = true
		return
	}
	if g.contains(newHead.x, newHead.y) {
		g.gameOver = true
		return
	}

	g.snake = append([]Point{newHead}, g.snake...)

	if newHead == g.food {
		g.score += 10
		g.generateFood()
		if len(g.snake) > maxLength {
			g.snake = g.snake[:maxLength]
		}
	} else {
		g.snake = g.snake[:len(g.snake)-1]
	}
}

func (g *Game) draw() {
	clearScreen()
	fmt.Printf("Score: %d\n", g.score)

	grid := make([][]rune, height)
	for i := range grid {
		grid[i] = make([]rune, width)
		for j := range grid[i] {
			grid[i][j] = ' '
		}
	}

	for i, p := range g.snake {
		if i == 0 {
			grid[p.y][p.x] = 'O'
		} else {
			grid[p.y][p.x] = 'o'
		}
	}
	grid[g.food.y][g.food.x] = 'X'

	for _, row := range grid {
		fmt.Println(string(row))
	}
}

func main() {
	game := Game{}
	game.init()

	reader := bufio.NewReader(os.Stdin)

	fmt.Println("Snake Game - Created by Sanne Karibo")
	fmt.Println("Use WASD keys + Enter to move. Press Enter to start...")
	reader.ReadString('\n')

	for !game.gameOver {
		game.draw()

		// Read user input for direction
		input, _ := reader.ReadString('\n')
		switch input {
		case "d\n", "D\n":
			if game.dir != 3 {
				game.dir = 1
			}
		case "s\n", "S\n":
			if game.dir != 4 {
				game.dir = 2
			}
		case "a\n", "A\n":
			if game.dir != 1 {
				game.dir = 3
			}
		case "w\n", "W\n":
			if game.dir != 2 {
				game.dir = 4
			}
		}

		game.moveSnake()
		time.Sleep(150 * time.Millisecond)
	}

	game.draw()
	fmt.Println("Game Over! Final Score:", game.score)
	fmt.Println("Press Enter to exit...")
	reader.ReadString('\n')
}

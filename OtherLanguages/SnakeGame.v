// Snake Game in V
// Author: Sanne Karibo
// Enhanced with score tracking and improved gameplay

import time
import term
import rand

const (
    width = 64
    height = 48
    max_length = 100
)

struct Game {
mut:
    x         []int = []int{len: max_length, init: 0}
    y         []int = []int{len: max_length, init: 0}
    length    int = 5
    dir       int = 1 // 1=Right,2=Down,3=Left,4=Up
    food_x    int
    food_y    int
    game_over bool = false
    score     int = 0
}

fn main() {
    mut game := Game{}
    term.clear()
    show_prescreen()

    game.init_snake()
    game.generate_food()

    for !game.game_over {
        term.clear()
        game.draw_score()
        game.draw_snake()
        game.draw_food()

        game.handle_input()
        game.move_snake()
        game.check_collision()

        time.sleep_ms(100)
    }

    term.clear()
    println(term.bold(term.red('Game Over!')))
    println('Final Score: $game.score')
    println('Press Enter to exit...')
    _ := os.input('') // wait for Enter key
}

fn show_prescreen() {
    term.clear()
    println(term.bold(term.yellow('Snake Game')))
    println('Created by Sanne Karibo')
    println('Press Enter to start...')
    _ := os.input('')
}

fn (mut g Game) init_snake() {
    for i in 0 .. g.length {
        g.x[i] = 20 - i
        g.y[i] = 10
    }
}

fn (mut g Game) draw_score() {
    println('Score: $g.score\n')
}

fn (g Game) draw_snake() {
    mut screen := [][]string{len: height, init: []string{len: width, init: ' '}}
    // Draw snake body
    for i in 0 .. g.length {
        if i == 0 {
            screen[g.y[i]][g.x[i]] = 'O' // head
        } else {
            screen[g.y[i]][g.x[i]] = 'o' // body
        }
    }

    // Render screen
    for row in screen {
        println(row.join(''))
    }
}

fn (g Game) draw_food() {
    // Food is displayed as 'X' on the screen
    // Because we redraw entire screen in draw_snake(), just print food position below
    println('\nFood: ( $g.food_x , $g.food_y )')
}

fn (mut g Game) generate_food() {
    g.food_x = rand.intn(width)
    g.food_y = rand.intn(height)
}

fn (mut g Game) move_snake() {
    // Move body
    for i := g.length - 1; i > 0; i-- {
        g.x[i] = g.x[i - 1]
        g.y[i] = g.y[i - 1]
    }

    // Move head
    match g.dir {
        1 { g.x[0]++ }
        2 { g.y[0]++ }
        3 { g.x[0]-- }
        4 { g.y[0]-- }
        else {}
    }

    // Check food collision
    if g.x[0] == g.food_x && g.y[0] == g.food_y {
        if g.length < max_length {
            g.length++
            g.x[g.length - 1] = g.x[g.length - 2]
            g.y[g.length - 1] = g.y[g.length - 2]
        }
        g.score += 10
        g.generate_food()
    }
}

fn (mut g Game) check_collision() {
    // Check wall collision
    if g.x[0] < 0 || g.x[0] >= width || g.y[0] < 0 || g.y[0] >= height {
        g.game_over = true
    }

    // Check self collision
    for i in 1 .. g.length {
        if g.x[0] == g.x[i] && g.y[0] == g.y[i] {
            g.game_over = true
            break
        }
    }
}

fn (mut g Game) handle_input() {
    if term.kbhit() {
        key := term.read_key()

        match key {
            .arrow_right { if g.dir != 3 { g.dir = 1 } }
            .arrow_down { if g.dir != 4 { g.dir = 2 } }
            .arrow_left { if g.dir != 1 { g.dir = 3 } }
            .arrow_up { if g.dir != 2 { g.dir = 4 } }
            else {}
        }
    }
}

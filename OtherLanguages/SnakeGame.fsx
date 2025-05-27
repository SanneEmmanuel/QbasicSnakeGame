// SnakeGame.fsx
// Author: Sanne Karibo
// Console snake game in F#

open System

let width = 64
let height = 24
let maxLength = 100

type Point = { x: int; y: int }

type Direction =
    | Right = 1
    | Down = 2
    | Left = 3
    | Up = 4

type Game = {
    mutable snake: Point list
    mutable dir: Direction
    mutable food: Point
    mutable score: int
    mutable gameOver: bool
}

let generateFood (snake: Point list) =
    let rnd = Random()
    let rec loop () =
        let p = { x = rnd.Next(width); y = rnd.Next(height) }
        if List.exists (fun s -> s.x = p.x && s.y = p.y) snake then loop() else p
    loop()

let moveSnake (game: Game) =
    if game.gameOver then () else
    let head = List.head game.snake
    let newHead =
        match game.dir with
        | Direction.Right -> { head with x = head.x + 1 }
        | Direction.Down -> { head with y = head.y + 1 }
        | Direction.Left -> { head with x = head.x - 1 }
        | Direction.Up -> { head with y = head.y - 1 }
        | _ -> head
    if newHead.x < 0 || newHead.x >= width || newHead.y < 0 || newHead.y >= height then
        game.gameOver <- true
    elif List.exists (fun s -> s = newHead) game.snake then
        game.gameOver <- true
    else
        game.snake <- newHead :: (if newHead = game.food then game.snake else List.take (List.length game.snake - 1) game.snake)
        if newHead = game.food then
            game.score <- game.score + 10
            game.food <- generateFood game.snake

let draw (game: Game) =
    Console.Clear()
    printfn "Score: %d" game.score
    for y in 0 .. height - 1 do
        for x in 0 .. width - 1 do
            let p = { x = x; y = y }
            if p = List.head game.snake then
                printf "O"
            elif List.exists (fun s -> s = p) (List.tail game.snake) then
                printf "o"
            elif p = game.food then
                printf "X"
            else
                printf " "
        printfn ""

[<EntryPoint>]
let main argv =
    let initSnake = [ for i in 0 .. 4 -> { x = 20 - i; y = 10 } ]
    let food = generateFood initSnake
    let game = { snake = initSnake; dir = Direction.Right; food = food; score = 0; gameOver = false }

    Console.WriteLine("Snake Game - Created by Sanne Karibo")
    Console.WriteLine("Use WASD keys to move. Press Q to quit.")
    while not game.gameOver do
        draw game
        if Console.KeyAvailable then
            let key = Console.ReadKey(true)
            match key.Key with
            | ConsoleKey.D when game.dir <> Direction.Left -> game.dir <- Direction.Right
            | ConsoleKey.S when game.dir <> Direction.Up -> game.dir <- Direction.Down
            | ConsoleKey.A when game.dir <> Direction.Right -> game.dir <- Direction.Left
            | ConsoleKey.W when game.dir <> Direction.Down -> game.dir <- Direction.Up
            | ConsoleKey.Q -> game.gameOver <- true
            | _ -> ()
        moveSnake game
        System.Threading.Thread.Sleep(150)

    draw game
    Console.WriteLine("Game Over! Final Score: {0}", game.score)
    Console.WriteLine("Press any key to exit...")
    Console.ReadKey() |> ignore
    0

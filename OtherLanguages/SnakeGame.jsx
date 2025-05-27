// SnakeGame.jsx
// Author: Sanne Karibo
// Enhanced with sound effects, score tracking, and improved graphics
import React, { useEffect, useRef, useState } from "react";

const WIDTH = 600;
const HEIGHT = 480;
const DOT_SIZE = 10;
const MAX_LENGTH = 100;

const directions = {
  RIGHT: 1,
  DOWN: 2,
  LEFT: 3,
  UP: 4,
};

const SnakeGame = () => {
  const canvasRef = useRef(null);
  const [snake, setSnake] = useState([
    { x: 200, y: 100 },
    { x: 190, y: 100 },
    { x: 180, y: 100 },
    { x: 170, y: 100 },
    { x: 160, y: 100 },
  ]);
  const [dir, setDir] = useState(directions.RIGHT);
  const [food, setFood] = useState({ x: 0, y: 0 });
  const [gameOver, setGameOver] = useState(false);
  const [score, setScore] = useState(0);

  // Generate random food position aligned to grid
  const generateFood = () => {
    const x = Math.floor(Math.random() * (WIDTH / DOT_SIZE)) * DOT_SIZE;
    const y = Math.floor(Math.random() * (HEIGHT / DOT_SIZE)) * DOT_SIZE;
    return { x, y };
  };

  // Initialize food on mount
  useEffect(() => {
    setFood(generateFood());
  }, []);

  // Handle key presses for direction changes
  useEffect(() => {
    const handleKeyDown = (e) => {
      switch (e.key) {
        case "ArrowRight":
          if (dir !== directions.LEFT) setDir(directions.RIGHT);
          break;
        case "ArrowDown":
          if (dir !== directions.UP) setDir(directions.DOWN);
          break;
        case "ArrowLeft":
          if (dir !== directions.RIGHT) setDir(directions.LEFT);
          break;
        case "ArrowUp":
          if (dir !== directions.DOWN) setDir(directions.UP);
          break;
        default:
          if (gameOver) window.location.reload(); // reload on any key if game over
      }
    };
    window.addEventListener("keydown", handleKeyDown);
    return () => window.removeEventListener("keydown", handleKeyDown);
  }, [dir, gameOver]);

  // Game loop - runs every 100ms
  useEffect(() => {
    if (gameOver) return;

    const interval = setInterval(() => {
      setSnake((prevSnake) => {
        const head = prevSnake[0];
        let newHead;

        switch (dir) {
          case directions.RIGHT:
            newHead = { x: head.x + DOT_SIZE, y: head.y };
            break;
          case directions.DOWN:
            newHead = { x: head.x, y: head.y + DOT_SIZE };
            break;
          case directions.LEFT:
            newHead = { x: head.x - DOT_SIZE, y: head.y };
            break;
          case directions.UP:
            newHead = { x: head.x, y: head.y - DOT_SIZE };
            break;
          default:
            newHead = { ...head };
        }

        // Check collisions with walls
        if (
          newHead.x < 0 ||
          newHead.x >= WIDTH ||
          newHead.y < 0 ||
          newHead.y >= HEIGHT
        ) {
          setGameOver(true);
          return prevSnake;
        }

        // Check collisions with itself
        for (let i = 0; i < prevSnake.length; i++) {
          if (prevSnake[i].x === newHead.x && prevSnake[i].y === newHead.y) {
            setGameOver(true);
            return prevSnake;
          }
        }

        let newSnake = [newHead, ...prevSnake];

        // Check if food eaten
        if (newHead.x === food.x && newHead.y === food.y) {
          setScore((s) => s + 10);
          // Beep sound for eating food (simple beep)
          if (typeof window !== "undefined" && window.AudioContext) {
            const audioCtx = new AudioContext();
            const oscillator = audioCtx.createOscillator();
            oscillator.type = "square";
            oscillator.frequency.setValueAtTime(1000, audioCtx.currentTime);
            oscillator.connect(audioCtx.destination);
            oscillator.start();
            oscillator.stop(audioCtx.currentTime + 0.1);
          }
          setFood(generateFood());
          // Limit length to MAX_LENGTH
          if (newSnake.length > MAX_LENGTH) {
            newSnake = newSnake.slice(0, MAX_LENGTH);
          }
        } else {
          // Remove tail segment if no food eaten
          newSnake.pop();
        }

        return newSnake;
      });
    }, 100);

    return () => clearInterval(interval);
  }, [dir, food, gameOver]);

  // Draw the game
  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;
    const ctx = canvas.getContext("2d");

    // Clear canvas
    ctx.fillStyle = "black";
    ctx.fillRect(0, 0, WIDTH, HEIGHT);

    // Draw score
    ctx.fillStyle = "cyan";
    ctx.font = "16px Arial";
    ctx.fillText("Score: " + score, 10, 20);

    // Draw food as red circle
    ctx.fillStyle = "red";
    ctx.beginPath();
    ctx.arc(food.x + DOT_SIZE / 2, food.y + DOT_SIZE / 2, DOT_SIZE / 2, 0, Math.PI * 2);
    ctx.fill();

    // Draw snake
    // Head bright yellow
    ctx.fillStyle = "yellow";
    const head = snake[0];
    ctx.fillRect(head.x, head.y, DOT_SIZE, DOT_SIZE);

    // Body gradient green
    for (let i = 1; i < snake.length; i++) {
      let greenValue = Math.max(50, 255 - i * 10);
      ctx.fillStyle = `rgb(0, ${greenValue}, 0)`;
      ctx.fillRect(snake[i].x, snake[i].y, DOT_SIZE, DOT_SIZE);
    }

    // If game over, show message
    if (gameOver) {
      ctx.fillStyle = "red";
      ctx.font = "40px Arial";
      ctx.textAlign = "center";
      ctx.fillText("Game Over!", WIDTH / 2, HEIGHT / 2 - 40);
      ctx.font = "24px Arial";
      ctx.fillText("Final Score: " + score, WIDTH / 2, HEIGHT / 2);
      ctx.fillText("Press any key to restart...", WIDTH / 2, HEIGHT / 2 + 40);
    }
  }, [snake, food, score, gameOver]);

  return (
    <div style={{ textAlign: "center", marginTop: 20 }}>
      <h1>Snake Game</h1>
      <h3>Created by Sanne Karibo</h3>
      <canvas ref={canvasRef} width={WIDTH} height={HEIGHT} style={{ border: "1px solid white", backgroundColor: "black" }} />
      {!gameOver && <p>Use arrow keys to control the snake.</p>}
      {gameOver && <p>Press any key to restart.</p>}
    </div>
  );
};

export default SnakeGame;

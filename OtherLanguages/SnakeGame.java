import javax.swing.*;
import java.awt.*;
import java.awt.event.*;
import java.util.Random;

public class SnakeGame extends JPanel implements ActionListener, KeyListener {

    // Constants and game variables
    private static final int WIDTH = 640;
    private static final int HEIGHT = 480;
    private static final int DOT_SIZE = 10;
    private static final int MAX_DOTS = 100;
    private static final int ALL_DOTS = (WIDTH / DOT_SIZE) * (HEIGHT / DOT_SIZE);

    private final int[] x = new int[MAX_DOTS];
    private final int[] y = new int[MAX_DOTS];
    private int length;
    private int dir; // 1=Right, 2=Down, 3=Left, 4=Up
    private int foodX;
    private int foodY;
    private boolean gameOver;
    private int score;

    private Timer timer;
    private Random random;

    // Constructor to setup game
    public SnakeGame() {
        setPreferredSize(new Dimension(WIDTH, HEIGHT));
        setBackground(Color.BLACK);
        setFocusable(true);
        addKeyListener(this);

        random = new Random();
        initGame();
    }

    private void initGame() {
        length = 5;
        dir = 1; // start moving right
        score = 0;
        gameOver = false;

        // Initialize snake position (centered horizontally)
        for (int i = 0; i < length; i++) {
            x[i] = 200 - i * DOT_SIZE;
            y[i] = 100;
        }

        locateFood();

        timer = new Timer(100, this); // update every 100 ms
        timer.start();
    }

    private void locateFood() {
        foodX = random.nextInt(WIDTH / DOT_SIZE) * DOT_SIZE;
        foodY = random.nextInt(HEIGHT / DOT_SIZE) * DOT_SIZE;
    }

    @Override
    public void paintComponent(Graphics g) {
        super.paintComponent(g);

        if (!gameOver) {
            drawScore(g);
            drawFood(g);
            drawSnake(g);
        } else {
            gameOverScreen(g);
        }
    }

    private void drawScore(Graphics g) {
        g.setColor(Color.CYAN);
        g.setFont(new Font("Arial", Font.BOLD, 14));
        g.drawString("Score: " + score, 10, 20);
    }

    private void drawFood(Graphics g) {
        g.setColor(Color.RED);
        g.fillOval(foodX, foodY, DOT_SIZE, DOT_SIZE);
    }

    private void drawSnake(Graphics g) {
        // Head in bright yellow
        g.setColor(Color.YELLOW);
        g.fillRect(x[0], y[0], DOT_SIZE, DOT_SIZE);

        // Body segments in shades of green
        for (int i = 1; i < length; i++) {
            int greenValue = Math.max(50, 255 - (i * 10));
            g.setColor(new Color(0, greenValue, 0));
            g.fillRect(x[i], y[i], DOT_SIZE, DOT_SIZE);
        }
    }

    private void move() {
        // Move body segments
        for (int i = length - 1; i > 0; i--) {
            x[i] = x[i - 1];
            y[i] = y[i - 1];
        }

        // Move head based on direction
        switch (dir) {
            case 1: x[0] += DOT_SIZE; break; // right
            case 2: y[0] += DOT_SIZE; break; // down
            case 3: x[0] -= DOT_SIZE; break; // left
            case 4: y[0] -= DOT_SIZE; break; // up
        }
    }

    private void checkFood() {
        if (x[0] == foodX && y[0] == foodY) {
            if (length < MAX_DOTS) {
                length++;
                x[length - 1] = x[length - 2];
                y[length - 1] = y[length - 2];
            }
            score += 10;
            Toolkit.getDefaultToolkit().beep(); // simple sound effect
            locateFood();
        }
    }

    private void checkCollision() {
        // Check collision with walls
        if (x[0] < 0 || x[0] >= WIDTH || y[0] < 0 || y[0] >= HEIGHT) {
            gameOver = true;
            Toolkit.getDefaultToolkit().beep();
            timer.stop();
        }

        // Check collision with itself
        for (int i = 1; i < length; i++) {
            if (x[0] == x[i] && y[0] == y[i]) {
                gameOver = true;
                Toolkit.getDefaultToolkit().beep();
                timer.stop();
            }
        }
    }

    private void gameOverScreen(Graphics g) {
        String msg1 = "Game Over!";
        String msg2 = "Final Score: " + score;
        String msg3 = "Press any key to exit...";

        g.setColor(Color.RED);
        g.setFont(new Font("Arial", Font.BOLD, 40));
        FontMetrics fm = getFontMetrics(g.getFont());
        g.drawString(msg1, (WIDTH - fm.stringWidth(msg1)) / 2, HEIGHT / 2 - 50);

        g.setFont(new Font("Arial", Font.BOLD, 24));
        fm = getFontMetrics(g.getFont());
        g.drawString(msg2, (WIDTH - fm.stringWidth(msg2)) / 2, HEIGHT / 2);

        g.drawString(msg3, (WIDTH - fm.stringWidth(msg3)) / 2, HEIGHT / 2 + 50);
    }

    @Override
    public void actionPerformed(ActionEvent e) {
        if (!gameOver) {
            move();
            checkFood();
            checkCollision();
        }
        repaint();
    }

    // Handle key input to change direction
    @Override
    public void keyPressed(KeyEvent e) {
        int key = e.getKeyCode();

        switch (key) {
            case KeyEvent.VK_RIGHT:
                if (dir != 3) dir = 1;
                break;
            case KeyEvent.VK_DOWN:
                if (dir != 4) dir = 2;
                break;
            case KeyEvent.VK_LEFT:
                if (dir != 1) dir = 3;
                break;
            case KeyEvent.VK_UP:
                if (dir != 2) dir = 4;
                break;
            default:
                // If game over and any key pressed, exit
                if (gameOver) System.exit(0);
        }
    }

    @Override public void keyReleased(KeyEvent e) {}
    @Override public void keyTyped(KeyEvent e) {}

    // Main method to start the game
    public static void main(String[] args) {
        JFrame frame = new JFrame("Snake Game - Sanne Karibo");
        SnakeGame gamePanel = new SnakeGame();

        frame.add(gamePanel);
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        frame.pack();
        frame.setResizable(false);
        frame.setLocationRelativeTo(null);
        frame.setVisible(true);

        // Show prescreen dialog
        JOptionPane.showMessageDialog(frame,
                "Snake Game\nCreated by Sanne Karibo\n\nPress OK to start...",
                "Welcome", JOptionPane.INFORMATION_MESSAGE);
    }
}

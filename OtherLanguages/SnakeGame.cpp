#include <graphics.h>
#include <conio.h>
#include <dos.h>
#include <cstdlib>
#include <ctime>

const int MaxLength = 100;
int x[MaxLength], y[MaxLength];
int Length = 5;
int Dir = 1; // 1=Right, 2=Down, 3=Left, 4=Up
int FoodX, FoodY;
bool GameOver = false;
int Score = 0;

void DrawSnake();
void MoveSnake();
void GenerateFood();
void CheckCollision();
void ShowPrescreen();
void DrawScore();

int main() {
    int gd = DETECT, gm;
    initgraph(&gd, &gm, "");

    srand(time(0));
    ShowPrescreen();
    cleardevice();

    for (int i = 0; i < Length; ++i) {
        x[i] = 20 - i;
        y[i] = 10;
    }

    GenerateFood();

    while (!GameOver) {
        cleardevice();
        DrawScore();
        DrawSnake();

        // Draw Food
        setcolor(RED);
        setfillstyle(SOLID_FILL, RED);
        fillellipse(FoodX * 10 + 4, FoodY * 10 + 4, 4, 4);

        if (kbhit()) {
            int ch = getch();
            if (ch == 0) ch = getch();
            switch (ch) {
                case 77: if (Dir != 3) Dir = 1; break; // Right
                case 80: if (Dir != 4) Dir = 2; break; // Down
                case 75: if (Dir != 1) Dir = 3; break; // Left
                case 72: if (Dir != 2) Dir = 4; break; // Up
            }
        }

        MoveSnake();
        CheckCollision();
        delay(100);
    }

    cleardevice();
    setcolor(RED);
    outtextxy(250, 200, "Game Over!");
    outtextxy(230, 230, ("Final Score: " + std::to_string(Score)).c_str());
    outtextxy(200, 260, "Press any key to exit...");
    getch();

    closegraph();
    return 0;
}

void ShowPrescreen() {
    cleardevice();
    setcolor(YELLOW);
    outtextxy(250, 200, "Snake Game");
    outtextxy(230, 230, "Created by Sanne Karibo");
    outtextxy(210, 260, "Press any key to start...");
    getch();
}

void DrawScore() {
    setcolor(LIGHTCYAN);
    outtextxy(10, 10, ("Score: " + std::to_string(Score)).c_str());
}

void DrawSnake() {
    setfillstyle(SOLID_FILL, YELLOW);
    bar(x[0] * 10, y[0] * 10, x[0] * 10 + 8, y[0] * 10 + 8); // Head

    for (int i = 1; i < Length; ++i) {
        int color = GREEN + (i / 5);
        if (color > LIGHTGREEN) color = LIGHTGREEN;
        setfillstyle(SOLID_FILL, color);
        bar(x[i] * 10, y[i] * 10, x[i] * 10 + 8, y[i] * 10 + 8);
    }
}

void MoveSnake() {
    for (int i = Length - 1; i > 0; --i) {
        x[i] = x[i - 1];
        y[i] = y[i - 1];
    }

    switch (Dir) {
        case 1: x[0]++; break;
        case 2: y[0]++; break;
        case 3: x[0]--; break;
        case 4: y[0]--; break;
    }

    if (x[0] == FoodX && y[0] == FoodY) {
        if (Length < MaxLength) {
            Length++;
            x[Length - 1] = x[Length - 2];
            y[Length - 1] = y[Length - 2];
        }
        Score += 10;
        sound(1000); delay(50); nosound();
        GenerateFood();
    }
}

void GenerateFood() {
    FoodX = rand() % 60 + 1;
    FoodY = rand() % 45 + 1;
}

void CheckCollision() {
    if (x[0] < 0 || x[0] > 63 || y[0] < 0 || y[0] > 47) {
        sound(300); delay(200); nosound();
        GameOver = true;
        return;
    }

    for (int i = 1; i < Length; ++i) {
        if (x[0] == x[i] && y[0] == y[i]) {
            sound(300); delay(200); nosound();
            GameOver = true;
        }
    }
}

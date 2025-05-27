' Snake Game in QBasic
' Author: Sanne Karibo
' Enhanced with sound effects, score tracking, and improved graphics

DECLARE SUB DrawSnake()
DECLARE SUB MoveSnake()
DECLARE SUB GenerateFood()
DECLARE SUB CheckCollision()
DECLARE SUB ShowPrescreen()
DECLARE SUB DrawScore()

CONST MaxLength = 100
DIM SHARED x(MaxLength), y(MaxLength)
DIM SHARED Length, Dir, FoodX, FoodY, GameOver, Score

RANDOMIZE TIMER
SCREEN 12
ShowPrescreen
CLS

Length = 5
Dir = 1 ' 1=Right, 2=Down, 3=Left, 4=Up
GameOver = 0
Score = 0

FOR i = 1 TO Length
    x(i) = 20 - i
    y(i) = 10
NEXT

GenerateFood

DO WHILE NOT GameOver
    CLS
    DrawScore
    DrawSnake
    ' Draw food as a red filled circle for nicer graphics
    CIRCLE (FoodX * 10 + 4, FoodY * 10 + 4), 4, 4
    PAINT (FoodX * 10 + 4, FoodY * 10 + 4), 4

    Key$ = INKEY$
    IF Key$ <> "" THEN
        SELECT CASE Key$
            CASE CHR$(0) + "M": IF Dir <> 3 THEN Dir = 1 ' Right
            CASE CHR$(0) + "P": IF Dir <> 4 THEN Dir = 2 ' Down
            CASE CHR$(0) + "K": IF Dir <> 1 THEN Dir = 3 ' Left
            CASE CHR$(0) + "H": IF Dir <> 2 THEN Dir = 4 ' Up
        END SELECT
    END IF

    MoveSnake
    CheckCollision
    _DELAY 0.1
LOOP

CLS
COLOR 12
LOCATE 12, 20
PRINT "Game Over!"
LOCATE 14, 18
PRINT "Final Score: "; Score
LOCATE 16, 18
PRINT "Press any key to exit..."
DO WHILE INKEY$ = "": LOOP
END

SUB ShowPrescreen
    CLS
    COLOR 14, 1
    LOCATE 12, 25
    PRINT "Snake Game"
    LOCATE 14, 20
    PRINT "Created by Sanne Karibo"
    LOCATE 16, 22
    PRINT "Press any key to start..."
    DO WHILE INKEY$ = "": LOOP
END SUB

SUB DrawScore
    COLOR 11
    LOCATE 1, 1
    PRINT "Score: "; Score
END SUB

SUB DrawSnake
    ' Head in bright yellow, body in green with gradient effect
    LINE (x(1) * 10, y(1) * 10)-(x(1) * 10 + 8, y(1) * 10 + 8), 14, BF
    FOR i = 2 TO Length
        ' Gradually darker green for body segments
        COLOR_SEG = 10 - (i \ 5) ' decrease color index every 5 segments (10 to 6)
        IF COLOR_SEG < 6 THEN COLOR_SEG = 6
        LINE (x(i) * 10, y(i) * 10)-(x(i) * 10 + 8, y(i) * 10 + 8), COLOR_SEG, BF
    NEXT
END SUB

SUB MoveSnake
    FOR i = Length TO 2 STEP -1
        x(i) = x(i - 1)
        y(i) = y(i - 1)
    NEXT

    SELECT CASE Dir
        CASE 1: x(1) = x(1) + 1
        CASE 2: y(1) = y(1) + 1
        CASE 3: x(1) = x(1) - 1
        CASE 4: y(1) = y(1) - 1
    END SELECT

    IF x(1) = FoodX AND y(1) = FoodY THEN
        IF Length < MaxLength THEN
            Length = Length + 1
            x(Length) = x(Length - 1)
            y(Length) = y(Length - 1)
        END IF
        Score = Score + 10
        SOUND 1000, 5   ' Sound effect for eating food
        GenerateFood
    END IF
END SUB

SUB GenerateFood
    FoodX = INT(RND * 60) + 1
    FoodY = INT(RND * 45) + 1
END SUB

SUB CheckCollision
    IF x(1) < 0 OR x(1) > 63 OR y(1) < 0 OR y(1) > 47 THEN
        SOUND 300, 20  ' Sound effect for game over
        GameOver = 1
        EXIT SUB
    END IF

    FOR i = 2 TO Length
        IF x(1) = x(i) AND y(1) = y(i) THEN
            SOUND 300, 20  ' Sound effect for game over
            GameOver = 1
        END IF
    NEXT
END SUB

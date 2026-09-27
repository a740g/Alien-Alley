'-----------------------------------------------------------------------------------------------------------------------
'      _    _ _                 _    _ _
'     / \  | (_) ___ _ __      / \  | | | ___ _   _
'    / _ \ | | |/ _ \ '_ \    / _ \ | | |/ _ \ | | |
'   / ___ \| | |  __/ | | |  / ___ \| | |  __/ |_| |
'  /_/   \_\_|_|\___|_| |_| /_/   \_\_|_|\___|\__, |
'                                             |___/
'
'  QB64-PE Source Port
'  Copyright (c) 2026 Samuel Gomes
'
'-----------------------------------------------------------------------------------------------------------------------

'$STATIC
_DEFINE A-Z AS LONG
OPTION _EXPLICIT
$ASSERTS
$EXEICON:'./AlienAlley.ico'
$VERSIONINFO:ProductName='Alien Alley'
$VERSIONINFO:CompanyName='Samuel Gomes'
$VERSIONINFO:LegalCopyright='Copyright (c) 2026 Samuel Gomes'
$VERSIONINFO:LegalTrademarks='All trademarks are property of their respective owners'
$VERSIONINFO:Web='https://github.com/a740g'
$VERSIONINFO:Comments='https://github.com/a740g'
$VERSIONINFO:InternalName='AlienAlley'
$VERSIONINFO:OriginalFilename='AlienAlley.exe'
$VERSIONINFO:FileDescription='Alien Alley executable'
$VERSIONINFO:FILEVERSION#=2,5,0,0
$VERSIONINFO:PRODUCTVERSION#=2,5,0,0
$COLOR:32
$RESIZE:SMOOTH

' Game constants
CONST APP_NAME = "Alien Alley"
CONST MAX_ALIENS = 4
CONST MAX_ALIEN_MISSILES = 20
CONST MAX_HERO_MISSILES = 10
CONST MAX_EXPLOSIONS = MAX_ALIENS + 1 ' +1 for hero
CONST MAX_EXPLOSION_BITMAPS = 5
CONST GUN_BLINK_RATE = 20
CONST HERO_X_VELOCITY = 3
CONST HERO_Y_VELOCITY = 3
CONST ALIEN_X_VELOCITY = 3
CONST ALIEN_Y_VELOCITY = 2
CONST HERO_MISSILE_VELOCITY = 5
CONST ALIEN_MISSILE_VELOCITY = 4
CONST ALIEN_MOVE_TIME_VAR = 50
CONST ALIEN_MOVE_TIME_BASE = 20
CONST ALIEN_GEN_RATE_BASE = 40
CONST ALIEN_GEN_RATE_VAR = 40
CONST ALIEN_FIRE_LOCKOUT = 60
CONST ALIEN_FIRE_PROB_HERO = 20
CONST ALIEN_FIRE_PROB_RANDOM = 10
CONST ALIEN_PROX_THRESHOLD = 20
CONST HERO_GUN_OFFSET_LEFT = 3
CONST HERO_GUN_OFFSET_RIGHT = 26
CONST HERO_GUN_OFFSET_UP = 10
CONST ALIEN_GUN_OFFSET_LEFT = 4
CONST ALIEN_GUN_OFFSET_RIGHT = 25
CONST ALIEN_GUN_OFFSET_DOWN = 20
CONST DEATH_DELAY = 60 ' 1 sec delay after player death
CONST POINTS_PER_ALIEN = 10
CONST SHIELD_STATUS_WIDTH = 80
CONST SHIELD_STATUS_HEIGHT = 20
CONST SHIELD_STATUS_LEFT = 192
CONST SHIELD_STATUS_TOP = 360
CONST SHIELD_STATUS_RIGHT = SHIELD_STATUS_LEFT + SHIELD_STATUS_WIDTH - 1
CONST SHIELD_STATUS_BOTTOM = SHIELD_STATUS_TOP + SHIELD_STATUS_HEIGHT - 1
CONST MAX_HERO_SHIELDS = SHIELD_STATUS_WIDTH - 1
CONST SCORE_NUMBERS_LEFT = 474
CONST SCORE_NUMBERS_TOP = 363
CONST EXPLOSION_FRAME_REPEAT_COUNT = 3
CONST HIGH_SCORE_TEXT_LEN = 20
CONST HIGH_SCORE_FILENAME = "highscore.csv"
CONST NUM_HIGH_SCORES = 10
CONST NUM_TILES = 3
CONST UPDATES_PER_SECOND = 60
' Screen parameters
CONST SCREEN_WIDTH = 640
CONST SCREEN_HEIGHT = 400
CONST STATUS_HEIGHT = 60 ' our HUD is 60 pixels now 30 * 2 in 640x400 mode
CONST REDUCED_SCREEN_HEIGHT = SCREEN_HEIGHT - STATUS_HEIGHT
' Scrolling parameters
CONST MAP_SCROLL_STEP_NORMAL = 1
CONST MAP_SCROLL_STEP_FAST = 2
' Key constants
CONST KEY_SPACE& = _ASC_SPACE
CONST KEY_UPPER_A& = 65
CONST KEY_UPPER_D& = 68
CONST KEY_UPPER_J& = 74
CONST KEY_UPPER_K& = 75
CONST KEY_UPPER_M& = 77
CONST KEY_UPPER_Q& = 81
CONST KEY_UPPER_S& = 83
CONST KEY_UPPER_W& = 87
CONST KEY_LOWER_A& = 97
CONST KEY_LOWER_D& = 100
CONST KEY_LOWER_J& = 106
CONST KEY_LOWER_K& = 107
CONST KEY_LOWER_M& = 109
CONST KEY_LOWER_Q& = 113
CONST KEY_LOWER_S& = 115
CONST KEY_LOWER_W& = 119
CONST KEY_TILDE& = _ASC_TILDE

TYPE Vector2f
    x AS SINGLE
    y AS SINGLE
END TYPE

TYPE Rectangle
    a AS Vector2f
    b AS Vector2f
END TYPE

TYPE Sprite
    isActive AS _BYTE ' is this sprite active / in use?
    size AS Vector2f ' size of the sprite
    boundary AS Rectangle ' sprite should not leave this area
    position AS Vector2f ' (left, top) position of the sprite on the 2D plane
    velocity AS Vector2f ' velocity of the sprite
    bDraw AS _BYTE ' do we need to draw the sprite?
    objSpec1 AS LONG ' special data 1
    objSpec2 AS LONG ' special data 2
END TYPE

TYPE HighScore
    text AS STRING
    score AS LONG
END TYPE

DIM SHARED Score AS LONG
DIM SHARED HeroShields AS INTEGER
DIM SHARED HighScore(0 TO NUM_HIGH_SCORES - 1) AS HighScore
DIM SHARED MapScrollStep AS INTEGER ' # of pixels to scroll the background
DIM SHARED Hero AS Sprite
DIM SHARED Alien(0 TO MAX_ALIENS - 1) AS Sprite
DIM SHARED HeroMissile(0 TO MAX_HERO_MISSILES - 1) AS Sprite
DIM SHARED AlienMissile(0 TO MAX_ALIEN_MISSILES - 1) AS Sprite
DIM SHARED Explosion(0 TO MAX_EXPLOSIONS - 1) AS Sprite
DIM SHARED HUDSize AS Vector2f
DIM SHARED HUDDigitSize AS Vector2f
DIM SHARED AlienGenCounter AS INTEGER
DIM SHARED GunBlinkCounter AS INTEGER
DIM SHARED GunBlinkState AS _BYTE
DIM SHARED AllowHeroFire AS _BYTE
' Asset global variables
DIM SHARED ExplosionSound AS LONG ' sample handle
DIM SHARED LaserSound AS LONG ' sample handle
DIM SHARED HeroBitmap(0 TO 1) AS LONG
DIM SHARED AlienBitmap(0 TO 1) AS LONG
DIM SHARED MissileBitmap AS LONG
DIM SHARED MissileTrailUpBitmap AS LONG
DIM SHARED MissileTrailDnBitmap AS LONG
DIM SHARED ExplosionBitmap(0 TO MAX_EXPLOSION_BITMAPS - 1) AS LONG
DIM SHARED TileBitmap(0 TO NUM_TILES - 1) AS LONG
DIM SHARED HUDBitmap(0 TO 1) AS LONG
DIM SHARED HUDDigitBitmap(0 TO 9) AS LONG
REDIM SHARED TileMap(0 TO 0, 0 TO 0) AS LONG ' bitmap for each tile position
REDIM SHARED TileMapY(0 TO 0) AS LONG ' the y postion of the tile row
DIM SHARED TileMapSize AS Vector2f
DIM SHARED ShowFPS AS _BYTE
DIM SHARED NoLimit AS _BYTE

' @brief Calculates the bounding rectangle for a sprite given its position and size.
' @param position Sprite position (left, top).
' @param size Sprite size (width, height).
' @param r Output rectangle (a = top-left, b = bottom-right).
SUB GetRectangle (position AS Vector2f, size AS Vector2f, r AS Rectangle)
    r.a.x = position.x
    r.a.y = position.y
    r.b.x = position.x + size.x - 1
    r.b.y = position.y + size.y - 1
END SUB

' @brief Tests two rectangles for AABB overlap.
' @param r1 First rectangle.
' @param r2 Second rectangle.
' @return _TRUE if the rectangles overlap, _FALSE otherwise.
FUNCTION RectanglesCollide%% (r1 AS Rectangle, r2 AS Rectangle)
    RectanglesCollide = NOT (r1.a.x > r2.b.x _ORELSE r2.a.x > r1.b.x _ORELSE r1.a.y > r2.b.y _ORELSE r2.a.y > r1.b.y)
END FUNCTION

' @brief Clears all pending mouse and keyboard input events.
SUB ClearInput
    DO WHILE _MOUSEINPUT
    LOOP
    _KEYCLEAR
END SUB

' @brief Fades the current _DEST to/from black.
' @param isIn _TRUE for fade-in, _FALSE for fade-out.
' @param maxFPS Target frame rate during the fade animation.
' @param stopPercent Percentage (0-100) at which to stop early (for partial fades).
SUB FadeScreen (isIn AS _BYTE, maxFPS AS _UNSIGNED INTEGER, stopPercent AS _BYTE)
    DIM AS LONG dspImg, tmpImg

    dspImg = _DISPLAY ' Get the image handle of the screen being displayed

    ' We'll draw a filled rectangle over the screen with varying aplha values
    ' Make a copy of the destination image
    tmpImg = _COPYIMAGE(_DEST)

    DIM maxX AS LONG: maxX = _WIDTH(tmpImg) - 1
    DIM maxY AS LONG: maxY = _HEIGHT(tmpImg) - 1

    DIM i AS LONG
    FOR i = 0 TO 255
        IF stopPercent < (i * 100) \ 255 THEN EXIT FOR ' bail if < 100% we hit the limit

        ' Stretch and blit the image to the screen
        _PUTIMAGE , tmpImg, _DISPLAY

        IF isIn THEN
            LINE (0, 0)-(maxX, maxY), _RGBA32(0, 0, 0, 255 - i), BF
        ELSE
            LINE (0, 0)-(maxX, maxY), _RGBA32(0, 0, 0, i), BF
        END IF

        _DISPLAY

        IF maxFPS > 0 THEN _LIMIT maxFPS
    NEXT i

    _FREEIMAGE tmpImg
END SUB

' @brief Loads an image from file or memory buffer and returns a handle.
' @param fileName Filename or memory buffer of the image.
' @param isHardware If _TRUE, loads as a hardware image.
' @param otherOptions Additional loading options (e.g., "memory", "HQ2XA" scaler).
' @param transparentColor Color key for transparency (use -1 to disable).
' @return Image handle on success, -1 on failure.
FUNCTION LoadImage& (fileName AS STRING, isHardware AS _BYTE, otherOptions AS STRING, transparentColor AS _INTEGER64)
    DIM handle AS LONG

    handle = _LOADIMAGE(fileName, 32, otherOptions)

    IF handle < -1 THEN
        IF transparentColor >= 0 THEN _CLEARCOLOR transparentColor, handle

        IF isHardware THEN
            DIM handleHW AS LONG: handleHW = _COPYIMAGE(handle, 33)
            _FREEIMAGE handle
            handle = handleHW
        END IF
    END IF

    LoadImage = handle
END FUNCTION

' @brief Loads sprite bitmaps and initializes all sprite structures for gameplay.
SUB InitializeSprites
    DIM i AS INTEGER

    ' Load hero spaceship
    HeroBitmap(0) = LoadImage("dat/gfx/hero0.pcx", _TRUE, _STR_EMPTY, Black)
    _ASSERT HeroBitmap(0) < -1
    HeroBitmap(1) = LoadImage("dat/gfx/hero1.pcx", _TRUE, _STR_EMPTY, Black)
    _ASSERT HeroBitmap(1) < -1

    ' Load alien spaceship
    AlienBitmap(0) = LoadImage("dat/gfx/alien0.pcx", _TRUE, _STR_EMPTY, Black)
    _ASSERT AlienBitmap(0) < -1
    AlienBitmap(1) = LoadImage("dat/gfx/alien1.pcx", _TRUE, _STR_EMPTY, Black)
    _ASSERT AlienBitmap(1) < -1

    ' Load missile
    MissileBitmap = LoadImage("dat/gfx/missile.pcx", _TRUE, _STR_EMPTY, Black)
    _ASSERT MissileBitmap < -1

    ' Load missile trails
    MissileTrailUpBitmap = LoadImage("dat/gfx/missiletrailup.pcx", _TRUE, _STR_EMPTY, Black)
    _ASSERT MissileTrailUpBitmap < -1
    MissileTrailDnBitmap = LoadImage("dat/gfx/missiletraildn.pcx", _TRUE, _STR_EMPTY, Black)
    _ASSERT MissileTrailDnBitmap < -1

    ' Load explosion bitmaps
    FOR i = 0 TO MAX_EXPLOSION_BITMAPS - 1
        ExplosionBitmap(i) = LoadImage("dat/gfx/explosion" + LTRIM$(STR$(i)) + ".pcx", _TRUE, _STR_EMPTY, Black)
        _ASSERT ExplosionBitmap(i) < -1
    NEXT

    ' Initialize Hero sprite
    Hero.isActive = _TRUE
    Hero.size.x = _WIDTH(HeroBitmap(0))
    Hero.size.y = _HEIGHT(HeroBitmap(0))
    Hero.boundary.a.x = 0
    Hero.boundary.a.y = 0
    Hero.boundary.b.x = SCREEN_WIDTH
    Hero.boundary.b.y = REDUCED_SCREEN_HEIGHT
    Hero.position.x = ((Hero.boundary.b.x - Hero.boundary.a.x) / 2) - Hero.size.x / 2
    Hero.position.y = ((Hero.boundary.b.y - Hero.boundary.a.y) / 2) - Hero.size.y / 2
    Hero.velocity.x = HERO_X_VELOCITY
    Hero.velocity.y = HERO_Y_VELOCITY
    Hero.bDraw = _TRUE

    ' Initialize alien sprites
    FOR i = 0 TO MAX_ALIENS - 1
        Alien(i).isActive = _FALSE
        Alien(i).size.x = _WIDTH(AlienBitmap(0))
        Alien(i).size.y = _HEIGHT(AlienBitmap(0))
        Alien(i).boundary.a.x = 0
        Alien(i).boundary.b.x = SCREEN_WIDTH
        Alien(i).bDraw = _FALSE
    NEXT

    ' Initialize alien missiles
    FOR i = 0 TO MAX_ALIEN_MISSILES - 1
        AlienMissile(i).isActive = _FALSE
        AlienMissile(i).size.x = _WIDTH(MissileBitmap)
        AlienMissile(i).size.y = _HEIGHT(MissileBitmap)
        AlienMissile(i).objSpec1 = _WIDTH(MissileTrailUpBitmap) ' Store these here
        AlienMissile(i).objSpec2 = _HEIGHT(MissileTrailUpBitmap) ' Store these here
        AlienMissile(i).bDraw = _FALSE
    NEXT

    ' Initialize hero missiles
    FOR i = 0 TO MAX_HERO_MISSILES - 1
        HeroMissile(i).isActive = _FALSE
        HeroMissile(i).size.x = _WIDTH(MissileBitmap)
        HeroMissile(i).size.y = _HEIGHT(MissileBitmap)
        HeroMissile(i).objSpec1 = _WIDTH(MissileTrailUpBitmap) ' Store these here
        HeroMissile(i).objSpec2 = _HEIGHT(MissileTrailUpBitmap) ' Store these here
        HeroMissile(i).bDraw = _FALSE
    NEXT

    ' Initialize explosions
    FOR i = 0 TO MAX_EXPLOSIONS - 1
        Explosion(i).isActive = _FALSE
        Explosion(i).size.x = _WIDTH(ExplosionBitmap(0))
        Explosion(i).size.y = _HEIGHT(ExplosionBitmap(0))
        Explosion(i).bDraw = _FALSE
    NEXT

    ' Set up gun blink stuff
    GunBlinkCounter = GUN_BLINK_RATE
    GunBlinkState = 1
END SUB

' @brief Frees sprite bitmap resources allocated during InitializeSprites.
SUB FinalizeSprites
    DIM i AS INTEGER

    FOR i = 0 TO MAX_EXPLOSION_BITMAPS - 1
        _FREEIMAGE ExplosionBitmap(i)
    NEXT

    _FREEIMAGE MissileTrailDnBitmap
    _FREEIMAGE MissileTrailUpBitmap
    _FREEIMAGE MissileBitmap
    _FREEIMAGE AlienBitmap(0)
    _FREEIMAGE AlienBitmap(1)
    _FREEIMAGE HeroBitmap(0)
    _FREEIMAGE HeroBitmap(1)
END SUB

' @brief Collects input from keyboard and mouse, populating the UserInput variables.
' @param UserInputUp Set to _TRUE if up movement requested.
' @param UserInputDown Set to _TRUE if down movement requested.
' @param UserInputLeft Set to _TRUE if left movement requested.
' @param UserInputRight Set to _TRUE if right movement requested.
' @param UserInputFire Set to _TRUE if fire requested.
' @return _TRUE if ESC was pressed (game quit requested), _FALSE otherwise.
' TODO: Add game controller support.
FUNCTION GetInput%% (UserInputUp AS _BYTE, UserInputDown AS _BYTE, UserInputLeft AS _BYTE, UserInputRight AS _BYTE, UserInputFire AS _BYTE)
    DIM mouseMovement AS Vector2f
    DIM mouseFire AS _BYTE

    ' Collect and aggregate mouse input
    ' The mouse should not give undue advantage
    DO WHILE _MOUSEINPUT
        mouseMovement.x = mouseMovement.x + _MOUSEMOVEMENTX
        mouseMovement.y = mouseMovement.y + _MOUSEMOVEMENTY
        mouseFire = mouseFire OR _MOUSEBUTTON(1) OR _MOUSEBUTTON(2) OR _MOUSEBUTTON(3)
    LOOP

    UserInputLeft = (mouseMovement.x < 0) OR _KEYDOWN(_KEY_LEFT) OR _KEYDOWN(KEY_UPPER_A) OR _KEYDOWN(KEY_LOWER_A)
    UserInputRight = (mouseMovement.x > 0) OR _KEYDOWN(_KEY_RIGHT) OR _KEYDOWN(KEY_UPPER_D) OR _KEYDOWN(KEY_LOWER_D)
    UserInputUp = (mouseMovement.y < 0) OR _KEYDOWN(_KEY_UP) OR _KEYDOWN(KEY_UPPER_W) OR _KEYDOWN(KEY_LOWER_W)
    UserInputDown = (mouseMovement.y > 0) OR _KEYDOWN(_KEY_DOWN) OR _KEYDOWN(KEY_UPPER_S) OR _KEYDOWN(KEY_LOWER_S)
    UserInputFire = mouseFire OR _KEYDOWN(KEY_SPACE) OR _KEYDOWN(_KEY_LCTRL) OR _KEYDOWN(_KEY_RCTRL) OR _KEYDOWN(_KEY_LALT) OR _KEYDOWN(_KEY_RALT)

    GetInput = _KEYDOWN(_KEY_ESC)
END FUNCTION

' @brief Finds a non-active hero missile slot and initializes it at the given position.
' @param x Horizontal spawn position.
' @param y Vertical spawn position.
' @return _TRUE if a missile was created successfully, _FALSE if all slots are in use.
FUNCTION CreateHeroMissile%% (x AS INTEGER, y AS INTEGER)
    DIM i AS INTEGER

    FOR i = 0 TO MAX_HERO_MISSILES - 1
        IF NOT HeroMissile(i).isActive THEN
            HeroMissile(i).isActive = _TRUE
            HeroMissile(i).position.x = x
            HeroMissile(i).position.y = y
            HeroMissile(i).velocity.x = 0
            HeroMissile(i).velocity.y = -HERO_MISSILE_VELOCITY
            HeroMissile(i).bDraw = _TRUE
            CreateHeroMissile = _TRUE
            EXIT FUNCTION
        END IF
    NEXT

    CreateHeroMissile = _FALSE
END FUNCTION

' @brief Finds a free alien slot and spawns a new alien at a random position at the top of the screen.
SUB CreateAlien
    DIM i AS INTEGER

    FOR i = 0 TO MAX_ALIENS - 1
        IF NOT Alien(i).isActive THEN
            Alien(i).isActive = _TRUE
            Alien(i).position.x = RND * (SCREEN_WIDTH - Alien(i).size.x)
            Alien(i).position.y = -Alien(i).size.y
            Alien(i).velocity.x = RND * ALIEN_X_VELOCITY + 1
            Alien(i).velocity.y = RND * ALIEN_Y_VELOCITY + 1
            Alien(i).objSpec1 = ALIEN_MOVE_TIME_BASE + RND * ALIEN_MOVE_TIME_VAR
            Alien(i).objSpec2 = 0 ' ability to fire immediately
            Alien(i).bDraw = _TRUE
            EXIT FOR
        END IF
    NEXT
END SUB

' @brief Finds a free alien missile slot and initializes it at the given position.
' @param x Horizontal spawn position (near an alien gun).
' @param y Vertical spawn position (near an alien gun).
SUB CreateAlienMissile (x AS INTEGER, y AS INTEGER)
    DIM i AS INTEGER

    FOR i = 0 TO MAX_ALIEN_MISSILES - 1
        IF NOT AlienMissile(i).isActive THEN
            AlienMissile(i).isActive = _TRUE
            AlienMissile(i).position.x = x
            AlienMissile(i).position.y = y
            AlienMissile(i).velocity.x = 0
            AlienMissile(i).velocity.y = ALIEN_MISSILE_VELOCITY
            AlienMissile(i).bDraw = _TRUE
            EXIT FOR
        END IF
    NEXT
END SUB

' @brief Starts an explosion animation at the given coordinates.
' @param position Explosion center position.
SUB CreateExplosion (position AS Vector2f)
    DIM i AS INTEGER

    FOR i = 0 TO MAX_EXPLOSIONS - 1
        IF NOT Explosion(i).isActive THEN
            Explosion(i).isActive = _TRUE
            Explosion(i).position = position
            Explosion(i).objSpec1 = 0 ' current explosion bitmap
            Explosion(i).objSpec2 = EXPLOSION_FRAME_REPEAT_COUNT
            Explosion(i).bDraw = _TRUE
            EXIT FOR
        END IF
    NEXT
END SUB

' @brief Loads HUD bitmaps (panel and digit sprites) and initializes the HUD overlay.
SUB InitializeHUD
    DIM i AS INTEGER

    ' Load the HUD bitmap
    HUDBitmap(0) = LoadImage("dat/gfx/hud0.pcx", _TRUE, "HQ2XA", -1)
    _ASSERT HUDBitmap(0) < -1
    HUDBitmap(1) = LoadImage("dat/gfx/hud1.pcx", _TRUE, "HQ2XA", -1)
    _ASSERT HUDBitmap(1) < -1

    HUDSize.x = _WIDTH(HUDBitmap(0))
    HUDSize.y = _HEIGHT(HUDBitmap(0))

    ' Load the digit bitmaps
    FOR i = 0 TO 9
        HUDDigitBitmap(i) = LoadImage("dat/gfx/" + LTRIM$(STR$(i)) + ".pcx", _TRUE, "HQ2XA", -1)
        _ASSERT HUDDigitBitmap(i) < -1
    NEXT
    HUDDigitSize.x = _WIDTH(HUDDigitBitmap(0))
    HUDDigitSize.y = _HEIGHT(HUDDigitBitmap(0))
END SUB

' @brief Frees all HUD bitmap resources (digit sprites and HUD panel).
SUB FinalizeHUD
    DIM i AS INTEGER

    FOR i = 0 TO 9
        _FREEIMAGE HUDDigitBitmap(i)
    NEXT

    _FREEIMAGE HUDBitmap(0)
    _FREEIMAGE HUDBitmap(1)
END SUB

' @brief Draws the HUD panel at the bottom of the screen, including score digits and shield bar.
SUB DrawHUD
    ' First draw the HUD panel onto the frame buffer
    _PUTIMAGE (0, SCREEN_HEIGHT - HUDSize.y), HUDBitmap(GunBlinkState)

    ' Update the shield status
    LINE (SHIELD_STATUS_LEFT, SHIELD_STATUS_TOP)-(SHIELD_STATUS_RIGHT, SHIELD_STATUS_BOTTOM), Red, BF
    IF HeroShields > 0 THEN
        LINE (SHIELD_STATUS_LEFT, SHIELD_STATUS_TOP)-(SHIELD_STATUS_LEFT + HeroShields, SHIELD_STATUS_BOTTOM), Lime, BF
    END IF

    DIM s AS LONG: s = _MIN(Score, 999999) ' 6 digits only
    DIM w AS LONG: w = HUDDigitSize.x
    DIM h AS LONG: h = HUDDigitSize.y
    DIM j AS LONG: j = SCORE_NUMBERS_LEFT + 5 * w ' start at the rightmost score digit position

    ' Render the score from right to left
    DIM i AS LONG
    FOR i = 1 TO 6
        _PUTIMAGE (j, SCORE_NUMBERS_TOP)-(j + w - 1, SCORE_NUMBERS_TOP + h), HUDDigitBitmap(s MOD 10)

        s = s \ 10
        j = j - w
    NEXT i
END SUB

' @brief Loads background tile bitmaps and initializes the scrolling starfield map.
SUB InitializeMap
    DIM AS LONG x, y, c

    ' Load the background tiles
    TileBitmap(0) = LoadImage("dat/gfx/stars1.pcx", _TRUE, _STR_EMPTY, -1)
    _ASSERT TileBitmap(0) < -1
    TileBitmap(1) = LoadImage("dat/gfx/stars2.pcx", _TRUE, _STR_EMPTY, -1)
    _ASSERT TileBitmap(1) < -1
    TileBitmap(2) = LoadImage("dat/gfx/earth.pcx", _TRUE, _STR_EMPTY, -1)
    _ASSERT TileBitmap(2) < -1

    TileMapSize.x = SCREEN_WIDTH \ _WIDTH(TileBitmap(0))
    TileMapSize.y = SCREEN_HEIGHT \ _HEIGHT(TileBitmap(0)) + 1 ' one more at the bottom for seemless scrolling

    ' Tiles (n, 0) is always placed offscreen
    REDIM TileMap(1 TO TileMapSize.x, 0 TO TileMapSize.y) AS LONG ' resize the tile map array
    REDIM TileMapY(0 TO TileMapSize.y) AS LONG ' resize the y position array

    ' Set other variables
    MapScrollStep = MAP_SCROLL_STEP_NORMAL

    ' Set random tiles on the tile map
    FOR y = 0 TO TileMapSize.y
        FOR x = 1 TO TileMapSize.x
            ' Bias toward stars, fewer planets
            c = RND * 256
            IF c = 128 THEN
                c = NUM_TILES - 1
            ELSE
                c = c MOD (NUM_TILES - 1)
            END IF

            TileMap(x, y) = TileBitmap(c)
        NEXT
        TileMapY(y) = _HEIGHT(TileBitmap(0)) * y - _HEIGHT(TileBitmap(0)) ' setup the y values for TileMapY
    NEXT
END SUB

' @brief Frees background tile map resources.
SUB FinalizeMap
    DIM i AS LONG

    FOR i = 0 TO NUM_TILES - 1
        _FREEIMAGE TileBitmap(i)
    NEXT
END SUB

' @brief Advances the scrolling starfield map by one row.
SUB UpdateMap
    DIM AS LONG x, y, c

    ' Advance all tile rows by the scroll step amount
    FOR y = 0 TO TileMapSize.y
        TileMapY(y) = TileMapY(y) + MapScrollStep
    NEXT

    ' When the top row scrolls onto the screen, shift everything down
    IF TileMapY(0) >= 0 THEN
        ' Shift all rows down one position, removing the bottom row
        FOR y = TileMapSize.y TO 1 STEP -1
            TileMapY(y) = TileMapY(y - 1)

            FOR x = 1 TO TileMapSize.x
                TileMap(x, y) = TileMap(x, y - 1)
            NEXT
        NEXT

        TileMapY(0) = -_HEIGHT(TileBitmap(0)) ' set the tile to render completely offscreen

        ' Generate a new row of tiles at the top of the map
        FOR x = 1 TO TileMapSize.x
            ' We just need more stars and less planets
            c = RND * 256
            IF c = 128 THEN
                c = NUM_TILES - 1
            ELSE
                c = c MOD (NUM_TILES - 1)
            END IF

            TileMap(x, 0) = TileBitmap(c)
        NEXT
    END IF
END SUB

' @brief Renders the scrolling starfield background tiles to the frame buffer.
SUB DrawMap
    DIM AS LONG x, y

    FOR y = 0 TO TileMapSize.y
        FOR x = 1 TO TileMapSize.x
            _PUTIMAGE ((x - 1) * _WIDTH(TileBitmap(0)), TileMapY(y)), TileMap(x, y)
        NEXT
    NEXT
END SUB

' @brief Stops any currently playing MIDI and starts looping the specified file.
' @param fileName Path to the MIDI file to play. Pass "" to stop playback.
SUB PlayMIDIFile (fileName AS STRING)
    STATIC MIDIHandle AS LONG

    ' Stop and close any previously loaded MIDI
    IF MIDIHandle > 0 THEN
        _SNDSTOP MIDIHandle
        _SNDCLOSE MIDIHandle
        MIDIHandle = 0
    END IF

    IF _FILEEXISTS(fileName) THEN
        MIDIHandle = _SNDOPEN(fileName)
        _ASSERT MIDIHandle > 0
        _SNDLOOP MIDIHandle
    END IF
END SUB

' @brief Initializes sound effect playback handles.
SUB InitializeSound
    ' Load the sound effects
    ExplosionSound = _SNDOPEN("dat/sfx/snd/explode.wav")
    _ASSERT ExplosionSound > 0
    LaserSound = _SNDOPEN("dat/sfx/snd/laser.wav")
    _ASSERT LaserSound > 0
END SUB

' @brief Closes all sound effect handles and stops any playing MIDI.
SUB FinalizeSound
    _SNDCLOSE ExplosionSound
    _SNDCLOSE LaserSound

    PlayMIDIFile _STR_EMPTY ' This is will unload whatever MIDI data is there in memory
END SUB

' @brief Calculates and returns the current frames per second.
' @return Current FPS (updated once per second).
FUNCTION GetFPS~&
    STATIC AS _UNSIGNED LONG counter, finalFPS
    STATIC lastTime AS DOUBLE

    DIM currentTime AS DOUBLE: currentTime = _UPTIME

    IF currentTime >= lastTime + 1# THEN
        lastTime = currentTime
        finalFPS = counter
        counter = 0
    END IF

    counter = counter + 1

    GetFPS = finalFPS
END FUNCTION

' @brief Centers a string horizontally on the screen and draws it.
' @param s String to draw.
' @param y Vertical screen position.
' @param c Text color.
SUB DrawStringCenter (s AS STRING, y AS LONG, c AS _UNSIGNED LONG)
    COLOR c
    _PRINTSTRING ((SCREEN_WIDTH \ 2) - (_PRINTWIDTH(s) \ 2), y), s
END SUB

' @brief Renders the high score list on the screen.
SUB DrawHighScores
    DIM AS INTEGER i

    DrawStringCenter "####===-- HIGH SCORES --===####", 32, LemonYellow
    FOR i = 0 TO NUM_HIGH_SCORES - 1
        DrawStringCenter RIGHT$(" " + STR$(i + 1), 2) + ". " + LEFT$(HighScore(i).text + SPACE$(HIGH_SCORE_TEXT_LEN), HIGH_SCORE_TEXT_LEN) + "  " + RIGHT$(SPACE$(4) + STR$(HighScore(i).score), 5), 64 + i * 32, SkyBlue
    NEXT
END SUB

' @brief Displays the high score list screen, waiting for a keypress to return.
SUB DisplayHighScoresScreen
    ClearInput

    DO
        CLS , 0 ' black with no alpha

        UpdateMap

        DrawMap
        DrawHighScores

        IF ShowFPS THEN _PRINTSTRING (0, 0), STR$(GetFPS) + " FPS"

        _DISPLAY

        IF NOT NoLimit THEN _LIMIT UPDATES_PER_SECOND

        DO WHILE _MOUSEINPUT
            IF _MOUSEBUTTON(1) OR _MOUSEBUTTON(2) OR _MOUSEBUTTON(3) THEN EXIT DO
        LOOP
    LOOP WHILE _KEYHIT <= 0 ' <= 0 is used to ignore key up events
END SUB

' @brief Inserts a new score into the sorted high score list and prompts for the player's name.
' @param NewScore The player's score to insert.
SUB NewHighScore (NewScore AS LONG)
    DIM AS INTEGER i, sPos
    DIM k AS _UNSIGNED INTEGER

    ' Check to see if it's really a high score
    IF NewScore <= HighScore(NUM_HIGH_SCORES - 1).score THEN EXIT SUB

    ' Start high score music
    PlayMIDIFile "dat/sfx/mus/alienend.mid"

    ' Move other scores down to make room
    FOR i = NUM_HIGH_SCORES - 2 TO 0 STEP -1
        IF NewScore > HighScore(i).score THEN
            HighScore(i + 1).text = HighScore(i).text
            HighScore(i + 1).score = HighScore(i).score
        ELSE
            EXIT FOR
        END IF
    NEXT
    i = i + 1

    ' Blank out text of correct slot
    HighScore(i).text = _STR_EMPTY
    HighScore(i).score = NewScore


    sPos = 0
    ClearInput
    COLOR DeepSkyBlue

    ' Get user text string
    DO
        CLS , 0 ' black with no alpha
        UpdateMap

        DrawMap
        DrawHighScores
        _PRINTSTRING (228 + sPos * 8, 64 + i * 32), CHR$(179)

        k = _KEYHIT
        IF k >= KEY_SPACE AND k <= KEY_TILDE AND sPos < HIGH_SCORE_TEXT_LEN THEN
            sPos = sPos + 1
            HighScore(i).text = HighScore(i).text + CHR$(k)
        ELSEIF k = _KEY_BACKSPACE AND sPos > 0 THEN
            sPos = sPos - 1
            HighScore(i).text = LEFT$(HighScore(i).text, sPos)
        END IF

        IF ShowFPS THEN _PRINTSTRING (0, 0), STR$(GetFPS) + " FPS"

        _DISPLAY

        IF NOT NoLimit THEN _LIMIT UPDATES_PER_SECOND
    LOOP WHILE k <> _KEY_ENTER
END SUB

' @brief Displays the title screen with a fade-in effect and plays the intro music.
SUB DisplayTitlePage
    ' Start title music
    PlayMIDIFile "dat/sfx/mus/alienintro.mid"

    ' Clear screen
    CLS , 0 ' black with no alpha

    ' Load and display the title screen image
    DIM tmp AS LONG: tmp = LoadImage("dat/gfx/title.pcx", _FALSE, "HQ2XA", -1)
    _ASSERT tmp < -1

    ' Stretch the image to fill the screen
    _PUTIMAGE , tmp

    _FREEIMAGE tmp

    ' Fade in from black
    FadeScreen _TRUE, UPDATES_PER_SECOND * 2, 100
END SUB

' @brief Displays the production credits with fade in/out transitions.
SUB DisplayIntroCredits
    ' Clear the screen
    CLS , 0 ' black with no alpha

    ' Display publisher credit
    DrawStringCenter "Coriolis Group Books", 192, Red
    DrawStringCenter "Presents", 208, Red

    FadeScreen _TRUE, UPDATES_PER_SECOND * 2, 100
    FadeScreen _FALSE, UPDATES_PER_SECOND * 2, 100

    CLS , 0

    ' Display author credit
    DrawStringCenter "A", 176, Red
    DrawStringCenter "Dave Roberts", 192, Red
    DrawStringCenter "Production", 208, Red

    FadeScreen _TRUE, UPDATES_PER_SECOND * 2, 100 ' fade in
    FadeScreen _FALSE, UPDATES_PER_SECOND * 2, 100 ' fade out
END SUB

' @brief Loads the high score list from disk, falling back to defaults if the file is missing or unreadable.
SUB LoadHighScores
    IF _FILEEXISTS(HIGH_SCORE_FILENAME) THEN
        DIM i AS INTEGER
        DIM hsFile AS LONG

        ' Read scores from file
        hsFile = FREEFILE
        OPEN HIGH_SCORE_FILENAME FOR INPUT AS hsFile

        FOR i = 0 TO NUM_HIGH_SCORES - 1
            INPUT #hsFile, HighScore(i).text, HighScore(i).score
        NEXT

        CLOSE hsFile
    ELSE ' Load default high scores
        HighScore(0).text = "George Washington"
        HighScore(0).score = 100

        HighScore(1).text = "John Adams"
        HighScore(1).score = 90

        HighScore(2).text = "Thomas Jefferson"
        HighScore(2).score = 80

        HighScore(3).text = "James Madison"
        HighScore(3).score = 70

        HighScore(4).text = "James Monroe"
        HighScore(4).score = 60

        HighScore(5).text = "John Quincy Adams"
        HighScore(5).score = 50

        HighScore(6).text = "Andrew Jackson"
        HighScore(6).score = 40

        HighScore(7).text = "Martin Van Buren"
        HighScore(7).score = 30

        HighScore(8).text = "William H. Harrison"
        HighScore(8).score = 20

        HighScore(9).text = "John Tyler"
        HighScore(9).score = 10
    END IF
END SUB

' @brief Writes the current high score list to disk.
SUB SaveHighScores
    DIM i AS INTEGER
    DIM hsFile AS LONG

    ' Open the file for writing
    hsFile = FREEFILE

    OPEN HIGH_SCORE_FILENAME FOR OUTPUT AS hsFile

    FOR i = 0 TO NUM_HIGH_SCORES - 1
        WRITE #hsFile, HighScore(i).text, HighScore(i).score
    NEXT

    CLOSE hsFile
END SUB

' @brief Moves a sprite by its velocity and clamps it within its boundary (if defined).
' @param s Sprite to update.
SUB UpdateSprite (s AS Sprite)
    ' Apply velocity
    s.position.x = s.position.x + s.velocity.x
    s.position.y = s.position.y + s.velocity.y

    ' Clamp to boundary if defined
    IF s.boundary.b.x > s.boundary.a.x THEN
        IF s.position.x < s.boundary.a.x THEN s.position.x = s.boundary.a.x
        IF s.position.x > s.boundary.b.x - s.size.x THEN s.position.x = s.boundary.b.x - s.size.x
    END IF
    IF s.boundary.b.y > s.boundary.a.y THEN
        IF s.position.y < s.boundary.a.y THEN s.position.y = s.boundary.a.y
        IF s.position.y > s.boundary.b.y - s.size.y THEN s.position.y = s.boundary.b.y - s.size.y
    END IF
END SUB

' @brief Updates all sprite positions, generates new missiles, and handles off-screen cleanup.
' @param UserInputUp _TRUE if up movement requested.
' @param UserInputDown _TRUE if down movement requested.
' @param UserInputLeft _TRUE if left movement requested.
' @param UserInputRight _TRUE if right movement requested.
' @param UserInputFire _TRUE if fire requested.
SUB MoveSprites (UserInputUp AS _BYTE, UserInputDown AS _BYTE, UserInputLeft AS _BYTE, UserInputRight AS _BYTE, UserInputFire AS _BYTE)
    DIM i AS INTEGER
    DIM AlienFireResult AS INTEGER
    DIM AlienProximity AS INTEGER

    ' Update hero ship based on input
    IF UserInputUp THEN Hero.velocity.y = -HERO_Y_VELOCITY
    IF UserInputDown THEN Hero.velocity.y = HERO_Y_VELOCITY
    IF UserInputLeft THEN Hero.velocity.x = -HERO_X_VELOCITY
    IF UserInputRight THEN Hero.velocity.x = HERO_X_VELOCITY
    UpdateSprite Hero
    Hero.velocity.x = 0
    Hero.velocity.y = 0

    ' Update and cull off-screen hero missiles
    FOR i = 0 TO MAX_HERO_MISSILES - 1
        IF HeroMissile(i).bDraw THEN
            UpdateSprite HeroMissile(i)
            IF HeroMissile(i).position.y < -(HeroMissile(i).size.y + HeroMissile(i).objSpec2) THEN
                HeroMissile(i).bDraw = _FALSE
            END IF
        END IF
    NEXT

    ' Generate hero missiles
    IF UserInputFire AND AllowHeroFire AND Hero.bDraw THEN
        IF CreateHeroMissile(Hero.position.x + HERO_GUN_OFFSET_LEFT, Hero.position.y + HERO_GUN_OFFSET_UP) AND CreateHeroMissile(Hero.position.x + HERO_GUN_OFFSET_RIGHT, Hero.position.y + HERO_GUN_OFFSET_UP) THEN
            _SNDPLAYCOPY LaserSound, , (2 * (Hero.position.x + Hero.size.x / 2) - SCREEN_WIDTH + 1) / (SCREEN_WIDTH - 1)
        END IF
        AllowHeroFire = _FALSE
    END IF

    ' Update and cull off-screen alien missiles
    FOR i = 0 TO MAX_ALIEN_MISSILES - 1
        IF AlienMissile(i).bDraw THEN
            UpdateSprite AlienMissile(i)
            IF AlienMissile(i).position.y > (SCREEN_HEIGHT + AlienMissile(i).size.y + AlienMissile(i).objSpec2) THEN
                AlienMissile(i).bDraw = _FALSE
            END IF
        END IF
    NEXT

    ' Move aliens and handle their AI
    FOR i = 0 TO MAX_ALIENS - 1
        IF Alien(i).bDraw THEN
            IF Alien(i).objSpec1 = 0 THEN
                ' Pick a new horizontal direction
                IF INT(TIMER) MOD 2 THEN
                    Alien(i).velocity.x = RND * ALIEN_X_VELOCITY
                ELSE
                    Alien(i).velocity.x = RND * -ALIEN_X_VELOCITY
                END IF
                Alien(i).objSpec1 = ALIEN_MOVE_TIME_BASE + RND * ALIEN_MOVE_TIME_VAR
            ELSE
                Alien(i).objSpec1 = Alien(i).objSpec1 - 1
            END IF
            UpdateSprite Alien(i)

            ' Wrap around to top if past bottom
            IF Alien(i).position.y > SCREEN_HEIGHT + Alien(i).size.y THEN Alien(i).position.y = -Alien(i).size.y

            ' Fire at hero if not in cooldown
            IF Alien(i).objSpec2 = 0 THEN
                AlienFireResult = RND * 100
                AlienProximity = Alien(i).position.x - Hero.position.x

                IF AlienProximity < 0 THEN AlienProximity = -AlienProximity

                IF ((AlienProximity < ALIEN_PROX_THRESHOLD) AND (AlienFireResult < ALIEN_FIRE_PROB_HERO)) OR (AlienFireResult < ALIEN_FIRE_PROB_RANDOM) THEN
                    CreateAlienMissile Alien(i).position.x + ALIEN_GUN_OFFSET_LEFT, Alien(i).position.y + ALIEN_GUN_OFFSET_DOWN
                    CreateAlienMissile Alien(i).position.x + ALIEN_GUN_OFFSET_RIGHT, Alien(i).position.y + ALIEN_GUN_OFFSET_DOWN
                    Alien(i).objSpec2 = ALIEN_FIRE_LOCKOUT
                    _SNDPLAYCOPY LaserSound, , (2 * (Alien(i).position.x + Alien(i).size.x / 2) - SCREEN_WIDTH + 1) / (SCREEN_WIDTH - 1)
                END IF
            ELSE
                Alien(i).objSpec2 = Alien(i).objSpec2 - 1
            END IF
        END IF
    NEXT

    ' Spawn a new alien if the counter has elapsed
    IF AlienGenCounter = 0 THEN
        CreateAlien
        AlienGenCounter = ALIEN_GEN_RATE_BASE + RND * ALIEN_GEN_RATE_VAR
    ELSE
        AlienGenCounter = AlienGenCounter - 1
    END IF

    ' Advance explosion animations
    FOR i = 0 TO MAX_EXPLOSIONS - 1
        IF Explosion(i).bDraw THEN
            IF Explosion(i).objSpec2 = 0 THEN
                Explosion(i).objSpec1 = Explosion(i).objSpec1 + 1
                Explosion(i).objSpec2 = EXPLOSION_FRAME_REPEAT_COUNT
                IF Explosion(i).objSpec1 >= MAX_EXPLOSION_BITMAPS THEN Explosion(i).bDraw = _FALSE
            ELSE
                Explosion(i).objSpec2 = Explosion(i).objSpec2 - 1
            END IF
        END IF
    NEXT

    ' Adjust scroll speed based on player direction
    IF UserInputUp THEN MapScrollStep = MAP_SCROLL_STEP_FAST ELSE MapScrollStep = MAP_SCROLL_STEP_NORMAL
END SUB

' @brief Checks for collisions between sprites and triggers explosions.
' Tests performed:
'   - Aliens vs. hero
'   - Aliens vs. hero missiles
'   - Hero vs. alien missiles
' @note All tests only run for objects that are currently being drawn (not just active).
SUB CheckCollisions
    DIM AS INTEGER i, j
    DIM AS Rectangle r1, r2

    ' Check hero vs. aliens
    FOR i = 0 TO MAX_ALIENS - 1
        ' Only test if both are currently on screen (they may be active but off screen)
        GetRectangle Hero.position, Hero.size, r1
        GetRectangle Alien(i).position, Alien(i).size, r2
        IF Hero.bDraw AND Alien(i).bDraw AND RectanglesCollide(r1, r2) THEN
            Hero.bDraw = _FALSE
            CreateExplosion Hero.position
            Alien(i).bDraw = _FALSE
            CreateExplosion Alien(i).position
            _SNDPLAYCOPY ExplosionSound, , (2 * (Alien(i).position.x + Alien(i).size.x / 2) - SCREEN_WIDTH + 1) / (SCREEN_WIDTH - 1)
        END IF
    NEXT

    ' Check between aliens and hero missiles
    FOR i = 0 TO MAX_ALIENS - 1
        IF NOT Alien(i).bDraw THEN _CONTINUE

        FOR j = 0 TO MAX_HERO_MISSILES - 1
            ' Short-circuit: skip if missile is off screen
            GetRectangle Alien(i).position, Alien(i).size, r1
            GetRectangle HeroMissile(j).position, HeroMissile(j).size, r2
            IF HeroMissile(j).bDraw AND RectanglesCollide(r1, r2) THEN
                Alien(i).bDraw = _FALSE
                HeroMissile(j).bDraw = _FALSE
                CreateExplosion Alien(i).position
                Score = Score + POINTS_PER_ALIEN
                _SNDPLAYCOPY ExplosionSound, , (2 * (Alien(i).position.x + Alien(i).size.x / 2) - SCREEN_WIDTH + 1) / (SCREEN_WIDTH - 1)
                EXIT FOR ' alien destroyed, stop checking this alien
            END IF
        NEXT
    NEXT

    ' Check hero vs. alien missiles
    FOR i = 0 TO MAX_ALIEN_MISSILES - 1
        GetRectangle Hero.position, Hero.size, r1
        GetRectangle AlienMissile(i).position, AlienMissile(i).size, r2
        IF AlienMissile(i).bDraw AND Hero.bDraw AND RectanglesCollide(r1, r2) THEN
            AlienMissile(i).bDraw = _FALSE
            IF HeroShields <= 0 THEN
                Hero.bDraw = _FALSE
                CreateExplosion Hero.position
                _SNDPLAYCOPY ExplosionSound, , (2 * (Hero.position.x + Hero.size.x / 2) - SCREEN_WIDTH + 1) / (SCREEN_WIDTH - 1)
                EXIT FOR ' player destroyed
            ELSE
                ' Reduce shields (clamp to 0)
                HeroShields = _MAX(0, HeroShields - 5)
            END IF
        END IF
    NEXT
END SUB

' @brief Erases sprites from the screen and deactivates objects no longer being drawn.
' @return _TRUE if the game over condition has been met, _FALSE otherwise.
FUNCTION EraseSprites%%
    DIM i AS INTEGER
    STATIC DeathCounter AS _UNSIGNED INTEGER

    EraseSprites = _FALSE

    ' Deactivate hero if off-screen
    IF Hero.isActive _ANDALSO NOT Hero.bDraw THEN
        Hero.isActive = _FALSE
        DeathCounter = DEATH_DELAY
    END IF

    ' Deactivate hero missiles no longer being drawn
    FOR i = 0 TO MAX_HERO_MISSILES - 1
        IF NOT HeroMissile(i).bDraw THEN
            HeroMissile(i).isActive = _FALSE
        END IF
    NEXT

    ' Deactivate destroyed aliens
    FOR i = 0 TO MAX_ALIENS - 1
        IF NOT Alien(i).bDraw THEN
            Alien(i).isActive = _FALSE
        END IF
    NEXT

    ' Deactivate alien missiles no longer being drawn
    FOR i = 0 TO MAX_ALIEN_MISSILES - 1
        IF NOT AlienMissile(i).bDraw THEN
            AlienMissile(i).isActive = _FALSE
        END IF
    NEXT

    ' Deactivate completed explosions
    FOR i = 0 TO MAX_EXPLOSIONS - 1
        IF NOT Explosion(i).bDraw THEN
            Explosion(i).isActive = _FALSE
        END IF
    NEXT

    ' Signal game over after death delay expires
    IF NOT Hero.isActive THEN
        IF DeathCounter = 0 THEN
            EraseSprites = _TRUE
        ELSE
            DeathCounter = DeathCounter - 1
        END IF
    END IF
END FUNCTION

' @brief Draws all active sprites that are currently on-screen.
SUB DrawSprites
    DIM i AS INTEGER

    ' Draw explosions
    FOR i = 0 TO MAX_EXPLOSIONS - 1
        IF Explosion(i).bDraw THEN
            _PUTIMAGE (Explosion(i).position.x, Explosion(i).position.y), ExplosionBitmap(Explosion(i).objSpec1)
        END IF
    NEXT

    ' Draw hero missiles with trails
    FOR i = 0 TO MAX_HERO_MISSILES - 1
        IF HeroMissile(i).bDraw THEN
            _PUTIMAGE (HeroMissile(i).position.x, HeroMissile(i).position.y), MissileBitmap
            _PUTIMAGE (HeroMissile(i).position.x, HeroMissile(i).position.y + HeroMissile(i).objSpec2), MissileTrailUpBitmap
        END IF
    NEXT

    ' Draw alien missiles with trails
    FOR i = 0 TO MAX_ALIEN_MISSILES - 1
        IF AlienMissile(i).bDraw THEN
            _PUTIMAGE (AlienMissile(i).position.x, AlienMissile(i).position.y), MissileBitmap
            _PUTIMAGE (AlienMissile(i).position.x, AlienMissile(i).position.y - AlienMissile(i).objSpec2), MissileTrailDnBitmap
        END IF
    NEXT

    ' Draw aliens
    FOR i = 0 TO MAX_ALIENS - 1
        IF Alien(i).isActive AND Alien(i).bDraw THEN
            _PUTIMAGE (Alien(i).position.x, Alien(i).position.y), AlienBitmap(GunBlinkState)
        END IF
    NEXT

    ' Draw player
    IF Hero.isActive AND Hero.bDraw THEN
        _PUTIMAGE (Hero.position.x, Hero.position.y), HeroBitmap(GunBlinkState)
    END IF

    ' Toggle gun blink state
    IF GunBlinkCounter = 0 THEN
        GunBlinkState = 1 - GunBlinkState
        GunBlinkCounter = GUN_BLINK_RATE
        AllowHeroFire = _TRUE
    ELSE
        GunBlinkCounter = GunBlinkCounter - 1
    END IF
END SUB

' @brief Performs all program-wide initialization: setup, assets, and sound.
SUB InitializeProgram
    RANDOMIZE TIMER

    ' Set window title
    _TITLE APP_NAME

    ' Load high-score file
    LoadHighScores

    ' Load sound fx and music
    InitializeSound

    ' Initialize graphics
    SCREEN _NEWIMAGE(SCREEN_WIDTH, SCREEN_HEIGHT, 32)

    ' Render text on the hardware screen
    _DISPLAYORDER _HARDWARE , _HARDWARE1 , _GLRENDER , _SOFTWARE

    ' Fullscreen with square pixels (Alt+Enter for windowed)
    _FULLSCREEN _SQUAREPIXELS , _SMOOTH

    ' Transparent text rendering
    _PRINTMODE _KEEPBACKGROUND

    _MOUSEHIDE

    ' Manual frame buffer updates
    _DISPLAY

    ' Load game assets
    InitializeMap
END SUB

' @brief Releases all allocated resources (call before exiting).
SUB FinalizeProgram
    ' Free memory used by assets
    FinalizeMap

    ' Set framebuffer to autoupdate
    _AUTODISPLAY

    ' Release sound resources (including MIDI)
    FinalizeSound

    ' Save high scores
    SaveHighScores
END SUB

' @brief Runs the main game loop: input, update, render, repeat until game over.
SUB RunGame
    DIM AS _BYTE UserInputUp, UserInputDown, UserInputLeft, UserInputRight, UserInputFire, GameOver

    InitializeHUD
    InitializeSprites

    Score = 0
    AlienGenCounter = ALIEN_GEN_RATE_BASE
    HeroShields = MAX_HERO_SHIELDS

    PlayMIDIFile "dat/sfx/mus/alienmain.mid"

    GameOver = _FALSE

    DO
        ' Read input and check for quit
        GameOver = GetInput(UserInputUp, UserInputDown, UserInputLeft, UserInputRight, UserInputFire)

        MoveSprites UserInputUp, UserInputDown, UserInputLeft, UserInputRight, UserInputFire
        CheckCollisions
        GameOver = GameOver OR EraseSprites

        ' Render frame
        CLS , 0
        UpdateMap
        DrawMap
        DrawSprites
        DrawHUD

        IF ShowFPS THEN _PRINTSTRING (0, 0), STR$(GetFPS) + " FPS"

        ' Page flip
        _DISPLAY

        IF NOT NoLimit THEN _LIMIT UPDATES_PER_SECOND
    LOOP WHILE NOT GameOver

    FinalizeSprites
    FinalizeHUD
END SUB

'-----------------------------------------------------------------------------------------------------------------------
' Program entry point: initialize, display intro/title screens, and handle the main menu
'-----------------------------------------------------------------------------------------------------------------------
DIM DrawTitle AS _BYTE
DIM k AS _UNSIGNED LONG

' Show the title page on first iteration
DrawTitle = _TRUE
InitializeProgram
' Display intro credits
DisplayIntroCredits
' Clear keyboard and mouse
ClearInput

' Main menu loop
DO
    ' Draw title page (only if required)
    IF DrawTitle THEN
        DisplayTitlePage
        DrawTitle = _FALSE
    END IF

    ' Get a key from the user
    k = _KEYHIT

    ' Check what key was press and action it
    SELECT CASE k
        CASE _KEY_ESC, KEY_LOWER_Q, KEY_UPPER_Q
            EXIT DO

        CASE KEY_LOWER_K, KEY_UPPER_K, KEY_LOWER_M, KEY_UPPER_M, KEY_LOWER_J, KEY_UPPER_J, _KEY_ENTER
            RunGame
            NewHighScore Score
            ClearInput
            DrawTitle = _TRUE

        CASE KEY_LOWER_S, KEY_UPPER_S
            DisplayHighScoresScreen
            ClearInput
            DrawTitle = _TRUE

        CASE _KEY_F1
            ShowFPS = NOT ShowFPS

        CASE _KEY_F7
            NoLimit = NOT NoLimit

        CASE ELSE
            DrawTitle = _FALSE
    END SELECT
LOOP

' Fade out
FadeScreen _FALSE, UPDATES_PER_SECOND * 2, 100

' Release all resources
FinalizeProgram

SYSTEM

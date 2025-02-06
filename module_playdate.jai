//
// This file was auto-generated using the following command:
//
// jai ./generate.jai
//



TARGET_EXTENSION :: 1;
LCD_COLUMNS :: 400;
LCD_ROWS :: 240;
LCD_ROWSIZE :: 52;

SEEK_SET :: 0;
SEEK_CUR :: 1;
SEEK_END :: 2;

AUDIO_FRAMES_PER_CYCLE :: 512;

NOTE_C4 :: 60;

LCDRect :: struct {
    left:   s32 #align 4;
    right:  s32 #align 4; // not inclusive
    top:    s32 #align 4;
    bottom: s32 #align 4; // not inclusive
}

LCDMakeRect :: (x: s32, y: s32, width: s32, height: s32) -> LCDRect #foreign ;

LCDRect_translate :: (r: LCDRect, dx: s32, dy: s32) -> LCDRect #foreign ;

LCDBitmapDrawMode :: enum s32 {
    Copy             :: 0;
    WhiteTransparent :: 1;
    BlackTransparent :: 2;
    FillWhite        :: 3;
    FillBlack        :: 4;
    XOR              :: 5;
    NXOR             :: 6;
    Inverted         :: 7;

    kDrawModeCopy             :: Copy;
    kDrawModeWhiteTransparent :: WhiteTransparent;
    kDrawModeBlackTransparent :: BlackTransparent;
    kDrawModeFillWhite        :: FillWhite;
    kDrawModeFillBlack        :: FillBlack;
    kDrawModeXOR              :: XOR;
    kDrawModeNXOR             :: NXOR;
    kDrawModeInverted         :: Inverted;
}

LCDBitmapFlip :: enum s32 {
    Unflipped :: 0;
    FlippedX  :: 1;
    FlippedY  :: 2;
    FlippedXY :: 3;

    kBitmapUnflipped :: Unflipped;
    kBitmapFlippedX  :: FlippedX;
    kBitmapFlippedY  :: FlippedY;
    kBitmapFlippedXY :: FlippedXY;
}

LCDSolidColor :: enum s32 {
    Black :: 0;
    White :: 1;
    Clear :: 2;
    XOR   :: 3;

    kColorBlack :: Black;
    kColorWhite :: White;
    kColorClear :: Clear;
    kColorXOR   :: XOR;
}

LCDLineCapStyle :: enum s32 {
    Butt   :: 0;
    Square :: 1;
    Round  :: 2;

    kLineCapStyleButt   :: Butt;
    kLineCapStyleSquare :: Square;
    kLineCapStyleRound  :: Round;
}

LCDFontLanguage :: enum s32 {
    English  :: 0;
    Japanese :: 1;
    Unknown  :: 2;

    kLCDFontLanguageEnglish  :: English;
    kLCDFontLanguageJapanese :: Japanese;
    kLCDFontLanguageUnknown  :: Unknown;
}

PDStringEncoding :: enum s32 {
    ASCIIEncoding    :: 0;
    UTF8Encoding     :: 1;
    _16BitLEEncoding :: 2;

    kASCIIEncoding   :: ASCIIEncoding;
    kUTF8Encoding    :: UTF8Encoding;
    k16BitLEEncoding :: _16BitLEEncoding;
}

LCDPattern :: [16] u8;
LCDColor :: u32;

LCDPolygonFillRule :: enum s32 {
    NonZero :: 0;
    EvenOdd :: 1;

    kPolygonFillNonZero :: NonZero;
    kPolygonFillEvenOdd :: EvenOdd;
}

PDTextWrappingMode :: enum s32 {
    Clip      :: 0;
    Character :: 1;
    Word      :: 2;

    kWrapClip      :: Clip;
    kWrapCharacter :: Character;
    kWrapWord      :: Word;
}

PDTextAlignment :: enum s32 {
    Left   :: 0;
    Center :: 1;
    Right  :: 2;

    kAlignTextLeft   :: Left;
    kAlignTextCenter :: Center;
    kAlignTextRight  :: Right;
}

LCDBitmap :: struct {}
LCDBitmapTable :: struct {}
LCDFont :: struct {}
LCDFontData :: struct {}
LCDFontPage :: struct {}
LCDFontGlyph :: struct {}
LCDVideoPlayer :: struct {}

playdate_video :: struct {
    __loadVideo: u32 #align 4;
    __freePlayer: u32 #align 4;
    __setContext: u32 #align 4;
    __useScreenContext: u32 #align 4;
    __renderFrame: u32 #align 4;
    __getError: u32 #align 4;
    __getInfo: u32 #align 4;
    __getContext: u32 #align 4;

#place __loadVideo;
    loadVideo:        #type (path: *u8) -> *LCDVideoPlayer #c_call = --- #align 4;
#place __freePlayer;
    freePlayer:       #type (p: *LCDVideoPlayer) -> void #c_call = --- #align 4;
#place __setContext;
    setContext:       #type (p: *LCDVideoPlayer, _context: *LCDBitmap) -> s32 #c_call = --- #align 4;
#place __useScreenContext;
    useScreenContext: #type (p: *LCDVideoPlayer) -> void #c_call = --- #align 4;
#place __renderFrame;
    renderFrame:      #type (p: *LCDVideoPlayer, n: s32) -> s32 #c_call = --- #align 4;
#place __getError;
    getError:         #type (p: *LCDVideoPlayer) -> *u8 #c_call = --- #align 4;
#place __getInfo;
    getInfo:          #type (p: *LCDVideoPlayer, outWidth: *s32, outHeight: *s32, outFrameRate: *float, outFrameCount: *s32, outCurrentFrame: *s32) -> void #c_call = --- #align 4;
#place __getContext;
    getContext:       #type (p: *LCDVideoPlayer) -> *LCDBitmap #c_call = --- #align 4;
}

playdate_graphics :: struct {
    __video: u32 #align 4;
    __clear: u32 #align 4;
    __setBackgroundColor: u32 #align 4;
    __setStencil: u32 #align 4;
    __setDrawMode: u32 #align 4;
    __setDrawOffset: u32 #align 4;
    __setClipRect: u32 #align 4;
    __clearClipRect: u32 #align 4;
    __setLineCapStyle: u32 #align 4;
    __setFont: u32 #align 4;
    __setTextTracking: u32 #align 4;
    __pushContext: u32 #align 4;
    __popContext: u32 #align 4;
    __drawBitmap: u32 #align 4;
    __tileBitmap: u32 #align 4;
    __drawLine: u32 #align 4;
    __fillTriangle: u32 #align 4;
    __drawRect: u32 #align 4;
    __fillRect: u32 #align 4;
    __drawEllipse: u32 #align 4;
    __fillEllipse: u32 #align 4;
    __drawScaledBitmap: u32 #align 4;
    __drawText: u32 #align 4;
    __newBitmap: u32 #align 4;
    __freeBitmap: u32 #align 4;
    __loadBitmap: u32 #align 4;
    __copyBitmap: u32 #align 4;
    __loadIntoBitmap: u32 #align 4;
    __getBitmapData: u32 #align 4;
    __clearBitmap: u32 #align 4;
    __rotatedBitmap: u32 #align 4;
    __newBitmapTable: u32 #align 4;
    __freeBitmapTable: u32 #align 4;
    __loadBitmapTable: u32 #align 4;
    __loadIntoBitmapTable: u32 #align 4;
    __getTableBitmap: u32 #align 4;
    __loadFont: u32 #align 4;
    __getFontPage: u32 #align 4;
    __getPageGlyph: u32 #align 4;
    __getGlyphKerning: u32 #align 4;
    __getTextWidth: u32 #align 4;
    __getFrame: u32 #align 4;
    __getDisplayFrame: u32 #align 4;
    __getDebugBitmap: u32 #align 4;
    __copyFrameBufferBitmap: u32 #align 4;
    __markUpdatedRows: u32 #align 4;
    __display: u32 #align 4;
    __setColorToPattern: u32 #align 4;
    __checkMaskCollision: u32 #align 4;
    __setScreenClipRect: u32 #align 4;
    __fillPolygon: u32 #align 4;
    __getFontHeight: u32 #align 4;
    __getDisplayBufferBitmap: u32 #align 4;
    __drawRotatedBitmap: u32 #align 4;
    __setTextLeading: u32 #align 4;
    __setBitmapMask: u32 #align 4;
    __getBitmapMask: u32 #align 4;
    __setStencilImage: u32 #align 4;
    __makeFontFromData: u32 #align 4;
    __getTextTracking: u32 #align 4;
    __setPixel: u32 #align 4;
    __getBitmapPixel: u32 #align 4;
    __getBitmapTableInfo: u32 #align 4;
    __drawTextInRect: u32 #align 4;

#place __video;
    video:                  *playdate_video = --- #align 4;

    // Drawing Functions
#place __clear;
    clear:                  #type (color: LCDColor) -> void #c_call = --- #align 4;
#place __setBackgroundColor;
    setBackgroundColor:     #type (color: LCDSolidColor) -> void #c_call = --- #align 4;
#place __setStencil;
    setStencil:             #type (stencil: *LCDBitmap) -> void #c_call = --- #align 4; // deprecated in favor of setStencilImage, which adds a "tile" flag
#place __setDrawMode;
    setDrawMode:            #type (mode: LCDBitmapDrawMode) -> LCDBitmapDrawMode #c_call = --- #align 4;
#place __setDrawOffset;
    setDrawOffset:          #type (dx: s32, dy: s32) -> void #c_call = --- #align 4;
#place __setClipRect;
    setClipRect:            #type (x: s32, y: s32, width: s32, height: s32) -> void #c_call = --- #align 4;
#place __clearClipRect;
    clearClipRect:          #type () -> void #c_call = --- #align 4;
#place __setLineCapStyle;
    setLineCapStyle:        #type (endCapStyle: LCDLineCapStyle) -> void #c_call = --- #align 4;
#place __setFont;
    setFont:                #type (font: *LCDFont) -> void #c_call = --- #align 4;
#place __setTextTracking;
    setTextTracking:        #type (tracking: s32) -> void #c_call = --- #align 4;
#place __pushContext;
    pushContext:            #type (target: *LCDBitmap) -> void #c_call = --- #align 4;
#place __popContext;
    popContext:             #type () -> void #c_call = --- #align 4;

#place __drawBitmap;
    drawBitmap:             #type (bitmap: *LCDBitmap, x: s32, y: s32, flip: LCDBitmapFlip) -> void #c_call = --- #align 4;
#place __tileBitmap;
    tileBitmap:             #type (bitmap: *LCDBitmap, x: s32, y: s32, width: s32, height: s32, flip: LCDBitmapFlip) -> void #c_call = --- #align 4;
#place __drawLine;
    drawLine:               #type (x1: s32, y1: s32, x2: s32, y2: s32, width: s32, color: LCDColor) -> void #c_call = --- #align 4;
#place __fillTriangle;
    fillTriangle:           #type (x1: s32, y1: s32, x2: s32, y2: s32, x3: s32, y3: s32, color: LCDColor) -> void #c_call = --- #align 4;
#place __drawRect;
    drawRect:               #type (x: s32, y: s32, width: s32, height: s32, color: LCDColor) -> void #c_call = --- #align 4;
#place __fillRect;
    fillRect:               #type (x: s32, y: s32, width: s32, height: s32, color: LCDColor) -> void #c_call = --- #align 4;
#place __drawEllipse;
    drawEllipse:            #type (x: s32, y: s32, width: s32, height: s32, lineWidth: s32, startAngle: float, endAngle: float, color: LCDColor) -> void #c_call = --- #align 4; // stroked inside the rect
#place __fillEllipse;
    fillEllipse:            #type (x: s32, y: s32, width: s32, height: s32, startAngle: float, endAngle: float, color: LCDColor) -> void #c_call = --- #align 4;
#place __drawScaledBitmap;
    drawScaledBitmap:       #type (bitmap: *LCDBitmap, x: s32, y: s32, xscale: float, yscale: float) -> void #c_call = --- #align 4;
#place __drawText;
    drawText:               #type (text: *void, len: u32, encoding: PDStringEncoding, x: s32, y: s32) -> s32 #c_call = --- #align 4;

    // LCDBitmap
#place __newBitmap;
    newBitmap:              #type (width: s32, height: s32, bgcolor: LCDColor) -> *LCDBitmap #c_call = --- #align 4;
#place __freeBitmap;
    freeBitmap:             #type (unknown0: *LCDBitmap) -> void #c_call = --- #align 4;
#place __loadBitmap;
    loadBitmap:             #type (path: *u8, outerr: **u8) -> *LCDBitmap #c_call = --- #align 4;
#place __copyBitmap;
    copyBitmap:             #type (bitmap: *LCDBitmap) -> *LCDBitmap #c_call = --- #align 4;
#place __loadIntoBitmap;
    loadIntoBitmap:         #type (path: *u8, bitmap: *LCDBitmap, outerr: **u8) -> void #c_call = --- #align 4;
#place __getBitmapData;
    getBitmapData:          #type (bitmap: *LCDBitmap, width: *s32, height: *s32, rowbytes: *s32, mask: **u8, data: **u8) -> void #c_call = --- #align 4;
#place __clearBitmap;
    clearBitmap:            #type (bitmap: *LCDBitmap, bgcolor: LCDColor) -> void #c_call = --- #align 4;
#place __rotatedBitmap;
    rotatedBitmap:          #type (bitmap: *LCDBitmap, rotation: float, xscale: float, yscale: float, allocedSize: *s32) -> *LCDBitmap #c_call = --- #align 4;

    // LCDBitmapTable
#place __newBitmapTable;
    newBitmapTable:         #type (count: s32, width: s32, height: s32) -> *LCDBitmapTable #c_call = --- #align 4;
#place __freeBitmapTable;
    freeBitmapTable:        #type (table: *LCDBitmapTable) -> void #c_call = --- #align 4;
#place __loadBitmapTable;
    loadBitmapTable:        #type (path: *u8, outerr: **u8) -> *LCDBitmapTable #c_call = --- #align 4;
#place __loadIntoBitmapTable;
    loadIntoBitmapTable:    #type (path: *u8, table: *LCDBitmapTable, outerr: **u8) -> void #c_call = --- #align 4;
#place __getTableBitmap;
    getTableBitmap:         #type (table: *LCDBitmapTable, idx: s32) -> *LCDBitmap #c_call = --- #align 4;

    // LCDFont
#place __loadFont;
    loadFont:               #type (path: *u8, outErr: **u8) -> *LCDFont #c_call = --- #align 4;
#place __getFontPage;
    getFontPage:            #type (font: *LCDFont, c: u32) -> *LCDFontPage #c_call = --- #align 4;
#place __getPageGlyph;
    getPageGlyph:           #type (page: *LCDFontPage, c: u32, bitmap: **LCDBitmap, advance: *s32) -> *LCDFontGlyph #c_call = --- #align 4;
#place __getGlyphKerning;
    getGlyphKerning:        #type (glyph: *LCDFontGlyph, glyphcode: u32, nextcode: u32) -> s32 #c_call = --- #align 4;
#place __getTextWidth;
    getTextWidth:           #type (font: *LCDFont, text: *void, len: u32, encoding: PDStringEncoding, tracking: s32) -> s32 #c_call = --- #align 4;

#place __getFrame;
    getFrame:               #type () -> *u8 #c_call = --- #align 4; // row stride = LCD_ROWSIZE
#place __getDisplayFrame;
    getDisplayFrame:        #type () -> *u8 #c_call = --- #align 4; // row stride = LCD_ROWSIZE
#place __getDebugBitmap;
    getDebugBitmap:         #type () -> *LCDBitmap #c_call = --- #align 4; // valid in simulator only, function is NULL on device
#place __copyFrameBufferBitmap;
    copyFrameBufferBitmap:  #type () -> *LCDBitmap #c_call = --- #align 4;
#place __markUpdatedRows;
    markUpdatedRows:        #type (start: s32, end: s32) -> void #c_call = --- #align 4;
#place __display;
    display:                #type () -> void #c_call = --- #align 4;

    // misc util.
#place __setColorToPattern;
    setColorToPattern:      #type (color: *LCDColor, bitmap: *LCDBitmap, x: s32, y: s32) -> void #c_call = --- #align 4;
#place __checkMaskCollision;
    checkMaskCollision:     #type (bitmap1: *LCDBitmap, x1: s32, y1: s32, flip1: LCDBitmapFlip, bitmap2: *LCDBitmap, x2: s32, y2: s32, flip2: LCDBitmapFlip, rect: LCDRect) -> s32 #c_call = --- #align 4;

    // 1.1
#place __setScreenClipRect;
    setScreenClipRect:      #type (x: s32, y: s32, width: s32, height: s32) -> void #c_call = --- #align 4;

    // 1.1.1
#place __fillPolygon;
    fillPolygon:            #type (nPoints: s32, coords: *s32, color: LCDColor, fillrule: LCDPolygonFillRule) -> void #c_call = --- #align 4;
#place __getFontHeight;
    getFontHeight:          #type (font: *LCDFont) -> u8 #c_call = --- #align 4;

    // 1.7
#place __getDisplayBufferBitmap;
    getDisplayBufferBitmap: #type () -> *LCDBitmap #c_call = --- #align 4;
#place __drawRotatedBitmap;
    drawRotatedBitmap:      #type (bitmap: *LCDBitmap, x: s32, y: s32, rotation: float, centerx: float, centery: float, xscale: float, yscale: float) -> void #c_call = --- #align 4;
#place __setTextLeading;
    setTextLeading:         #type (lineHeightAdustment: s32) -> void #c_call = --- #align 4;

    // 1.8
#place __setBitmapMask;
    setBitmapMask:          #type (bitmap: *LCDBitmap, mask: *LCDBitmap) -> s32 #c_call = --- #align 4;
#place __getBitmapMask;
    getBitmapMask:          #type (bitmap: *LCDBitmap) -> *LCDBitmap #c_call = --- #align 4;

    // 1.10
#place __setStencilImage;
    setStencilImage:        #type (stencil: *LCDBitmap, tile: s32) -> void #c_call = --- #align 4;

    // 1.12
#place __makeFontFromData;
    makeFontFromData:       #type (data: *LCDFontData, wide: s32) -> *LCDFont #c_call = --- #align 4;

    // 2.1
#place __getTextTracking;
    getTextTracking:        #type () -> s32 #c_call = --- #align 4;

    // 2.5
#place __setPixel;
    setPixel:               #type (x: s32, y: s32, c: LCDColor) -> void #c_call = --- #align 4;
#place __getBitmapPixel;
    getBitmapPixel:         #type (bitmap: *LCDBitmap, x: s32, y: s32) -> LCDSolidColor #c_call = --- #align 4;
#place __getBitmapTableInfo;
    getBitmapTableInfo:     #type (table: *LCDBitmapTable, count: *s32, width: *s32) -> void #c_call = --- #align 4;

    // 2.6
#place __drawTextInRect;
    drawTextInRect:         #type (text: *void, len: u32, encoding: PDStringEncoding, x: s32, y: s32, width: s32, height: s32, wrap: PDTextWrappingMode, align: PDTextAlignment) -> void #c_call = --- #align 4;
}

PDButtons :: enum s32 {
    Left  :: 1;
    Right :: 2;
    Up    :: 4;
    Down  :: 8;
    B     :: 16;
    A     :: 32;

    kButtonLeft  :: Left;
    kButtonRight :: Right;
    kButtonUp    :: Up;
    kButtonDown  :: Down;
    kButtonB     :: B;
    kButtonA     :: A;
}

PDLanguage :: enum s32 {
    English  :: 0;
    Japanese :: 1;
    Unknown  :: 2;

    kPDLanguageEnglish  :: English;
    kPDLanguageJapanese :: Japanese;
    kPDLanguageUnknown  :: Unknown;
}

PDDateTime :: struct {
    year:    u16 #align 2;
    month:   u8 #align 2; // 1-12
    day:     u8 #align 2; // 1-31
    weekday: u8 #align 2; // 1=monday-7=sunday
    hour:    u8 #align 2; // 0-23
    minute:  u8 #align 2;
    second:  u8 #align 2;
}

PDMenuItem :: struct {}

PDPeripherals :: enum s32 {
    None           :: 0;
    Accelerometer  :: 1;

    AllPeripherals :: 65535;

    kNone           :: None;
    kAccelerometer  :: Accelerometer;

    kAllPeripherals :: AllPeripherals;
}

PDCallbackFunction :: #type (userdata: *void) -> s32 #c_call;
PDMenuItemCallbackFunction :: #type (userdata: *void) -> void #c_call;
PDButtonCallbackFunction :: #type (button: PDButtons, down: s32, when: u32, userdata: *void) -> s32 #c_call;

playdate_sys :: struct {
    __realloc: u32 #align 4;
    __formatString: u32 #align 4;
    __logToConsole: u32 #align 4;
    __error: u32 #align 4;
    __getLanguage: u32 #align 4;
    __getCurrentTimeMilliseconds: u32 #align 4;
    __getSecondsSinceEpoch: u32 #align 4;
    __drawFPS: u32 #align 4;
    __setUpdateCallback: u32 #align 4;
    __getButtonState: u32 #align 4;
    __setPeripheralsEnabled: u32 #align 4;
    __getAccelerometer: u32 #align 4;
    __getCrankChange: u32 #align 4;
    __getCrankAngle: u32 #align 4;
    __isCrankDocked: u32 #align 4;
    __setCrankSoundsDisabled: u32 #align 4;
    __getFlipped: u32 #align 4;
    __setAutoLockDisabled: u32 #align 4;
    __setMenuImage: u32 #align 4;
    __addMenuItem: u32 #align 4;
    __addCheckmarkMenuItem: u32 #align 4;
    __addOptionsMenuItem: u32 #align 4;
    __removeAllMenuItems: u32 #align 4;
    __removeMenuItem: u32 #align 4;
    __getMenuItemValue: u32 #align 4;
    __setMenuItemValue: u32 #align 4;
    __getMenuItemTitle: u32 #align 4;
    __setMenuItemTitle: u32 #align 4;
    __getMenuItemUserdata: u32 #align 4;
    __setMenuItemUserdata: u32 #align 4;
    __getReduceFlashing: u32 #align 4;
    __getElapsedTime: u32 #align 4;
    __resetElapsedTime: u32 #align 4;
    __getBatteryPercentage: u32 #align 4;
    __getBatteryVoltage: u32 #align 4;
    __getTimezoneOffset: u32 #align 4;
    __shouldDisplay24HourTime: u32 #align 4;
    __convertEpochToDateTime: u32 #align 4;
    __convertDateTimeToEpoch: u32 #align 4;
    __clearICache: u32 #align 4;
    __setButtonCallback: u32 #align 4;
    __setSerialMessageCallback: u32 #align 4;
    __vaFormatString: u32 #align 4;
    __parseString: u32 #align 4;

#place __realloc;
    realloc:                    #type (ptr: *void, size: u32) -> *void #c_call = --- #align 4; // ptr = NULL -> malloc, size = 0 -> free
#place __formatString;
    formatString:               #type (ret: **u8, fmt: *u8, __args: ..Any) -> s32 #c_call = --- #align 4;
#place __logToConsole;
    logToConsole:               #type (fmt: *u8, __args: ..Any) -> void #c_call = --- #align 4;
#place __error;
    error:                      #type (fmt: *u8, __args: ..Any) -> void #c_call = --- #align 4;
#place __getLanguage;
    getLanguage:                #type () -> PDLanguage #c_call = --- #align 4;
#place __getCurrentTimeMilliseconds;
    getCurrentTimeMilliseconds: #type () -> u32 #c_call = --- #align 4;
#place __getSecondsSinceEpoch;
    getSecondsSinceEpoch:       #type (milliseconds: *u32) -> u32 #c_call = --- #align 4;
#place __drawFPS;
    drawFPS:                    #type (x: s32, y: s32) -> void #c_call = --- #align 4;

#place __setUpdateCallback;
    setUpdateCallback:          #type (update: PDCallbackFunction, userdata: *void) -> void #c_call = --- #align 4;
#place __getButtonState;
    getButtonState:             #type (current: *PDButtons, pushed: *PDButtons, released: *PDButtons) -> void #c_call = --- #align 4;
#place __setPeripheralsEnabled;
    setPeripheralsEnabled:      #type (mask: PDPeripherals) -> void #c_call = --- #align 4;
#place __getAccelerometer;
    getAccelerometer:           #type (outx: *float, outy: *float, outz: *float) -> void #c_call = --- #align 4;

#place __getCrankChange;
    getCrankChange:             #type () -> float #c_call = --- #align 4;
#place __getCrankAngle;
    getCrankAngle:              #type () -> float #c_call = --- #align 4;
#place __isCrankDocked;
    isCrankDocked:              #type () -> s32 #c_call = --- #align 4;
#place __setCrankSoundsDisabled;
    setCrankSoundsDisabled:     #type (flag: s32) -> s32 #c_call = --- #align 4; // returns previous setting

#place __getFlipped;
    getFlipped:                 #type () -> s32 #c_call = --- #align 4;
#place __setAutoLockDisabled;
    setAutoLockDisabled:        #type (disable: s32) -> void #c_call = --- #align 4;

#place __setMenuImage;
    setMenuImage:               #type (bitmap: *LCDBitmap, xOffset: s32) -> void #c_call = --- #align 4;
#place __addMenuItem;
    addMenuItem:                #type (title: *u8, callback: PDMenuItemCallbackFunction, userdata: *void) -> *PDMenuItem #c_call = --- #align 4;
#place __addCheckmarkMenuItem;
    addCheckmarkMenuItem:       #type (title: *u8, value: s32, callback: PDMenuItemCallbackFunction, userdata: *void) -> *PDMenuItem #c_call = --- #align 4;
#place __addOptionsMenuItem;
    addOptionsMenuItem:         #type (title: *u8, optionTitles: **u8, optionsCount: s32, f: PDMenuItemCallbackFunction, userdata: *void) -> *PDMenuItem #c_call = --- #align 4;
#place __removeAllMenuItems;
    removeAllMenuItems:         #type () -> void #c_call = --- #align 4;
#place __removeMenuItem;
    removeMenuItem:             #type (menuItem: *PDMenuItem) -> void #c_call = --- #align 4;
#place __getMenuItemValue;
    getMenuItemValue:           #type (menuItem: *PDMenuItem) -> s32 #c_call = --- #align 4;
#place __setMenuItemValue;
    setMenuItemValue:           #type (menuItem: *PDMenuItem, value: s32) -> void #c_call = --- #align 4;
#place __getMenuItemTitle;
    getMenuItemTitle:           #type (menuItem: *PDMenuItem) -> *u8 #c_call = --- #align 4;
#place __setMenuItemTitle;
    setMenuItemTitle:           #type (menuItem: *PDMenuItem, title: *u8) -> void #c_call = --- #align 4;
#place __getMenuItemUserdata;
    getMenuItemUserdata:        #type (menuItem: *PDMenuItem) -> *void #c_call = --- #align 4;
#place __setMenuItemUserdata;
    setMenuItemUserdata:        #type (menuItem: *PDMenuItem, ud: *void) -> void #c_call = --- #align 4;

#place __getReduceFlashing;
    getReduceFlashing:          #type () -> s32 #c_call = --- #align 4;

    // 1.1
#place __getElapsedTime;
    getElapsedTime:             #type () -> float #c_call = --- #align 4;
#place __resetElapsedTime;
    resetElapsedTime:           #type () -> void #c_call = --- #align 4;

    // 1.4
#place __getBatteryPercentage;
    getBatteryPercentage:       #type () -> float #c_call = --- #align 4;
#place __getBatteryVoltage;
    getBatteryVoltage:          #type () -> float #c_call = --- #align 4;

    // 1.13
#place __getTimezoneOffset;
    getTimezoneOffset:          #type () -> s32 #c_call = --- #align 4;
#place __shouldDisplay24HourTime;
    shouldDisplay24HourTime:    #type () -> s32 #c_call = --- #align 4;
#place __convertEpochToDateTime;
    convertEpochToDateTime:     #type (epoch: u32, datetime: *PDDateTime) -> void #c_call = --- #align 4;
#place __convertDateTimeToEpoch;
    convertDateTimeToEpoch:     #type (datetime: *PDDateTime) -> u32 #c_call = --- #align 4;

    // 2.0
#place __clearICache;
    clearICache:                #type () -> void #c_call = --- #align 4;

    // 2.4
#place __setButtonCallback;
    setButtonCallback:          #type (cb: PDButtonCallbackFunction, buttonud: *void, queuesize: s32) -> void #c_call = --- #align 4;
#place __setSerialMessageCallback;
    setSerialMessageCallback:   #type (callback: #type (data: *u8) -> void #c_call) -> void #c_call = --- #align 4;
#place __vaFormatString;
    vaFormatString:             *void /* function type contained C va_list argument */;
#place __parseString;
    parseString:                #type (str: *u8, format: *u8, __args: ..Any) -> s32 #c_call = --- #align 4;
}

lua_State :: *void;
lua_CFunction :: #type (L: *lua_State) -> s32 #c_call;

LuaUDObject :: struct {}
LCDSprite :: struct {}

l_valtype :: enum s32 {
    Int   :: 0;
    Float :: 1;
    Str   :: 2;
    kInt   :: Int;
    kFloat :: Float;
    kStr   :: Str;
}

lua_reg :: struct {
    __name: u32 #align 4;
    __func: u32 #align 4;

#place __name;
    name: *u8 = --- #align 4;
#place __func;
    func: lua_CFunction = --- #align 4;
}

LuaType :: enum s32 {
    Nil      :: 0;
    Bool     :: 1;
    Int      :: 2;
    Float    :: 3;
    String   :: 4;
    Table    :: 5;
    Function :: 6;
    Thread   :: 7;
    Object   :: 8;

    kTypeNil      :: Nil;
    kTypeBool     :: Bool;
    kTypeInt      :: Int;
    kTypeFloat    :: Float;
    kTypeString   :: String;
    kTypeTable    :: Table;
    kTypeFunction :: Function;
    kTypeThread   :: Thread;
    kTypeObject   :: Object;
}

lua_val :: struct {
    __name: u32 #align 4;
    __type: u32 #align 4;
    __v: u32 #align 4;

#place __name;
    name: *u8 = --- #align 4;
#place __type;
    type: l_valtype = --- #align 4;
#place __v;
    v:    union {
        intval:   u32;
        floatval: float;
        strval:   *u8;
    } = --- #align 4;
}

playdate_lua :: struct {
    __addFunction: u32 #align 4;
    __registerClass: u32 #align 4;
    __pushFunction: u32 #align 4;
    __indexMetatable: u32 #align 4;
    __stop: u32 #align 4;
    __start: u32 #align 4;
    __getArgCount: u32 #align 4;
    __getArgType: u32 #align 4;
    __argIsNil: u32 #align 4;
    __getArgBool: u32 #align 4;
    __getArgInt: u32 #align 4;
    __getArgFloat: u32 #align 4;
    __getArgString: u32 #align 4;
    __getArgBytes: u32 #align 4;
    __getArgObject: u32 #align 4;
    __getBitmap: u32 #align 4;
    __getSprite: u32 #align 4;
    __pushNil: u32 #align 4;
    __pushBool: u32 #align 4;
    __pushInt: u32 #align 4;
    __pushFloat: u32 #align 4;
    __pushString: u32 #align 4;
    __pushBytes: u32 #align 4;
    __pushBitmap: u32 #align 4;
    __pushSprite: u32 #align 4;
    __pushObject: u32 #align 4;
    __retainObject: u32 #align 4;
    __releaseObject: u32 #align 4;
    __setUserValue: u32 #align 4;
    __getUserValue: u32 #align 4;
    __callFunction_deprecated: u32 #align 4;
    __callFunction: u32 #align 4;

    // these two return 1 on success, else 0 with an error message in outErr
#place __addFunction;
    addFunction:             #type (f: lua_CFunction, name: *u8, outErr: **u8) -> s32 #c_call = --- #align 4;
#place __registerClass;
    registerClass:           #type (name: *u8, reg: *lua_reg, vals: *lua_val, isstatic: s32, outErr: **u8) -> s32 #c_call = --- #align 4;

#place __pushFunction;
    pushFunction:            #type (f: lua_CFunction) -> void #c_call = --- #align 4;
#place __indexMetatable;
    indexMetatable:          #type () -> s32 #c_call = --- #align 4;

#place __stop;
    stop:                    #type () -> void #c_call = --- #align 4;
#place __start;
    start:                   #type () -> void #c_call = --- #align 4;

    // stack operations
#place __getArgCount;
    getArgCount:             #type () -> s32 #c_call = --- #align 4;
#place __getArgType;
    getArgType:              #type (pos: s32, outClass: **u8) -> LuaType #c_call = --- #align 4;

#place __argIsNil;
    argIsNil:                #type (pos: s32) -> s32 #c_call = --- #align 4;
#place __getArgBool;
    getArgBool:              #type (pos: s32) -> s32 #c_call = --- #align 4;
#place __getArgInt;
    getArgInt:               #type (pos: s32) -> s32 #c_call = --- #align 4;
#place __getArgFloat;
    getArgFloat:             #type (pos: s32) -> float #c_call = --- #align 4;
#place __getArgString;
    getArgString:            #type (pos: s32) -> *u8 #c_call = --- #align 4;
#place __getArgBytes;
    getArgBytes:             #type (pos: s32, outlen: *u32) -> *u8 #c_call = --- #align 4;
#place __getArgObject;
    getArgObject:            #type (pos: s32, type: *u8, outud: **LuaUDObject) -> *void #c_call = --- #align 4;

#place __getBitmap;
    getBitmap:               #type (pos: s32) -> *LCDBitmap #c_call = --- #align 4;
#place __getSprite;
    getSprite:               #type (pos: s32) -> *LCDSprite #c_call = --- #align 4;

    // for returning values back to Lua
#place __pushNil;
    pushNil:                 #type () -> void #c_call = --- #align 4;
#place __pushBool;
    pushBool:                #type (val: s32) -> void #c_call = --- #align 4;
#place __pushInt;
    pushInt:                 #type (val: s32) -> void #c_call = --- #align 4;
#place __pushFloat;
    pushFloat:               #type (val: float) -> void #c_call = --- #align 4;
#place __pushString;
    pushString:              #type (str: *u8) -> void #c_call = --- #align 4;
#place __pushBytes;
    pushBytes:               #type (str: *u8, len: u32) -> void #c_call = --- #align 4;
#place __pushBitmap;
    pushBitmap:              #type (bitmap: *LCDBitmap) -> void #c_call = --- #align 4;
#place __pushSprite;
    pushSprite:              #type (sprite: *LCDSprite) -> void #c_call = --- #align 4;

#place __pushObject;
    pushObject:              #type (obj: *void, type: *u8, nValues: s32) -> *LuaUDObject #c_call = --- #align 4;
#place __retainObject;
    retainObject:            #type (obj: *LuaUDObject) -> *LuaUDObject #c_call = --- #align 4;
#place __releaseObject;
    releaseObject:           #type (obj: *LuaUDObject) -> void #c_call = --- #align 4;

#place __setUserValue;
    setUserValue:            #type (obj: *LuaUDObject, slot: u32) -> void #c_call = --- #align 4; // sets item on top of stack and pops it
#place __getUserValue;
    getUserValue:            #type (obj: *LuaUDObject, slot: u32) -> s32 #c_call = --- #align 4; // pushes item at slot to top of stack, returns stack position

    // calling lua from C has some overhead. use sparingly!
#place __callFunction_deprecated;
    callFunction_deprecated: #type (name: *u8, nargs: s32) -> void #c_call = --- #align 4;
#place __callFunction;
    callFunction:            #type (name: *u8, nargs: s32, outerr: **u8) -> s32 #c_call = --- #align 4;
}

json_value_type :: enum s32 {
    Null    :: 0;
    True    :: 1;
    False   :: 2;
    Integer :: 3;
    Float   :: 4;
    String  :: 5;
    Array   :: 6;
    Table   :: 7;

    kJSONNull    :: Null;
    kJSONTrue    :: True;
    kJSONFalse   :: False;
    kJSONInteger :: Integer;
    kJSONFloat   :: Float;
    kJSONString  :: String;
    kJSONArray   :: Array;
    kJSONTable   :: Table;
}

json_value :: struct {
    __type: u32 #align 4;
    __data: u32 #align 4;

#place __type;
    type: u8 = --- #align 4;
#place __data;
    data: union {
        intval:    s32;
        floatval:  float;
        stringval: *u8;
        arrayval:  *void;
        tableval:  *void;
    } = --- #align 4;;
}

json_intValue :: (value: json_value) -> s32 #foreign ;

json_floatValue :: (value: json_value) -> float #foreign ;

json_boolValue :: (value: json_value) -> s32 #foreign ;

json_stringValue :: (value: json_value) -> *u8 #foreign ;

json_decoder :: struct {
    __decodeError: u32 #align 4;
    __willDecodeSublist: u32 #align 4;
    __shouldDecodeTableValueForKey: u32 #align 4;
    __didDecodeTableValue: u32 #align 4;
    __shouldDecodeArrayValueAtIndex: u32 #align 4;
    __didDecodeArrayValue: u32 #align 4;
    __didDecodeSublist: u32 #align 4;
    __userdata: u32 #align 4;
    __returnString: u32 #align 4;
    __path: u32 #align 4;

#place __decodeError;
    decodeError:                   #type (decoder: *json_decoder, error: *u8, linenum: s32) -> void #c_call = --- #align 4;

    // the following functions are each optional
#place __willDecodeSublist;
    willDecodeSublist:             #type (decoder: *json_decoder, name: *u8, type: json_value_type) -> void #c_call = --- #align 4;
#place __shouldDecodeTableValueForKey;
    shouldDecodeTableValueForKey:  #type (decoder: *json_decoder, key: *u8) -> s32 #c_call = --- #align 4;
#place __didDecodeTableValue;
    didDecodeTableValue:           #type (decoder: *json_decoder, key: *u8, value: json_value) -> void #c_call = --- #align 4;
#place __shouldDecodeArrayValueAtIndex;
    shouldDecodeArrayValueAtIndex: #type (decoder: *json_decoder, pos: s32) -> s32 #c_call = --- #align 4;
#place __didDecodeArrayValue;
    didDecodeArrayValue:           #type (decoder: *json_decoder, pos: s32, value: json_value) -> void #c_call = --- #align 4; // if pos==0, this was a bare value at the root of the file
#place __didDecodeSublist;
    didDecodeSublist:              #type (decoder: *json_decoder, name: *u8, type: json_value_type) -> *void #c_call = --- #align 4;

#place __userdata;
    userdata:                      *void = --- #align 4;
#place __returnString;
    returnString:                  s32 = --- #align 4; // when set, the decoder skips parsing and returns the current subtree as a string
#place __path;
    path:                          *u8 = --- #align 4; // updated during parsing, reflects current position in tree
}

// convenience functions for setting up a table-only or array-only decoder
json_setTableDecode :: (decoder: *json_decoder, willDecodeSublist: #type (decoder: *json_decoder, name: *u8, type: json_value_type) -> void #c_call, didDecodeTableValue: #type (decoder: *json_decoder, key: *u8, value: json_value) -> void #c_call, didDecodeSublist: #type (decoder: *json_decoder, name: *u8, type: json_value_type) -> *void #c_call) -> void #foreign ;

json_setArrayDecode :: (decoder: *json_decoder, willDecodeSublist: #type (decoder: *json_decoder, name: *u8, type: json_value_type) -> void #c_call, didDecodeArrayValue: #type (decoder: *json_decoder, pos: s32, value: json_value) -> void #c_call, didDecodeSublist: #type (decoder: *json_decoder, name: *u8, type: json_value_type) -> *void #c_call) -> void #foreign ;

// fill buffer, return bytes written or -1 on end of data
json_readFunc :: #type (userdata: *void, buf: *u8, bufsize: s32) -> s32 #c_call;

json_reader :: struct {
    __read: u32 #align 4;
    __userdata: u32 #align 4;

#place __read;
    read:     json_readFunc = --- #align 4;
#place __userdata;
    userdata: *void = --- #align 4; // passed back to the read function above
}

// encoder
json_writeFunc :: #type (userdata: *void, str: *u8, len: s32) -> void #c_call;

json_encoder :: struct {
    __writeStringFunc: u32 #align 4;
    __userdata: u32 #align 4;
    __pretty: u32 #align 4;
    __startArray: u32 #align 4;
    __addArrayMember: u32 #align 4;
    __endArray: u32 #align 4;
    __startTable: u32 #align 4;
    __addTableMember: u32 #align 4;
    __endTable: u32 #align 4;
    __writeNull: u32 #align 4;
    __writeFalse: u32 #align 4;
    __writeTrue: u32 #align 4;
    __writeInt: u32 #align 4;
    __writeDouble: u32 #align 4;
    __writeString: u32 #align 4;

#place __writeStringFunc;
    writeStringFunc: json_writeFunc = --- #align 4;
#place __userdata;
    userdata:        *void = --- #align 4;

#place __pretty;
    pretty:          s32 = --- #align 4;
    #place __pretty; /*bitfield 1*/ startedTable:    s32 = --- #align 4;
    #place __pretty; /*bitfield 2*/ startedArray:    s32 = --- #align 4;
    #place __pretty; /*bitfield 3*/ depth:           s32 = --- #align 4;

#place __startArray;
    startArray:      #type (encoder: *json_encoder) -> void #c_call = --- #align 4;
#place __addArrayMember;
    addArrayMember:  #type (encoder: *json_encoder) -> void #c_call = --- #align 4;
#place __endArray;
    endArray:        #type (encoder: *json_encoder) -> void #c_call = --- #align 4;
#place __startTable;
    startTable:      #type (encoder: *json_encoder) -> void #c_call = --- #align 4;
#place __addTableMember;
    addTableMember:  #type (encoder: *json_encoder, name: *u8, len: s32) -> void #c_call = --- #align 4;
#place __endTable;
    endTable:        #type (encoder: *json_encoder) -> void #c_call = --- #align 4;
#place __writeNull;
    writeNull:       #type (encoder: *json_encoder) -> void #c_call = --- #align 4;
#place __writeFalse;
    writeFalse:      #type (encoder: *json_encoder) -> void #c_call = --- #align 4;
#place __writeTrue;
    writeTrue:       #type (encoder: *json_encoder) -> void #c_call = --- #align 4;
#place __writeInt;
    writeInt:        #type (encoder: *json_encoder, num: s32) -> void #c_call = --- #align 4;
#place __writeDouble;
    writeDouble:     #type (encoder: *json_encoder, num: float64) -> void #c_call = --- #align 4;
#place __writeString;
    writeString:     #type (encoder: *json_encoder, str: *u8, len: s32) -> void #c_call = --- #align 4;
}

playdate_json :: struct {
    __initEncoder: u32 #align 4;
    __decode: u32 #align 4;
    __decodeString: u32 #align 4;

#place __initEncoder;
    initEncoder:  #type (encoder: *json_encoder, write: json_writeFunc, userdata: *void, pretty: s32) -> void #c_call = --- #align 4;

#place __decode;
    decode:       #type (functions: *json_decoder, reader: json_reader, outval: *json_value) -> s32 #c_call = --- #align 4;
#place __decodeString;
    decodeString: #type (functions: *json_decoder, jsonString: *u8, outval: *json_value) -> s32 #c_call = --- #align 4;
}

SDFile :: void;

FileOptions :: enum s32 {
    Read     :: 1;
    ReadData :: 2;
    Write    :: 4;
    Append   :: 8;

    kFileRead     :: Read;
    kFileReadData :: ReadData;
    kFileWrite    :: Write;
    kFileAppend   :: Append;
}

FileStat :: struct {
    isdir:    s32 #align 4;
    size:     u32 #align 4;
    m_year:   s32 #align 4;
    m_month:  s32 #align 4;
    m_day:    s32 #align 4;
    m_hour:   s32 #align 4;
    m_minute: s32 #align 4;
    m_second: s32 #align 4;
}

playdate_file :: struct {
    __geterr: u32 #align 4;
    __listfiles: u32 #align 4;
    __stat: u32 #align 4;
    __mkdir: u32 #align 4;
    __unlink: u32 #align 4;
    __rename: u32 #align 4;
    __open: u32 #align 4;
    __close: u32 #align 4;
    __read: u32 #align 4;
    __write: u32 #align 4;
    __flush: u32 #align 4;
    __tell: u32 #align 4;
    __seek: u32 #align 4;

#place __geterr;
    geterr:    #type () -> *u8 #c_call = --- #align 4;

#place __listfiles;
    listfiles: #type (path: *u8, callback: #type (path: *u8, userdata: *void) -> void #c_call, userdata: *void, showhidden: s32) -> s32 #c_call = --- #align 4;
#place __stat;
    stat:      #type (path: *u8, stat: *FileStat) -> s32 #c_call = --- #align 4;
#place __mkdir;
    mkdir:     #type (path: *u8) -> s32 #c_call = --- #align 4;
#place __unlink;
    unlink:    #type (name: *u8, recursive: s32) -> s32 #c_call = --- #align 4;
#place __rename;
    rename:    #type (from: *u8, to: *u8) -> s32 #c_call = --- #align 4;

#place __open;
    open:      #type (name: *u8, mode: FileOptions) -> *SDFile #c_call = --- #align 4;
#place __close;
    close:     #type (file: *SDFile) -> s32 #c_call = --- #align 4;
#place __read;
    read:      #type (file: *SDFile, buf: *void, len: u32) -> s32 #c_call = --- #align 4;
#place __write;
    write:     #type (file: *SDFile, buf: *void, len: u32) -> s32 #c_call = --- #align 4;
#place __flush;
    flush:     #type (file: *SDFile) -> s32 #c_call = --- #align 4;
#place __tell;
    tell:      #type (file: *SDFile) -> s32 #c_call = --- #align 4;
#place __seek;
    seek:      #type (file: *SDFile, pos: s32, whence: s32) -> s32 #c_call = --- #align 4;
}

SpriteCollisionResponseType :: enum s32 {
    Slide   :: 0;
    Freeze  :: 1;
    Overlap :: 2;
    Bounce  :: 3;
    kCollisionTypeSlide   :: Slide;
    kCollisionTypeFreeze  :: Freeze;
    kCollisionTypeOverlap :: Overlap;
    kCollisionTypeBounce  :: Bounce;
}

PDRect :: struct {
    x:      float #align 4;
    y:      float #align 4;
    width:  float #align 4;
    height: float #align 4;
}

PDRectMake :: (x: float, y: float, width: float, height: float) -> PDRect #foreign ;

CollisionPoint :: struct {
    x: float #align 4;
    y: float #align 4;
}

CollisionVector :: struct {
    x: s32 #align 4;
    y: s32 #align 4;
}

SpriteCollisionInfo :: struct {
    __sprite: u32 #align 4;
    __other: u32 #align 4;
    __responseType: u32 #align 4;
    __overlaps: u32 #align 4;
    __ti: u32 #align 4;
    __move: u32 #align 4;
    __normal: u32 #align 4;
    __touch: u32 #align 4;
    __spriteRect: u32 #align 4;
    __otherRect: u32 #align 4;

#place __sprite;
    sprite:       *LCDSprite = --- #align 4; // The sprite being moved
#place __other;
    other:        *LCDSprite = --- #align 4; // The sprite colliding with the sprite being moved
#place __responseType;
    responseType: SpriteCollisionResponseType = --- #align 4; // The result of collisionResponse
#place __overlaps;
    overlaps:     u8 = --- #align 4; // True if the sprite was overlapping other when the collision started. False if it didn’t overlap but tunneled through other.
#place __ti;
    ti:           float = --- #align 4; // A number between 0 and 1 indicating how far along the movement to the goal the collision occurred
#place __move;
    move:         CollisionPoint = --- #align 4; // The difference between the original coordinates and the actual ones when the collision happened
#place __normal;
    normal:       CollisionVector = --- #align 4; // The collision normal; usually -1, 0, or 1 in x and y. Use this value to determine things like if your character is touching the ground.
#place __touch;
    touch:        CollisionPoint = --- #align 4; // The coordinates where the sprite started touching other
#place __spriteRect;
    spriteRect:   PDRect = --- #align 4; // The rectangle the sprite occupied when the touch happened
#place __otherRect;
    otherRect:    PDRect = --- #align 4; // The rectangle the sprite being collided with occupied when the touch happened
}

SpriteQueryInfo :: struct {
    __sprite: u32 #align 4;
    __ti1: u32 #align 4;
    __ti2: u32 #align 4;
    __entryPoint: u32 #align 4;
    __exitPoint: u32 #align 4;

#place __sprite;
    sprite:     *LCDSprite = --- #align 4; // The sprite being intersected by the segment

#place __ti1;
    ti1:        float = --- #align 4; // entry point
#place __ti2;
    ti2:        float = --- #align 4; // exit point
#place __entryPoint;
    entryPoint: CollisionPoint = --- #align 4; // The coordinates of the first intersection between sprite and the line segment
#place __exitPoint;
    exitPoint:  CollisionPoint = --- #align 4; // The coordinates of the second intersection between sprite and the line segment
}

CWCollisionInfo :: struct {}
CWItemInfo :: struct {}
LCDSpriteDrawFunction :: #type (sprite: *LCDSprite, bounds: PDRect, drawrect: PDRect) -> void #c_call;
LCDSpriteUpdateFunction :: #type (sprite: *LCDSprite) -> void #c_call;
LCDSpriteCollisionFilterProc :: #type (sprite: *LCDSprite, other: *LCDSprite) -> SpriteCollisionResponseType #c_call;

playdate_sprite :: struct {
    __setAlwaysRedraw: u32 #align 4;
    __addDirtyRect: u32 #align 4;
    __drawSprites: u32 #align 4;
    __updateAndDrawSprites: u32 #align 4;
    __newSprite: u32 #align 4;
    __freeSprite: u32 #align 4;
    __copy: u32 #align 4;
    __addSprite: u32 #align 4;
    __removeSprite: u32 #align 4;
    __removeSprites: u32 #align 4;
    __removeAllSprites: u32 #align 4;
    __getSpriteCount: u32 #align 4;
    __setBounds: u32 #align 4;
    __getBounds: u32 #align 4;
    __moveTo: u32 #align 4;
    __moveBy: u32 #align 4;
    __setImage: u32 #align 4;
    __getImage: u32 #align 4;
    __setSize: u32 #align 4;
    __setZIndex: u32 #align 4;
    __getZIndex: u32 #align 4;
    __setDrawMode: u32 #align 4;
    __setImageFlip: u32 #align 4;
    __getImageFlip: u32 #align 4;
    __setStencil: u32 #align 4;
    __setClipRect: u32 #align 4;
    __clearClipRect: u32 #align 4;
    __setClipRectsInRange: u32 #align 4;
    __clearClipRectsInRange: u32 #align 4;
    __setUpdatesEnabled: u32 #align 4;
    __updatesEnabled: u32 #align 4;
    __setCollisionsEnabled: u32 #align 4;
    __collisionsEnabled: u32 #align 4;
    __setVisible: u32 #align 4;
    __isVisible: u32 #align 4;
    __setOpaque: u32 #align 4;
    __markDirty: u32 #align 4;
    __setTag: u32 #align 4;
    __getTag: u32 #align 4;
    __setIgnoresDrawOffset: u32 #align 4;
    __setUpdateFunction: u32 #align 4;
    __setDrawFunction: u32 #align 4;
    __getPosition: u32 #align 4;
    __resetCollisionWorld: u32 #align 4;
    __setCollideRect: u32 #align 4;
    __getCollideRect: u32 #align 4;
    __clearCollideRect: u32 #align 4;
    __setCollisionResponseFunction: u32 #align 4;
    __checkCollisions: u32 #align 4;
    __moveWithCollisions: u32 #align 4;
    __querySpritesAtPoint: u32 #align 4;
    __querySpritesInRect: u32 #align 4;
    __querySpritesAlongLine: u32 #align 4;
    __querySpriteInfoAlongLine: u32 #align 4;
    __overlappingSprites: u32 #align 4;
    __allOverlappingSprites: u32 #align 4;
    __setStencilPattern: u32 #align 4;
    __clearStencil: u32 #align 4;
    __setUserdata: u32 #align 4;
    __getUserdata: u32 #align 4;
    __setStencilImage: u32 #align 4;
    __setCenter: u32 #align 4;
    __getCenter: u32 #align 4;

#place __setAlwaysRedraw;
    setAlwaysRedraw:              #type (flag: s32) -> void #c_call = --- #align 4;
#place __addDirtyRect;
    addDirtyRect:                 #type (dirtyRect: LCDRect) -> void #c_call = --- #align 4;
#place __drawSprites;
    drawSprites:                  #type () -> void #c_call = --- #align 4;
#place __updateAndDrawSprites;
    updateAndDrawSprites:         #type () -> void #c_call = --- #align 4;

#place __newSprite;
    newSprite:                    #type () -> *LCDSprite #c_call = --- #align 4;
#place __freeSprite;
    freeSprite:                   #type (sprite: *LCDSprite) -> void #c_call = --- #align 4;
#place __copy;
    copy:                         #type (sprite: *LCDSprite) -> *LCDSprite #c_call = --- #align 4;

#place __addSprite;
    addSprite:                    #type (sprite: *LCDSprite) -> void #c_call = --- #align 4;
#place __removeSprite;
    removeSprite:                 #type (sprite: *LCDSprite) -> void #c_call = --- #align 4;
#place __removeSprites;
    removeSprites:                #type (sprites: **LCDSprite, count: s32) -> void #c_call = --- #align 4;
#place __removeAllSprites;
    removeAllSprites:             #type () -> void #c_call = --- #align 4;
#place __getSpriteCount;
    getSpriteCount:               #type () -> s32 #c_call = --- #align 4;

#place __setBounds;
    setBounds:                    #type (sprite: *LCDSprite, bounds: PDRect) -> void #c_call = --- #align 4;
#place __getBounds;
    getBounds:                    #type (sprite: *LCDSprite) -> PDRect #c_call = --- #align 4;
#place __moveTo;
    moveTo:                       #type (sprite: *LCDSprite, x: float, y: float) -> void #c_call = --- #align 4;
#place __moveBy;
    moveBy:                       #type (sprite: *LCDSprite, dx: float, dy: float) -> void #c_call = --- #align 4;

#place __setImage;
    setImage:                     #type (sprite: *LCDSprite, image: *LCDBitmap, flip: LCDBitmapFlip) -> void #c_call = --- #align 4;
#place __getImage;
    getImage:                     #type (sprite: *LCDSprite) -> *LCDBitmap #c_call = --- #align 4;
#place __setSize;
    setSize:                      #type (s: *LCDSprite, width: float, height: float) -> void #c_call = --- #align 4;
#place __setZIndex;
    setZIndex:                    #type (sprite: *LCDSprite, zIndex: s16) -> void #c_call = --- #align 4;
#place __getZIndex;
    getZIndex:                    #type (sprite: *LCDSprite) -> s16 #c_call = --- #align 4;

#place __setDrawMode;
    setDrawMode:                  #type (sprite: *LCDSprite, mode: LCDBitmapDrawMode) -> void #c_call = --- #align 4;
#place __setImageFlip;
    setImageFlip:                 #type (sprite: *LCDSprite, flip: LCDBitmapFlip) -> void #c_call = --- #align 4;
#place __getImageFlip;
    getImageFlip:                 #type (sprite: *LCDSprite) -> LCDBitmapFlip #c_call = --- #align 4;
#place __setStencil;
    setStencil:                   #type (sprite: *LCDSprite, stencil: *LCDBitmap) -> void #c_call = --- #align 4; // deprecated in favor of setStencilImage()

#place __setClipRect;
    setClipRect:                  #type (sprite: *LCDSprite, clipRect: LCDRect) -> void #c_call = --- #align 4;
#place __clearClipRect;
    clearClipRect:                #type (sprite: *LCDSprite) -> void #c_call = --- #align 4;
#place __setClipRectsInRange;
    setClipRectsInRange:          #type (clipRect: LCDRect, startZ: s32, endZ: s32) -> void #c_call = --- #align 4;
#place __clearClipRectsInRange;
    clearClipRectsInRange:        #type (startZ: s32, endZ: s32) -> void #c_call = --- #align 4;

#place __setUpdatesEnabled;
    setUpdatesEnabled:            #type (sprite: *LCDSprite, flag: s32) -> void #c_call = --- #align 4;
#place __updatesEnabled;
    updatesEnabled:               #type (sprite: *LCDSprite) -> s32 #c_call = --- #align 4;
#place __setCollisionsEnabled;
    setCollisionsEnabled:         #type (sprite: *LCDSprite, flag: s32) -> void #c_call = --- #align 4;
#place __collisionsEnabled;
    collisionsEnabled:            #type (sprite: *LCDSprite) -> s32 #c_call = --- #align 4;
#place __setVisible;
    setVisible:                   #type (sprite: *LCDSprite, flag: s32) -> void #c_call = --- #align 4;
#place __isVisible;
    isVisible:                    #type (sprite: *LCDSprite) -> s32 #c_call = --- #align 4;
#place __setOpaque;
    setOpaque:                    #type (sprite: *LCDSprite, flag: s32) -> void #c_call = --- #align 4;
#place __markDirty;
    markDirty:                    #type (sprite: *LCDSprite) -> void #c_call = --- #align 4;

#place __setTag;
    setTag:                       #type (sprite: *LCDSprite, tag: u8) -> void #c_call = --- #align 4;
#place __getTag;
    getTag:                       #type (sprite: *LCDSprite) -> u8 #c_call = --- #align 4;

#place __setIgnoresDrawOffset;
    setIgnoresDrawOffset:         #type (sprite: *LCDSprite, flag: s32) -> void #c_call = --- #align 4;

#place __setUpdateFunction;
    setUpdateFunction:            #type (sprite: *LCDSprite, func: LCDSpriteUpdateFunction) -> void #c_call = --- #align 4;
#place __setDrawFunction;
    setDrawFunction:              #type (sprite: *LCDSprite, func: LCDSpriteDrawFunction) -> void #c_call = --- #align 4;

#place __getPosition;
    getPosition:                  #type (sprite: *LCDSprite, x: *float, y: *float) -> void #c_call = --- #align 4;

    // Collisions
#place __resetCollisionWorld;
    resetCollisionWorld:          #type () -> void #c_call = --- #align 4;

#place __setCollideRect;
    setCollideRect:               #type (sprite: *LCDSprite, collideRect: PDRect) -> void #c_call = --- #align 4;
#place __getCollideRect;
    getCollideRect:               #type (sprite: *LCDSprite) -> PDRect #c_call = --- #align 4;
#place __clearCollideRect;
    clearCollideRect:             #type (sprite: *LCDSprite) -> void #c_call = --- #align 4;

    // caller is responsible for freeing the returned array for all collision methods
#place __setCollisionResponseFunction;
    setCollisionResponseFunction: #type (sprite: *LCDSprite, func: LCDSpriteCollisionFilterProc) -> void #c_call = --- #align 4;
#place __checkCollisions;
    checkCollisions:              #type (sprite: *LCDSprite, goalX: float, goalY: float, actualX: *float, actualY: *float, len: *s32) -> *SpriteCollisionInfo #c_call = --- #align 4; // access results using SpriteCollisionInfo *info = &results[i];
#place __moveWithCollisions;
    moveWithCollisions:           #type (sprite: *LCDSprite, goalX: float, goalY: float, actualX: *float, actualY: *float, len: *s32) -> *SpriteCollisionInfo #c_call = --- #align 4;
#place __querySpritesAtPoint;
    querySpritesAtPoint:          #type (x: float, y: float, len: *s32) -> **LCDSprite #c_call = --- #align 4;
#place __querySpritesInRect;
    querySpritesInRect:           #type (x: float, y: float, width: float, height: float, len: *s32) -> **LCDSprite #c_call = --- #align 4;
#place __querySpritesAlongLine;
    querySpritesAlongLine:        #type (x1: float, y1: float, x2: float, y2: float, len: *s32) -> **LCDSprite #c_call = --- #align 4;
#place __querySpriteInfoAlongLine;
    querySpriteInfoAlongLine:     #type (x1: float, y1: float, x2: float, y2: float, len: *s32) -> *SpriteQueryInfo #c_call = --- #align 4; // access results using SpriteQueryInfo *info = &results[i];
#place __overlappingSprites;
    overlappingSprites:           #type (sprite: *LCDSprite, len: *s32) -> **LCDSprite #c_call = --- #align 4;
#place __allOverlappingSprites;
    allOverlappingSprites:        #type (len: *s32) -> **LCDSprite #c_call = --- #align 4;

    // added in 1.7
#place __setStencilPattern;
    setStencilPattern:            #type (sprite: *LCDSprite, pattern: *[8] u8) -> void #c_call = --- #align 4;
#place __clearStencil;
    clearStencil:                 #type (sprite: *LCDSprite) -> void #c_call = --- #align 4;

#place __setUserdata;
    setUserdata:                  #type (sprite: *LCDSprite, userdata: *void) -> void #c_call = --- #align 4;
#place __getUserdata;
    getUserdata:                  #type (sprite: *LCDSprite) -> *void #c_call = --- #align 4;

    // added in 1.10
#place __setStencilImage;
    setStencilImage:              #type (sprite: *LCDSprite, stencil: *LCDBitmap, tile: s32) -> void #c_call = --- #align 4;

    // 2.1
#place __setCenter;
    setCenter:                    #type (s: *LCDSprite, x: float, y: float) -> void #c_call = --- #align 4;
#place __getCenter;
    getCenter:                    #type (s: *LCDSprite, x: *float, y: *float) -> void #c_call = --- #align 4;
}

SoundFormat :: enum s32 {
    _8bitMono    :: 0;
    _8bitStereo  :: 1;
    _16bitMono   :: 2;
    _16bitStereo :: 3;
    ADPCMMono    :: 4;
    ADPCMStereo  :: 5;

    kSound8bitMono    :: _8bitMono;
    kSound8bitStereo  :: _8bitStereo;
    kSound16bitMono   :: _16bitMono;
    kSound16bitStereo :: _16bitStereo;
    kSoundADPCMMono   :: ADPCMMono;
    kSoundADPCMStereo :: ADPCMStereo;
}

SoundFormat_bytesPerFrame :: (fmt: SoundFormat) -> u32 #foreign ;

MIDINote :: float;

pd_noteToFrequency :: (n: MIDINote) -> float #foreign ;
pd_frequencyToNote :: (f: float) -> MIDINote #foreign ;

SoundSource :: struct {}
sndCallbackProc :: #type (c: *SoundSource, userdata: *void) -> void #c_call;

// SoundSource is the parent class for FilePlayer, SamplePlayer, PDSynth, and DelayLineTap. You can safely cast those objects to a SoundSource* and use these functions:
playdate_sound_source :: struct {
    __setVolume: u32 #align 4;
    __getVolume: u32 #align 4;
    __isPlaying: u32 #align 4;
    __setFinishCallback: u32 #align 4;

#place __setVolume;
    setVolume:         #type (c: *SoundSource, lvol: float, rvol: float) -> void #c_call = --- #align 4;
#place __getVolume;
    getVolume:         #type (c: *SoundSource, outl: *float, outr: *float) -> void #c_call = --- #align 4;
#place __isPlaying;
    isPlaying:         #type (c: *SoundSource) -> s32 #c_call = --- #align 4;
#place __setFinishCallback;
    setFinishCallback: #type (c: *SoundSource, callback: sndCallbackProc, userdata: *void) -> void #c_call = --- #align 4;
}

FilePlayer :: struct {}

playdate_sound_fileplayer :: struct {
    __newPlayer: u32 #align 4;
    __freePlayer: u32 #align 4;
    __loadIntoPlayer: u32 #align 4;
    __setBufferLength: u32 #align 4;
    __play: u32 #align 4;
    __isPlaying: u32 #align 4;
    __pause: u32 #align 4;
    __stop: u32 #align 4;
    __setVolume: u32 #align 4;
    __getVolume: u32 #align 4;
    __getLength: u32 #align 4;
    __setOffset: u32 #align 4;
    __setRate: u32 #align 4;
    __setLoopRange: u32 #align 4;
    __didUnderrun: u32 #align 4;
    __setFinishCallback: u32 #align 4;
    __setLoopCallback: u32 #align 4;
    __getOffset: u32 #align 4;
    __getRate: u32 #align 4;
    __setStopOnUnderrun: u32 #align 4;
    __fadeVolume: u32 #align 4;
    __setMP3StreamSource: u32 #align 4;

#place __newPlayer;
    newPlayer:          #type () -> *FilePlayer #c_call = --- #align 4;
#place __freePlayer;
    freePlayer:         #type (player: *FilePlayer) -> void #c_call = --- #align 4;
#place __loadIntoPlayer;
    loadIntoPlayer:     #type (player: *FilePlayer, path: *u8) -> s32 #c_call = --- #align 4;
#place __setBufferLength;
    setBufferLength:    #type (player: *FilePlayer, bufferLen: float) -> void #c_call = --- #align 4;
#place __play;
    play:               #type (player: *FilePlayer, repeat: s32) -> s32 #c_call = --- #align 4;
#place __isPlaying;
    isPlaying:          #type (player: *FilePlayer) -> s32 #c_call = --- #align 4;
#place __pause;
    pause:              #type (player: *FilePlayer) -> void #c_call = --- #align 4;
#place __stop;
    stop:               #type (player: *FilePlayer) -> void #c_call = --- #align 4;
#place __setVolume;
    setVolume:          #type (player: *FilePlayer, left: float, right: float) -> void #c_call = --- #align 4;
#place __getVolume;
    getVolume:          #type (player: *FilePlayer, left: *float, right: *float) -> void #c_call = --- #align 4;
#place __getLength;
    getLength:          #type (player: *FilePlayer) -> float #c_call = --- #align 4;
#place __setOffset;
    setOffset:          #type (player: *FilePlayer, offset: float) -> void #c_call = --- #align 4;
#place __setRate;
    setRate:            #type (player: *FilePlayer, rate: float) -> void #c_call = --- #align 4;
#place __setLoopRange;
    setLoopRange:       #type (player: *FilePlayer, start: float, end: float) -> void #c_call = --- #align 4;
#place __didUnderrun;
    didUnderrun:        #type (player: *FilePlayer) -> s32 #c_call = --- #align 4;
#place __setFinishCallback;
    setFinishCallback:  #type (player: *FilePlayer, callback: sndCallbackProc, userdata: *void) -> void #c_call = --- #align 4;
#place __setLoopCallback;
    setLoopCallback:    #type (player: *FilePlayer, callback: sndCallbackProc, userdata: *void) -> void #c_call = --- #align 4;
#place __getOffset;
    getOffset:          #type (player: *FilePlayer) -> float #c_call = --- #align 4;
#place __getRate;
    getRate:            #type (player: *FilePlayer) -> float #c_call = --- #align 4;
#place __setStopOnUnderrun;
    setStopOnUnderrun:  #type (player: *FilePlayer, flag: s32) -> void #c_call = --- #align 4;
#place __fadeVolume;
    fadeVolume:         #type (player: *FilePlayer, left: float, right: float, len: s32, finishCallback: sndCallbackProc, userdata: *void) -> void #c_call = --- #align 4;
#place __setMP3StreamSource;
    setMP3StreamSource: #type (player: *FilePlayer, dataSource: #type (data: *u8, bytes: s32, userdata: *void) -> s32 #c_call, userdata: *void, bufferLen: float) -> void #c_call = --- #align 4;
}

AudioSample :: struct {}
SamplePlayer :: struct {}

playdate_sound_sample :: struct {
    __newSampleBuffer: u32 #align 4;
    __loadIntoSample: u32 #align 4;
    __load: u32 #align 4;
    __newSampleFromData: u32 #align 4;
    __getData: u32 #align 4;
    __freeSample: u32 #align 4;
    __getLength: u32 #align 4;
    __decompress: u32 #align 4;

#place __newSampleBuffer;
    newSampleBuffer:   #type (byteCount: s32) -> *AudioSample #c_call = --- #align 4;
#place __loadIntoSample;
    loadIntoSample:    #type (sample: *AudioSample, path: *u8) -> s32 #c_call = --- #align 4;
#place __load;
    load:              #type (path: *u8) -> *AudioSample #c_call = --- #align 4;
#place __newSampleFromData;
    newSampleFromData: #type (data: *u8, format: SoundFormat, sampleRate: u32, byteCount: s32, shouldFreeData: s32) -> *AudioSample #c_call = --- #align 4;
#place __getData;
    getData:           #type (sample: *AudioSample, data: **u8, format: *SoundFormat, sampleRate: *u32, bytelength: *u32) -> void #c_call = --- #align 4;
#place __freeSample;
    freeSample:        #type (sample: *AudioSample) -> void #c_call = --- #align 4;
#place __getLength;
    getLength:         #type (sample: *AudioSample) -> float #c_call = --- #align 4;

    // 2.4
#place __decompress;
    decompress:        #type (sample: *AudioSample) -> s32 #c_call = --- #align 4;
}

playdate_sound_sampleplayer :: struct {
    __newPlayer: u32 #align 4;
    __freePlayer: u32 #align 4;
    __setSample: u32 #align 4;
    __play: u32 #align 4;
    __isPlaying: u32 #align 4;
    __stop: u32 #align 4;
    __setVolume: u32 #align 4;
    __getVolume: u32 #align 4;
    __getLength: u32 #align 4;
    __setOffset: u32 #align 4;
    __setRate: u32 #align 4;
    __setPlayRange: u32 #align 4;
    __setFinishCallback: u32 #align 4;
    __setLoopCallback: u32 #align 4;
    __getOffset: u32 #align 4;
    __getRate: u32 #align 4;
    __setPaused: u32 #align 4;

#place __newPlayer;
    newPlayer:         #type () -> *SamplePlayer #c_call = --- #align 4;
#place __freePlayer;
    freePlayer:        #type (player: *SamplePlayer) -> void #c_call = --- #align 4;
#place __setSample;
    setSample:         #type (player: *SamplePlayer, sample: *AudioSample) -> void #c_call = --- #align 4;
#place __play;
    play:              #type (player: *SamplePlayer, repeat: s32, rate: float) -> s32 #c_call = --- #align 4;
#place __isPlaying;
    isPlaying:         #type (player: *SamplePlayer) -> s32 #c_call = --- #align 4;
#place __stop;
    stop:              #type (player: *SamplePlayer) -> void #c_call = --- #align 4;
#place __setVolume;
    setVolume:         #type (player: *SamplePlayer, left: float, right: float) -> void #c_call = --- #align 4;
#place __getVolume;
    getVolume:         #type (player: *SamplePlayer, left: *float, right: *float) -> void #c_call = --- #align 4;
#place __getLength;
    getLength:         #type (player: *SamplePlayer) -> float #c_call = --- #align 4;
#place __setOffset;
    setOffset:         #type (player: *SamplePlayer, offset: float) -> void #c_call = --- #align 4;
#place __setRate;
    setRate:           #type (player: *SamplePlayer, rate: float) -> void #c_call = --- #align 4;
#place __setPlayRange;
    setPlayRange:      #type (player: *SamplePlayer, start: s32, end: s32) -> void #c_call = --- #align 4;
#place __setFinishCallback;
    setFinishCallback: #type (player: *SamplePlayer, callback: sndCallbackProc, userdata: *void) -> void #c_call = --- #align 4;
#place __setLoopCallback;
    setLoopCallback:   #type (player: *SamplePlayer, callback: sndCallbackProc, userdata: *void) -> void #c_call = --- #align 4;
#place __getOffset;
    getOffset:         #type (player: *SamplePlayer) -> float #c_call = --- #align 4;
#place __getRate;
    getRate:           #type (player: *SamplePlayer) -> float #c_call = --- #align 4;
#place __setPaused;
    setPaused:         #type (player: *SamplePlayer, flag: s32) -> void #c_call = --- #align 4;
}

PDSynthSignalValue :: struct {}
PDSynthSignal :: struct {}

signalStepFunc :: #type (userdata: *void, ioframes: *s32, ifval: *float) -> float #c_call;
signalNoteOnFunc :: #type (userdata: *void, note: MIDINote, vel: float, len: float) -> void #c_call;
signalNoteOffFunc :: #type (userdata: *void, stopped: s32, offset: s32) -> void #c_call;
signalDeallocFunc :: #type (userdata: *void) -> void #c_call;

playdate_sound_signal :: struct {
    __newSignal: u32 #align 4;
    __freeSignal: u32 #align 4;
    __getValue: u32 #align 4;
    __setValueScale: u32 #align 4;
    __setValueOffset: u32 #align 4;
    __newSignalForValue: u32 #align 4;

#place __newSignal;
    newSignal:         #type (step: signalStepFunc, noteOn: signalNoteOnFunc, noteOff: signalNoteOffFunc, dealloc: signalDeallocFunc, userdata: *void) -> *PDSynthSignal #c_call = --- #align 4;
#place __freeSignal;
    freeSignal:        #type (signal: *PDSynthSignal) -> void #c_call = --- #align 4;
#place __getValue;
    getValue:          #type (signal: *PDSynthSignal) -> float #c_call = --- #align 4;
#place __setValueScale;
    setValueScale:     #type (signal: *PDSynthSignal, scale: float) -> void #c_call = --- #align 4;
#place __setValueOffset;
    setValueOffset:    #type (signal: *PDSynthSignal, offset: float) -> void #c_call = --- #align 4;

    // 2.6
#place __newSignalForValue;
    newSignalForValue: #type (value: *PDSynthSignalValue) -> *PDSynthSignal #c_call = --- #align 4;
}

LFOType :: enum s32 {
    Square        :: 0;
    Triangle      :: 1;
    Sine          :: 2;
    SampleAndHold :: 3;
    SawtoothUp    :: 4;
    SawtoothDown  :: 5;
    Arpeggiator   :: 6;
    Function      :: 7;

    kLFOTypeSquare        :: Square;
    kLFOTypeTriangle      :: Triangle;
    kLFOTypeSine          :: Sine;
    kLFOTypeSampleAndHold :: SampleAndHold;
    kLFOTypeSawtoothUp    :: SawtoothUp;
    kLFOTypeSawtoothDown  :: SawtoothDown;
    kLFOTypeArpeggiator   :: Arpeggiator;
    kLFOTypeFunction      :: Function;
}

PDSynthLFO :: struct {}

playdate_sound_lfo :: struct {
    __newLFO: u32 #align 4;
    __freeLFO: u32 #align 4;
    __setType: u32 #align 4;
    __setRate: u32 #align 4;
    __setPhase: u32 #align 4;
    __setCenter: u32 #align 4;
    __setDepth: u32 #align 4;
    __setArpeggiation: u32 #align 4;
    __setFunction: u32 #align 4;
    __setDelay: u32 #align 4;
    __setRetrigger: u32 #align 4;
    __getValue: u32 #align 4;
    __setGlobal: u32 #align 4;
    __setStartPhase: u32 #align 4;

#place __newLFO;
    newLFO:          #type (type: LFOType) -> *PDSynthLFO #c_call = --- #align 4;
#place __freeLFO;
    freeLFO:         #type (lfo: *PDSynthLFO) -> void #c_call = --- #align 4;

#place __setType;
    setType:         #type (lfo: *PDSynthLFO, type: LFOType) -> void #c_call = --- #align 4;
#place __setRate;
    setRate:         #type (lfo: *PDSynthLFO, rate: float) -> void #c_call = --- #align 4;
#place __setPhase;
    setPhase:        #type (lfo: *PDSynthLFO, phase: float) -> void #c_call = --- #align 4;
#place __setCenter;
    setCenter:       #type (lfo: *PDSynthLFO, center: float) -> void #c_call = --- #align 4;
#place __setDepth;
    setDepth:        #type (lfo: *PDSynthLFO, depth: float) -> void #c_call = --- #align 4;
#place __setArpeggiation;
    setArpeggiation: #type (lfo: *PDSynthLFO, nSteps: s32, steps: *float) -> void #c_call = --- #align 4;
#place __setFunction;
    setFunction:     #type (lfo: *PDSynthLFO, lfoFunc: #type (lfo: *PDSynthLFO, userdata: *void) -> float #c_call, userdata: *void, interpolate: s32) -> void #c_call = --- #align 4;
#place __setDelay;
    setDelay:        #type (lfo: *PDSynthLFO, holdoff: float, ramptime: float) -> void #c_call = --- #align 4;
#place __setRetrigger;
    setRetrigger:    #type (lfo: *PDSynthLFO, flag: s32) -> void #c_call = --- #align 4;

#place __getValue;
    getValue:        #type (lfo: *PDSynthLFO) -> float #c_call = --- #align 4;

    // 1.10
#place __setGlobal;
    setGlobal:       #type (lfo: *PDSynthLFO, global: s32) -> void #c_call = --- #align 4;

    // 2.2
#place __setStartPhase;
    setStartPhase:   #type (lfo: *PDSynthLFO, phase: float) -> void #c_call = --- #align 4;
}

PDSynthEnvelope :: struct {}

playdate_sound_envelope :: struct {
    __newEnvelope: u32 #align 4;
    __freeEnvelope: u32 #align 4;
    __setAttack: u32 #align 4;
    __setDecay: u32 #align 4;
    __setSustain: u32 #align 4;
    __setRelease: u32 #align 4;
    __setLegato: u32 #align 4;
    __setRetrigger: u32 #align 4;
    __getValue: u32 #align 4;
    __setCurvature: u32 #align 4;
    __setVelocitySensitivity: u32 #align 4;
    __setRateScaling: u32 #align 4;

#place __newEnvelope;
    newEnvelope:            #type (attack: float, decay: float, sustain: float, release: float) -> *PDSynthEnvelope #c_call = --- #align 4;
#place __freeEnvelope;
    freeEnvelope:           #type (env: *PDSynthEnvelope) -> void #c_call = --- #align 4;

#place __setAttack;
    setAttack:              #type (env: *PDSynthEnvelope, attack: float) -> void #c_call = --- #align 4;
#place __setDecay;
    setDecay:               #type (env: *PDSynthEnvelope, decay: float) -> void #c_call = --- #align 4;
#place __setSustain;
    setSustain:             #type (env: *PDSynthEnvelope, sustain: float) -> void #c_call = --- #align 4;
#place __setRelease;
    setRelease:             #type (env: *PDSynthEnvelope, release: float) -> void #c_call = --- #align 4;

#place __setLegato;
    setLegato:              #type (env: *PDSynthEnvelope, flag: s32) -> void #c_call = --- #align 4;
#place __setRetrigger;
    setRetrigger:           #type (lfo: *PDSynthEnvelope, flag: s32) -> void #c_call = --- #align 4;

#place __getValue;
    getValue:               #type (env: *PDSynthEnvelope) -> float #c_call = --- #align 4;

    // 1.13
#place __setCurvature;
    setCurvature:           #type (env: *PDSynthEnvelope, amount: float) -> void #c_call = --- #align 4;
#place __setVelocitySensitivity;
    setVelocitySensitivity: #type (env: *PDSynthEnvelope, velsens: float) -> void #c_call = --- #align 4;
#place __setRateScaling;
    setRateScaling:         #type (env: *PDSynthEnvelope, scaling: float, start: MIDINote, end: MIDINote) -> void #c_call = --- #align 4;
}

SoundWaveform :: enum s32 {
    Square    :: 0;
    Triangle  :: 1;
    Sine      :: 2;
    Noise     :: 3;
    Sawtooth  :: 4;
    POPhase   :: 5;
    PODigital :: 6;
    POVosim   :: 7;

    kWaveformSquare    :: Square;
    kWaveformTriangle  :: Triangle;
    kWaveformSine      :: Sine;
    kWaveformNoise     :: Noise;
    kWaveformSawtooth  :: Sawtooth;
    kWaveformPOPhase   :: POPhase;
    kWaveformPODigital :: PODigital;
    kWaveformPOVosim   :: POVosim;
}

// generator render callback
// samples are in Q8.24 format. left is either the left channel or the single mono channel,
// right is non-NULL only if the stereo flag was set in the setGenerator() call.
// nsamples is at most 256 but may be shorter
// rate is Q0.32 per-frame phase step, drate is per-frame rate step (i.e., do rate += drate every frame)
// return value is the number of sample frames rendered
synthRenderFunc :: #type (userdata: *void, left: *s32, right: *s32, nsamples: s32, rate: u32, drate: s32) -> s32 #c_call;

// generator event callbacks
synthNoteOnFunc :: #type (userdata: *void, note: MIDINote, velocity: float, len: float) -> void #c_call;
synthReleaseFunc :: #type (userdata: *void, stop: s32) -> void #c_call;
synthSetParameterFunc :: #type (userdata: *void, parameter: s32, value: float) -> s32 #c_call;
synthDeallocFunc :: #type (userdata: *void) -> void #c_call;
synthCopyUserdata :: #type (userdata: *void) -> *void #c_call;
PDSynth :: struct {}

playdate_sound_synth :: struct {
    __newSynth: u32 #align 4;
    __freeSynth: u32 #align 4;
    __setWaveform: u32 #align 4;
    __setGenerator_deprecated: u32 #align 4;
    __setSample: u32 #align 4;
    __setAttackTime: u32 #align 4;
    __setDecayTime: u32 #align 4;
    __setSustainLevel: u32 #align 4;
    __setReleaseTime: u32 #align 4;
    __setTranspose: u32 #align 4;
    __setFrequencyModulator: u32 #align 4;
    __getFrequencyModulator: u32 #align 4;
    __setAmplitudeModulator: u32 #align 4;
    __getAmplitudeModulator: u32 #align 4;
    __getParameterCount: u32 #align 4;
    __setParameter: u32 #align 4;
    __setParameterModulator: u32 #align 4;
    __getParameterModulator: u32 #align 4;
    __playNote: u32 #align 4;
    __playMIDINote: u32 #align 4;
    __noteOff: u32 #align 4;
    __stop: u32 #align 4;
    __setVolume: u32 #align 4;
    __getVolume: u32 #align 4;
    __isPlaying: u32 #align 4;
    __getEnvelope: u32 #align 4;
    __setWavetable: u32 #align 4;
    __setGenerator: u32 #align 4;
    __copy: u32 #align 4;
    __clearEnvelope: u32 #align 4;

#place __newSynth;
    newSynth:                #type () -> *PDSynth #c_call = --- #align 4;
#place __freeSynth;
    freeSynth:               #type (synth: *PDSynth) -> void #c_call = --- #align 4;

#place __setWaveform;
    setWaveform:             #type (synth: *PDSynth, wave: SoundWaveform) -> void #c_call = --- #align 4;
#place __setGenerator_deprecated;
    setGenerator_deprecated: #type (synth: *PDSynth, stereo: s32, render: synthRenderFunc, noteOn: synthNoteOnFunc, release: synthReleaseFunc, setparam: synthSetParameterFunc, dealloc: synthDeallocFunc, userdata: *void) -> void #c_call = --- #align 4;
#place __setSample;
    setSample:               #type (synth: *PDSynth, sample: *AudioSample, sustainStart: u32, sustainEnd: u32) -> void #c_call = --- #align 4;

#place __setAttackTime;
    setAttackTime:           #type (synth: *PDSynth, attack: float) -> void #c_call = --- #align 4;
#place __setDecayTime;
    setDecayTime:            #type (synth: *PDSynth, decay: float) -> void #c_call = --- #align 4;
#place __setSustainLevel;
    setSustainLevel:         #type (synth: *PDSynth, sustain: float) -> void #c_call = --- #align 4;
#place __setReleaseTime;
    setReleaseTime:          #type (synth: *PDSynth, release: float) -> void #c_call = --- #align 4;

#place __setTranspose;
    setTranspose:            #type (synth: *PDSynth, halfSteps: float) -> void #c_call = --- #align 4;

#place __setFrequencyModulator;
    setFrequencyModulator:   #type (synth: *PDSynth, mod: *PDSynthSignalValue) -> void #c_call = --- #align 4;
#place __getFrequencyModulator;
    getFrequencyModulator:   #type (synth: *PDSynth) -> *PDSynthSignalValue #c_call = --- #align 4;
#place __setAmplitudeModulator;
    setAmplitudeModulator:   #type (synth: *PDSynth, mod: *PDSynthSignalValue) -> void #c_call = --- #align 4;
#place __getAmplitudeModulator;
    getAmplitudeModulator:   #type (synth: *PDSynth) -> *PDSynthSignalValue #c_call = --- #align 4;

#place __getParameterCount;
    getParameterCount:       #type (synth: *PDSynth) -> s32 #c_call = --- #align 4;
#place __setParameter;
    setParameter:            #type (synth: *PDSynth, parameter: s32, value: float) -> s32 #c_call = --- #align 4;
#place __setParameterModulator;
    setParameterModulator:   #type (synth: *PDSynth, parameter: s32, mod: *PDSynthSignalValue) -> void #c_call = --- #align 4;
#place __getParameterModulator;
    getParameterModulator:   #type (synth: *PDSynth, parameter: s32) -> *PDSynthSignalValue #c_call = --- #align 4;

#place __playNote;
    playNote:                #type (synth: *PDSynth, freq: float, vel: float, len: float, when: u32) -> void #c_call = --- #align 4; // len == -1 for indefinite
#place __playMIDINote;
    playMIDINote:            #type (synth: *PDSynth, note: MIDINote, vel: float, len: float, when: u32) -> void #c_call = --- #align 4; // len == -1 for indefinite
#place __noteOff;
    noteOff:                 #type (synth: *PDSynth, when: u32) -> void #c_call = --- #align 4; // move to release part of envelope
#place __stop;
    stop:                    #type (synth: *PDSynth) -> void #c_call = --- #align 4; // stop immediately

#place __setVolume;
    setVolume:               #type (synth: *PDSynth, left: float, right: float) -> void #c_call = --- #align 4;
#place __getVolume;
    getVolume:               #type (synth: *PDSynth, left: *float, right: *float) -> void #c_call = --- #align 4;

#place __isPlaying;
    isPlaying:               #type (synth: *PDSynth) -> s32 #c_call = --- #align 4;

#place __getEnvelope;
    getEnvelope:             #type (synth: *PDSynth) -> *PDSynthEnvelope #c_call = --- #align 4; // synth keeps ownership--don't free this!

    // 2.2
#place __setWavetable;
    setWavetable:            #type (synth: *PDSynth, sample: *AudioSample, log2size: s32, columns: s32, rows: s32) -> s32 #c_call = --- #align 4;

    // 2.4
#place __setGenerator;
    setGenerator:            #type (synth: *PDSynth, stereo: s32, render: synthRenderFunc, noteOn: synthNoteOnFunc, release: synthReleaseFunc, setparam: synthSetParameterFunc, dealloc: synthDeallocFunc, copyUserdata: synthCopyUserdata, userdata: *void) -> void #c_call = --- #align 4;
#place __copy;
    copy:                    #type (synth: *PDSynth) -> *PDSynth #c_call = --- #align 4;

    // 2.6
#place __clearEnvelope;
    clearEnvelope:           #type (synth: *PDSynth) -> void #c_call = --- #align 4;
}

ControlSignal :: struct {}

playdate_control_signal :: struct {
    __newSignal: u32 #align 4;
    __freeSignal: u32 #align 4;
    __clearEvents: u32 #align 4;
    __addEvent: u32 #align 4;
    __removeEvent: u32 #align 4;
    __getMIDIControllerNumber: u32 #align 4;

#place __newSignal;
    newSignal:               #type () -> *ControlSignal #c_call = --- #align 4;
#place __freeSignal;
    freeSignal:              #type (signal: *ControlSignal) -> void #c_call = --- #align 4;
#place __clearEvents;
    clearEvents:             #type (control: *ControlSignal) -> void #c_call = --- #align 4;
#place __addEvent;
    addEvent:                #type (control: *ControlSignal, step: s32, value: float, interpolate: s32) -> void #c_call = --- #align 4;
#place __removeEvent;
    removeEvent:             #type (control: *ControlSignal, step: s32) -> void #c_call = --- #align 4;
#place __getMIDIControllerNumber;
    getMIDIControllerNumber: #type (control: *ControlSignal) -> s32 #c_call = --- #align 4;
}

PDSynthInstrument :: struct {}

playdate_sound_instrument :: struct {
    __newInstrument: u32 #align 4;
    __freeInstrument: u32 #align 4;
    __addVoice: u32 #align 4;
    __playNote: u32 #align 4;
    __playMIDINote: u32 #align 4;
    __setPitchBend: u32 #align 4;
    __setPitchBendRange: u32 #align 4;
    __setTranspose: u32 #align 4;
    __noteOff: u32 #align 4;
    __allNotesOff: u32 #align 4;
    __setVolume: u32 #align 4;
    __getVolume: u32 #align 4;
    __activeVoiceCount: u32 #align 4;

#place __newInstrument;
    newInstrument:     #type () -> *PDSynthInstrument #c_call = --- #align 4;
#place __freeInstrument;
    freeInstrument:    #type (inst: *PDSynthInstrument) -> void #c_call = --- #align 4;
#place __addVoice;
    addVoice:          #type (inst: *PDSynthInstrument, synth: *PDSynth, rangeStart: MIDINote, rangeEnd: MIDINote, transpose: float) -> s32 #c_call = --- #align 4;
#place __playNote;
    playNote:          #type (inst: *PDSynthInstrument, frequency: float, vel: float, len: float, when: u32) -> *PDSynth #c_call = --- #align 4;
#place __playMIDINote;
    playMIDINote:      #type (inst: *PDSynthInstrument, note: MIDINote, vel: float, len: float, when: u32) -> *PDSynth #c_call = --- #align 4;
#place __setPitchBend;
    setPitchBend:      #type (inst: *PDSynthInstrument, bend: float) -> void #c_call = --- #align 4;
#place __setPitchBendRange;
    setPitchBendRange: #type (inst: *PDSynthInstrument, halfSteps: float) -> void #c_call = --- #align 4;
#place __setTranspose;
    setTranspose:      #type (inst: *PDSynthInstrument, halfSteps: float) -> void #c_call = --- #align 4;
#place __noteOff;
    noteOff:           #type (inst: *PDSynthInstrument, note: MIDINote, when: u32) -> void #c_call = --- #align 4;
#place __allNotesOff;
    allNotesOff:       #type (inst: *PDSynthInstrument, when: u32) -> void #c_call = --- #align 4;
#place __setVolume;
    setVolume:         #type (inst: *PDSynthInstrument, left: float, right: float) -> void #c_call = --- #align 4;
#place __getVolume;
    getVolume:         #type (inst: *PDSynthInstrument, left: *float, right: *float) -> void #c_call = --- #align 4;
#place __activeVoiceCount;
    activeVoiceCount:  #type (inst: *PDSynthInstrument) -> s32 #c_call = --- #align 4;
}

SequenceTrack :: struct {}

playdate_sound_track :: struct {
    __newTrack: u32 #align 4;
    __freeTrack: u32 #align 4;
    __setInstrument: u32 #align 4;
    __getInstrument: u32 #align 4;
    __addNoteEvent: u32 #align 4;
    __removeNoteEvent: u32 #align 4;
    __clearNotes: u32 #align 4;
    __getControlSignalCount: u32 #align 4;
    __getControlSignal: u32 #align 4;
    __clearControlEvents: u32 #align 4;
    __getPolyphony: u32 #align 4;
    __activeVoiceCount: u32 #align 4;
    __setMuted: u32 #align 4;
    __getLength: u32 #align 4;
    __getIndexForStep: u32 #align 4;
    __getNoteAtIndex: u32 #align 4;
    __getSignalForController: u32 #align 4;

#place __newTrack;
    newTrack:               #type () -> *SequenceTrack #c_call = --- #align 4;;
#place __freeTrack;
    freeTrack:              #type (track: *SequenceTrack) -> void #c_call = --- #align 4;;

#place __setInstrument;
    setInstrument:          #type (track: *SequenceTrack, inst: *PDSynthInstrument) -> void #c_call = --- #align 4;;
#place __getInstrument;
    getInstrument:          #type (track: *SequenceTrack) -> *PDSynthInstrument #c_call = --- #align 4;;

#place __addNoteEvent;
    addNoteEvent:           #type (track: *SequenceTrack, step: u32, len: u32, note: MIDINote, velocity: float) -> void #c_call = --- #align 4;;
#place __removeNoteEvent;
    removeNoteEvent:        #type (track: *SequenceTrack, step: u32, note: MIDINote) -> void #c_call = --- #align 4;;
#place __clearNotes;
    clearNotes:             #type (track: *SequenceTrack) -> void #c_call = --- #align 4;;

#place __getControlSignalCount;
    getControlSignalCount:  #type (track: *SequenceTrack) -> s32 #c_call = --- #align 4;;
#place __getControlSignal;
    getControlSignal:       #type (track: *SequenceTrack, idx: s32) -> *ControlSignal #c_call = --- #align 4;;
#place __clearControlEvents;
    clearControlEvents:     #type (track: *SequenceTrack) -> void #c_call = --- #align 4;;

#place __getPolyphony;
    getPolyphony:           #type (track: *SequenceTrack) -> s32 #c_call = --- #align 4;;
#place __activeVoiceCount;
    activeVoiceCount:       #type (track: *SequenceTrack) -> s32 #c_call = --- #align 4;;

#place __setMuted;
    setMuted:               #type (track: *SequenceTrack, mute: s32) -> void #c_call = --- #align 4;;

#place __getLength;
    getLength:              #type (track: *SequenceTrack) -> u32 #c_call; // in steps, includes full last not = --- #align 4;e
#place __getIndexForStep;
    getIndexForStep:        #type (track: *SequenceTrack, step: u32) -> s32 #c_call = --- #align 4;;
#place __getNoteAtIndex;
    getNoteAtIndex:         #type (track: *SequenceTrack, index: s32, outStep: *u32, outLen: *u32, outNote: *MIDINote, outVelocity: *float) -> s32 #c_call = --- #align 4;;

    // 1.10
#place __getSignalForController;
    getSignalForController: #type (track: *SequenceTrack, controller: s32, create: s32) -> *ControlSignal #c_call = --- #align 4;;
}

SoundSequence :: struct {}
SequenceFinishedCallback :: #type (seq: *SoundSequence, userdata: *void) -> void #c_call;

playdate_sound_sequence :: struct {
    __newSequence: u32 #align 4;
    __freeSequence: u32 #align 4;
    __loadMIDIFile: u32 #align 4;
    __getTime: u32 #align 4;
    __setTime: u32 #align 4;
    __setLoops: u32 #align 4;
    __getTempo_deprecated: u32 #align 4;
    __setTempo: u32 #align 4;
    __getTrackCount: u32 #align 4;
    __addTrack: u32 #align 4;
    __getTrackAtIndex: u32 #align 4;
    __setTrackAtIndex: u32 #align 4;
    __allNotesOff: u32 #align 4;
    __isPlaying: u32 #align 4;
    __getLength: u32 #align 4;
    __play: u32 #align 4;
    __stop: u32 #align 4;
    __getCurrentStep: u32 #align 4;
    __setCurrentStep: u32 #align 4;
    __getTempo: u32 #align 4;

#place __newSequence;
    newSequence:         #type () -> *SoundSequence #c_call = --- #align 4;
#place __freeSequence;
    freeSequence:        #type (sequence: *SoundSequence) -> void #c_call = --- #align 4;

#place __loadMIDIFile;
    loadMIDIFile:        #type (seq: *SoundSequence, path: *u8) -> s32 #c_call = --- #align 4;
#place __getTime;
    getTime:             #type (seq: *SoundSequence) -> u32 #c_call = --- #align 4;
#place __setTime;
    setTime:             #type (seq: *SoundSequence, time: u32) -> void #c_call = --- #align 4;
#place __setLoops;
    setLoops:            #type (seq: *SoundSequence, loopstart: s32, loopend: s32, loops: s32) -> void #c_call = --- #align 4;
#place __getTempo_deprecated;
    getTempo_deprecated: #type (seq: *SoundSequence) -> s32 #c_call = --- #align 4;
#place __setTempo;
    setTempo:            #type (seq: *SoundSequence, stepsPerSecond: float) -> void #c_call = --- #align 4;
#place __getTrackCount;
    getTrackCount:       #type (seq: *SoundSequence) -> s32 #c_call = --- #align 4;
#place __addTrack;
    addTrack:            #type (seq: *SoundSequence) -> *SequenceTrack #c_call = --- #align 4;
#place __getTrackAtIndex;
    getTrackAtIndex:     #type (seq: *SoundSequence, track: u32) -> *SequenceTrack #c_call = --- #align 4;
#place __setTrackAtIndex;
    setTrackAtIndex:     #type (seq: *SoundSequence, track: *SequenceTrack, idx: u32) -> void #c_call = --- #align 4;
#place __allNotesOff;
    allNotesOff:         #type (seq: *SoundSequence) -> void #c_call = --- #align 4;

    // 1.1
#place __isPlaying;
    isPlaying:           #type (seq: *SoundSequence) -> s32 #c_call = --- #align 4;
#place __getLength;
    getLength:           #type (seq: *SoundSequence) -> u32 #c_call; // in steps, includes full last not = --- #align 4e
#place __play;
    play:                #type (seq: *SoundSequence, finishCallback: SequenceFinishedCallback, userdata: *void) -> void #c_call = --- #align 4;
#place __stop;
    stop:                #type (seq: *SoundSequence) -> void #c_call = --- #align 4;
#place __getCurrentStep;
    getCurrentStep:      #type (seq: *SoundSequence, timeOffset: *s32) -> s32 #c_call = --- #align 4;
#place __setCurrentStep;
    setCurrentStep:      #type (seq: *SoundSequence, step: s32, timeOffset: s32, playNotes: s32) -> void #c_call = --- #align 4;

    // 2.5
#place __getTempo;
    getTempo:            #type (seq: *SoundSequence) -> float #c_call = --- #align 4;
}

TwoPoleFilter :: struct {}

TwoPoleFilterType :: enum s32 {
    LowPass   :: 0;
    HighPass  :: 1;
    BandPass  :: 2;
    Notch     :: 3;
    PEQ       :: 4;
    LowShelf  :: 5;
    HighShelf :: 6;

    kFilterTypeLowPass   :: LowPass;
    kFilterTypeHighPass  :: HighPass;
    kFilterTypeBandPass  :: BandPass;
    kFilterTypeNotch     :: Notch;
    kFilterTypePEQ       :: PEQ;
    kFilterTypeLowShelf  :: LowShelf;
    kFilterTypeHighShelf :: HighShelf;
}

playdate_sound_effect_twopolefilter :: struct {
    __newFilter: u32 #align 4;
    __freeFilter: u32 #align 4;
    __setType: u32 #align 4;
    __setFrequency: u32 #align 4;
    __setFrequencyModulator: u32 #align 4;
    __getFrequencyModulator: u32 #align 4;
    __setGain: u32 #align 4;
    __setResonance: u32 #align 4;
    __setResonanceModulator: u32 #align 4;
    __getResonanceModulator: u32 #align 4;

#place __newFilter;
    newFilter:             #type () -> *TwoPoleFilter #c_call = --- #align 4;
#place __freeFilter;
    freeFilter:            #type (filter: *TwoPoleFilter) -> void #c_call = --- #align 4;
#place __setType;
    setType:               #type (filter: *TwoPoleFilter, type: TwoPoleFilterType) -> void #c_call = --- #align 4;
#place __setFrequency;
    setFrequency:          #type (filter: *TwoPoleFilter, frequency: float) -> void #c_call = --- #align 4;
#place __setFrequencyModulator;
    setFrequencyModulator: #type (filter: *TwoPoleFilter, signal: *PDSynthSignalValue) -> void #c_call = --- #align 4;
#place __getFrequencyModulator;
    getFrequencyModulator: #type (filter: *TwoPoleFilter) -> *PDSynthSignalValue #c_call = --- #align 4;
#place __setGain;
    setGain:               #type (filter: *TwoPoleFilter, gain: float) -> void #c_call = --- #align 4;
#place __setResonance;
    setResonance:          #type (filter: *TwoPoleFilter, resonance: float) -> void #c_call = --- #align 4;
#place __setResonanceModulator;
    setResonanceModulator: #type (filter: *TwoPoleFilter, signal: *PDSynthSignalValue) -> void #c_call = --- #align 4;
#place __getResonanceModulator;
    getResonanceModulator: #type (filter: *TwoPoleFilter) -> *PDSynthSignalValue #c_call = --- #align 4;
}

OnePoleFilter :: struct {}

playdate_sound_effect_onepolefilter :: struct {
    __newFilter: u32 #align 4;
    __freeFilter: u32 #align 4;
    __setParameter: u32 #align 4;
    __setParameterModulator: u32 #align 4;
    __getParameterModulator: u32 #align 4;

#place __newFilter;
    newFilter:             #type () -> *OnePoleFilter #c_call = --- #align 4;
#place __freeFilter;
    freeFilter:            #type (filter: *OnePoleFilter) -> void #c_call = --- #align 4;
#place __setParameter;
    setParameter:          #type (filter: *OnePoleFilter, parameter: float) -> void #c_call = --- #align 4;
#place __setParameterModulator;
    setParameterModulator: #type (filter: *OnePoleFilter, signal: *PDSynthSignalValue) -> void #c_call = --- #align 4;
#place __getParameterModulator;
    getParameterModulator: #type (filter: *OnePoleFilter) -> *PDSynthSignalValue #c_call = --- #align 4;
}

BitCrusher :: struct {}

playdate_sound_effect_bitcrusher :: struct {
    __newBitCrusher: u32 #align 4;
    __freeBitCrusher: u32 #align 4;
    __setAmount: u32 #align 4;
    __setAmountModulator: u32 #align 4;
    __getAmountModulator: u32 #align 4;
    __setUndersampling: u32 #align 4;
    __setUndersampleModulator: u32 #align 4;
    __getUndersampleModulator: u32 #align 4;

#place __newBitCrusher;
    newBitCrusher:           #type () -> *BitCrusher #c_call = --- #align 4;;
#place __freeBitCrusher;
    freeBitCrusher:          #type (filter: *BitCrusher) -> void #c_call = --- #align 4;;
#place __setAmount;
    setAmount:               #type (filter: *BitCrusher, amount: float) -> void #c_call = --- #align 4;;
#place __setAmountModulator;
    setAmountModulator:      #type (filter: *BitCrusher, signal: *PDSynthSignalValue) -> void #c_call = --- #align 4;;
#place __getAmountModulator;
    getAmountModulator:      #type (filter: *BitCrusher) -> *PDSynthSignalValue #c_call = --- #align 4;;
#place __setUndersampling;
    setUndersampling:        #type (filter: *BitCrusher, undersampling: float) -> void #c_call = --- #align 4;;
#place __setUndersampleModulator;
    setUndersampleModulator: #type (filter: *BitCrusher, signal: *PDSynthSignalValue) -> void #c_call = --- #align 4;;
#place __getUndersampleModulator;
    getUndersampleModulator: #type (filter: *BitCrusher) -> *PDSynthSignalValue #c_call = --- #align 4;;
}

RingModulator :: struct {}

playdate_sound_effect_ringmodulator :: struct {
    __newRingmod: u32 #align 4;
    __freeRingmod: u32 #align 4;
    __setFrequency: u32 #align 4;
    __setFrequencyModulator: u32 #align 4;
    __getFrequencyModulator: u32 #align 4;

#place __newRingmod;
    newRingmod:            #type () -> *RingModulator #c_call = --- #align 4;;
#place __freeRingmod;
    freeRingmod:           #type (filter: *RingModulator) -> void #c_call = --- #align 4;;
#place __setFrequency;
    setFrequency:          #type (filter: *RingModulator, frequency: float) -> void #c_call = --- #align 4;;
#place __setFrequencyModulator;
    setFrequencyModulator: #type (filter: *RingModulator, signal: *PDSynthSignalValue) -> void #c_call = --- #align 4;;
#place __getFrequencyModulator;
    getFrequencyModulator: #type (filter: *RingModulator) -> *PDSynthSignalValue #c_call = --- #align 4;;
}

DelayLine :: struct {}
DelayLineTap :: struct {}

playdate_sound_effect_delayline :: struct {
    __newDelayLine: u32 #align 4;
    __freeDelayLine: u32 #align 4;
    __setLength: u32 #align 4;
    __setFeedback: u32 #align 4;
    __addTap: u32 #align 4;
    __freeTap: u32 #align 4;
    __setTapDelay: u32 #align 4;
    __setTapDelayModulator: u32 #align 4;
    __getTapDelayModulator: u32 #align 4;
    __setTapChannelsFlipped: u32 #align 4;

#place __newDelayLine;
    newDelayLine:          #type (length: s32, stereo: s32) -> *DelayLine #c_call = --- #align 4;
#place __freeDelayLine;
    freeDelayLine:         #type (filter: *DelayLine) -> void #c_call = --- #align 4;
#place __setLength;
    setLength:             #type (d: *DelayLine, frames: s32) -> void #c_call = --- #align 4;
#place __setFeedback;
    setFeedback:           #type (d: *DelayLine, fb: float) -> void #c_call = --- #align 4;
#place __addTap;
    addTap:                #type (d: *DelayLine, delay: s32) -> *DelayLineTap #c_call = --- #align 4;

    // note that DelayLineTap is a SoundSource, not a SoundEffect
#place __freeTap;
    freeTap:               #type (tap: *DelayLineTap) -> void #c_call = --- #align 4;
#place __setTapDelay;
    setTapDelay:           #type (t: *DelayLineTap, frames: s32) -> void #c_call = --- #align 4;
#place __setTapDelayModulator;
    setTapDelayModulator:  #type (t: *DelayLineTap, mod: *PDSynthSignalValue) -> void #c_call = --- #align 4;
#place __getTapDelayModulator;
    getTapDelayModulator:  #type (t: *DelayLineTap) -> *PDSynthSignalValue #c_call = --- #align 4;
#place __setTapChannelsFlipped;
    setTapChannelsFlipped: #type (t: *DelayLineTap, flip: s32) -> void #c_call = --- #align 4;
}

Overdrive :: struct {}

playdate_sound_effect_overdrive :: struct {
    __newOverdrive: u32 #align 4;
    __freeOverdrive: u32 #align 4;
    __setGain: u32 #align 4;
    __setLimit: u32 #align 4;
    __setLimitModulator: u32 #align 4;
    __getLimitModulator: u32 #align 4;
    __setOffset: u32 #align 4;
    __setOffsetModulator: u32 #align 4;
    __getOffsetModulator: u32 #align 4;

#place __newOverdrive;
    newOverdrive:       #type () -> *Overdrive #c_call = --- #align 4;;
#place __freeOverdrive;
    freeOverdrive:      #type (filter: *Overdrive) -> void #c_call = --- #align 4;;
#place __setGain;
    setGain:            #type (o: *Overdrive, gain: float) -> void #c_call = --- #align 4;;
#place __setLimit;
    setLimit:           #type (o: *Overdrive, limit: float) -> void #c_call = --- #align 4;;
#place __setLimitModulator;
    setLimitModulator:  #type (o: *Overdrive, mod: *PDSynthSignalValue) -> void #c_call = --- #align 4;;
#place __getLimitModulator;
    getLimitModulator:  #type (o: *Overdrive) -> *PDSynthSignalValue #c_call = --- #align 4;;
#place __setOffset;
    setOffset:          #type (o: *Overdrive, offset: float) -> void #c_call = --- #align 4;;
#place __setOffsetModulator;
    setOffsetModulator: #type (o: *Overdrive, mod: *PDSynthSignalValue) -> void #c_call = --- #align 4;;
#place __getOffsetModulator;
    getOffsetModulator: #type (o: *Overdrive) -> *PDSynthSignalValue #c_call = --- #align 4;;
}

SoundEffect :: struct {}
effectProc :: #type (e: *SoundEffect, left: *s32, right: *s32, nsamples: s32, bufactive: s32) -> s32 #c_call;

playdate_sound_effect :: struct {
    __newEffect: u32 #align 4;
    __freeEffect: u32 #align 4;
    __setMix: u32 #align 4;
    __setMixModulator: u32 #align 4;
    __getMixModulator: u32 #align 4;
    __setUserdata: u32 #align 4;
    __getUserdata: u32 #align 4;
    __twopolefilter: u32 #align 4;
    __onepolefilter: u32 #align 4;
    __bitcrusher: u32 #align 4;
    __ringmodulator: u32 #align 4;
    __delayline: u32 #align 4;
    __overdrive: u32 #align 4;

#place __newEffect;
    newEffect:       #type (proc: effectProc, userdata: *void) -> *SoundEffect #c_call = --- #align 4;
#place __freeEffect;
    freeEffect:      #type (effect: *SoundEffect) -> void #c_call = --- #align 4;

#place __setMix;
    setMix:          #type (effect: *SoundEffect, level: float) -> void #c_call = --- #align 4;
#place __setMixModulator;
    setMixModulator: #type (effect: *SoundEffect, signal: *PDSynthSignalValue) -> void #c_call = --- #align 4;
#place __getMixModulator;
    getMixModulator: #type (effect: *SoundEffect) -> *PDSynthSignalValue #c_call = --- #align 4;

#place __setUserdata;
    setUserdata:     #type (effect: *SoundEffect, userdata: *void) -> void #c_call = --- #align 4;
#place __getUserdata;
    getUserdata:     #type (effect: *SoundEffect) -> *void #c_call = --- #align 4;

#place __twopolefilter;
    twopolefilter:   *playdate_sound_effect_twopolefilter = --- #align 4;
#place __onepolefilter;
    onepolefilter:   *playdate_sound_effect_onepolefilter = --- #align 4;
#place __bitcrusher;
    bitcrusher:      *playdate_sound_effect_bitcrusher = --- #align 4;
#place __ringmodulator;
    ringmodulator:   *playdate_sound_effect_ringmodulator = --- #align 4;
#place __delayline;
    delayline:       *playdate_sound_effect_delayline = --- #align 4;
#place __overdrive;
    overdrive:       *playdate_sound_effect_overdrive = --- #align 4;
}

SoundChannel :: struct {}

AudioSourceFunction :: #type (_context: *void, left: *s16, right: *s16, len: s32) -> s32 #c_call;

playdate_sound_channel :: struct {
    __newChannel: u32 #align 4;
    __freeChannel: u32 #align 4;
    __addSource: u32 #align 4;
    __removeSource: u32 #align 4;
    __addCallbackSource: u32 #align 4;
    __addEffect: u32 #align 4;
    __removeEffect: u32 #align 4;
    __setVolume: u32 #align 4;
    __getVolume: u32 #align 4;
    __setVolumeModulator: u32 #align 4;
    __getVolumeModulator: u32 #align 4;
    __setPan: u32 #align 4;
    __setPanModulator: u32 #align 4;
    __getPanModulator: u32 #align 4;
    __getDryLevelSignal: u32 #align 4;
    __getWetLevelSignal: u32 #align 4;

#place __newChannel;
    newChannel:         #type () -> *SoundChannel #c_call = --- #align 4;
#place __freeChannel;
    freeChannel:        #type (channel: *SoundChannel) -> void #c_call = --- #align 4;
#place __addSource;
    addSource:          #type (channel: *SoundChannel, source: *SoundSource) -> s32 #c_call = --- #align 4;
#place __removeSource;
    removeSource:       #type (channel: *SoundChannel, source: *SoundSource) -> s32 #c_call = --- #align 4;
#place __addCallbackSource;
    addCallbackSource:  #type (channel: *SoundChannel, callback: AudioSourceFunction, _context: *void, stereo: s32) -> *SoundSource #c_call = --- #align 4;
#place __addEffect;
    addEffect:          #type (channel: *SoundChannel, effect: *SoundEffect) -> void #c_call = --- #align 4;
#place __removeEffect;
    removeEffect:       #type (channel: *SoundChannel, effect: *SoundEffect) -> void #c_call = --- #align 4;
#place __setVolume;
    setVolume:          #type (channel: *SoundChannel, volume: float) -> void #c_call = --- #align 4;
#place __getVolume;
    getVolume:          #type (channel: *SoundChannel) -> float #c_call = --- #align 4;
#place __setVolumeModulator;
    setVolumeModulator: #type (channel: *SoundChannel, mod: *PDSynthSignalValue) -> void #c_call = --- #align 4;
#place __getVolumeModulator;
    getVolumeModulator: #type (channel: *SoundChannel) -> *PDSynthSignalValue #c_call = --- #align 4;
#place __setPan;
    setPan:             #type (channel: *SoundChannel, pan: float) -> void #c_call = --- #align 4;
#place __setPanModulator;
    setPanModulator:    #type (channel: *SoundChannel, mod: *PDSynthSignalValue) -> void #c_call = --- #align 4;
#place __getPanModulator;
    getPanModulator:    #type (channel: *SoundChannel) -> *PDSynthSignalValue #c_call = --- #align 4;
#place __getDryLevelSignal;
    getDryLevelSignal:  #type (channel: *SoundChannel) -> *PDSynthSignalValue #c_call = --- #align 4;
#place __getWetLevelSignal;
    getWetLevelSignal:  #type (channel: *SoundChannel) -> *PDSynthSignalValue #c_call = --- #align 4;
}

RecordCallback :: #type (_context: *void, buffer: *s16, length: s32) -> s32 #c_call;

MicSource :: enum s32 {
    Autodetect :: 0;
    Internal   :: 1;
    Headset    :: 2;

    kMicInputAutodetect :: Autodetect;
    kMicInputInternal   :: Internal;
    kMicInputHeadset    :: Headset;
}

playdate_sound :: struct {
    __channel: u32 #align 4;
    __fileplayer: u32 #align 4;
    __sample: u32 #align 4;
    __sampleplayer: u32 #align 4;
    __synth: u32 #align 4;
    __sequence: u32 #align 4;
    __effect: u32 #align 4;
    __lfo: u32 #align 4;
    __envelope: u32 #align 4;
    __source: u32 #align 4;
    __controlsignal: u32 #align 4;
    __track: u32 #align 4;
    __instrument: u32 #align 4;
    __getCurrentTime: u32 #align 4;
    __addSource: u32 #align 4;
    __getDefaultChannel: u32 #align 4;
    __addChannel: u32 #align 4;
    __removeChannel: u32 #align 4;
    __setMicCallback: u32 #align 4;
    __getHeadphoneState: u32 #align 4;
    __setOutputsActive: u32 #align 4;
    __removeSource: u32 #align 4;
    __signal: u32 #align 4;
    __getError: u32 #align 4;

#place __channel;
    channel:           *playdate_sound_channel = --- #align 4;;
#place __fileplayer;
    fileplayer:        *playdate_sound_fileplayer = --- #align 4;;
#place __sample;
    sample:            *playdate_sound_sample = --- #align 4;;
#place __sampleplayer;
    sampleplayer:      *playdate_sound_sampleplayer = --- #align 4;;
#place __synth;
    synth:             *playdate_sound_synth = --- #align 4;;
#place __sequence;
    sequence:          *playdate_sound_sequence = --- #align 4;;
#place __effect;
    effect:            *playdate_sound_effect = --- #align 4;;
#place __lfo;
    lfo:               *playdate_sound_lfo = --- #align 4;;
#place __envelope;
    envelope:          *playdate_sound_envelope = --- #align 4;;
#place __source;
    source:            *playdate_sound_source = --- #align 4;;
#place __controlsignal;
    controlsignal:     *playdate_control_signal = --- #align 4;;
#place __track;
    track:             *playdate_sound_track = --- #align 4;;
#place __instrument;
    instrument:        *playdate_sound_instrument = --- #align 4;;

#place __getCurrentTime;
    getCurrentTime:    #type () -> u32 #c_call = --- #align 4;;
#place __addSource;
    addSource:         #type (callback: AudioSourceFunction, _context: *void, stereo: s32) -> *SoundSource #c_call = --- #align 4;;

#place __getDefaultChannel;
    getDefaultChannel: #type () -> *SoundChannel #c_call = --- #align 4;;

#place __addChannel;
    addChannel:        #type (channel: *SoundChannel) -> s32 #c_call = --- #align 4;;
#place __removeChannel;
    removeChannel:     #type (channel: *SoundChannel) -> s32 #c_call = --- #align 4;;

#place __setMicCallback;
    setMicCallback:    #type (callback: RecordCallback, _context: *void, source: MicSource) -> s32 #c_call = --- #align 4;;
#place __getHeadphoneState;
    getHeadphoneState: #type (headphone: *s32, headsetmic: *s32, changeCallback: #type (headphone: s32, mic: s32) -> void #c_call) -> void #c_call = --- #align 4;;
#place __setOutputsActive;
    setOutputsActive:  #type (headphone: s32, speaker: s32) -> void #c_call = --- #align 4;;

    // 1.5
#place __removeSource;
    removeSource:      #type (source: *SoundSource) -> s32 #c_call = --- #align 4;;

    // 1.12
#place __signal;
    signal:            *playdate_sound_signal = --- #align 4;;

    // 2.2
#place __getError;
    getError:          #type () -> *u8 #c_call = --- #align 4;;
}

playdate_display :: struct {
    __getWidth: u32 #align 4;
    __getHeight: u32 #align 4;
    __setRefreshRate: u32 #align 4;
    __setInverted: u32 #align 4;
    __setScale: u32 #align 4;
    __setMosaic: u32 #align 4;
    __setFlipped: u32 #align 4;
    __setOffset: u32 #align 4;

#place __getWidth;
    getWidth:       #type () -> s32 #c_call = --- #align 4;
#place __getHeight;
    getHeight:      #type () -> s32 #c_call = --- #align 4;

#place __setRefreshRate;
    setRefreshRate: #type (rate: float) -> void #c_call = --- #align 4;

#place __setInverted;
    setInverted:    #type (flag: s32) -> void #c_call = --- #align 4;
#place __setScale;
    setScale:       #type (s: u32) -> void #c_call = --- #align 4;
#place __setMosaic;
    setMosaic:      #type (x: u32, y: u32) -> void #c_call = --- #align 4;
#place __setFlipped;
    setFlipped:     #type (x: s32, y: s32) -> void #c_call = --- #align 4;
#place __setOffset;
    setOffset:      #type (x: s32, y: s32) -> void #c_call = --- #align 4;
}

PDScore :: struct {
    __rank: u32 #align 4;
    __value: u32 #align 4;
    __player: u32 #align 4;

#place __rank;
    rank:   u32 = --- #align 4;
#place __value;
    value:  u32 = --- #align 4;
#place __player;
    player: *u8 = --- #align 4;
}

PDScoresList :: struct {
    __boardID: u32 #align 4;
    __count: u32 #align 4;
    __lastUpdated: u32 #align 4;
    __playerIncluded: u32 #align 4;
    __limit: u32 #align 4;
    __scores: u32 #align 4;

#place __boardID;
    boardID:        *u8 = --- #align 4;
#place __count;
    count:          u32 = --- #align 4;
#place __lastUpdated;
    lastUpdated:    u32 = --- #align 4;
#place __playerIncluded;
    playerIncluded: s32 = --- #align 4;
#place __limit;
    limit:          u32 = --- #align 4;
#place __scores;
    scores:         *PDScore = --- #align 4;
}

PDBoard :: struct {
    __boardID: u32 #align 4;
    __name: u32 #align 4;

#place __boardID;
    boardID: *u8 = --- #align 4;
#place __name;
    name:    *u8 = --- #align 4;
}

PDBoardsList :: struct {
    __count: u32 #align 4;
    __lastUpdated: u32 #align 4;
    __boards: u32 #align 4;

#place __count;
    count:       u32 = --- #align 4;
#place __lastUpdated;
    lastUpdated: u32 = --- #align 4;
#place __boards;
    boards:      *PDBoard = --- #align 4;
}

AddScoreCallback :: #type (score: *PDScore, errorMessage: *u8) -> void #c_call;
PersonalBestCallback :: #type (score: *PDScore, errorMessage: *u8) -> void #c_call;
BoardsListCallback :: #type (boards: *PDBoardsList, errorMessage: *u8) -> void #c_call;
ScoresCallback :: #type (scores: *PDScoresList, errorMessage: *u8) -> void #c_call;

playdate_scoreboards :: struct {
    __addScore: u32 #align 4;
    __getPersonalBest: u32 #align 4;
    __freeScore: u32 #align 4;
    __getScoreboards: u32 #align 4;
    __freeBoardsList: u32 #align 4;
    __getScores: u32 #align 4;
    __freeScoresList: u32 #align 4;

#place __addScore;
    addScore:        #type (boardId: *u8, value: u32, callback: AddScoreCallback) -> s32 #c_call = --- #align 4;
#place __getPersonalBest;
    getPersonalBest: #type (boardId: *u8, callback: PersonalBestCallback) -> s32 #c_call = --- #align 4;
#place __freeScore;
    freeScore:       #type (score: *PDScore) -> void #c_call = --- #align 4;

#place __getScoreboards;
    getScoreboards:  #type (callback: BoardsListCallback) -> s32 #c_call = --- #align 4;
#place __freeBoardsList;
    freeBoardsList:  #type (boardsList: *PDBoardsList) -> void #c_call = --- #align 4;

#place __getScores;
    getScores:       #type (boardId: *u8, callback: ScoresCallback) -> s32 #c_call = --- #align 4;
#place __freeScoresList;
    freeScoresList:  #type (scoresList: *PDScoresList) -> void #c_call = --- #align 4;
}

PlaydateAPI :: struct {
    __system: u32 #align 4;
    __file: u32 #align 4;
    __graphics: u32 #align 4;
    __sprite: u32 #align 4;
    __display: u32 #align 4;
    __sound: u32 #align 4;
    __lua: u32 #align 4;
    __json: u32 #align 4;
    __scoreboards: u32 #align 4;

#place __system;
    system:      *playdate_sys = --- #align 4;
#place __file;
    file:        *playdate_file = --- #align 4;
#place __graphics;
    graphics:    *playdate_graphics = --- #align 4;
#place __sprite;
    sprite:      *playdate_sprite = --- #align 4;
#place __display;
    display:     *playdate_display = --- #align 4;
#place __sound;
    sound:       *playdate_sound = --- #align 4;
#place __lua;
    lua:         *playdate_lua = --- #align 4;
#place __json;
    json:        *playdate_json = --- #align 4;
#place __scoreboards;
    scoreboards: *playdate_scoreboards = --- #align 4;
}

PDSystemEvent :: enum s32 {
    Init        :: 0;
    InitLua     :: 1;
    Lock        :: 2;
    Unlock      :: 3;
    Pause       :: 4;
    Resume      :: 5;
    Terminate   :: 6;
    KeyPressed  :: 7;
    KeyReleased :: 8;
    LowPower    :: 9;

    kEventInit        :: Init;
    kEventInitLua     :: InitLua;
    kEventLock        :: Lock;
    kEventUnlock      :: Unlock;
    kEventPause       :: Pause;
    kEventResume      :: Resume;
    kEventTerminate   :: Terminate;
    kEventKeyPressed  :: KeyPressed;
    kEventKeyReleased :: KeyReleased;
    kEventLowPower    :: LowPower;
}

#scope_file


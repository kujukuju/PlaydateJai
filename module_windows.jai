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
    left:   s32;
    right:  s32; // not inclusive
    top:    s32;
    bottom: s32; // not inclusive
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
LCDColor :: u64;

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
    loadVideo:        #type (path: *u8) -> *LCDVideoPlayer #c_call;
    freePlayer:       #type (p: *LCDVideoPlayer) -> void #c_call;
    setContext:       #type (p: *LCDVideoPlayer, _context: *LCDBitmap) -> s32 #c_call;
    useScreenContext: #type (p: *LCDVideoPlayer) -> void #c_call;
    renderFrame:      #type (p: *LCDVideoPlayer, n: s32) -> s32 #c_call;
    getError:         #type (p: *LCDVideoPlayer) -> *u8 #c_call;
    getInfo:          #type (p: *LCDVideoPlayer, outWidth: *s32, outHeight: *s32, outFrameRate: *float, outFrameCount: *s32, outCurrentFrame: *s32) -> void #c_call;
    getContext:       #type (p: *LCDVideoPlayer) -> *LCDBitmap #c_call;
}

playdate_graphics :: struct {
    video:                  *playdate_video;

    // Drawing Functions
    clear:                  #type (color: LCDColor) -> void #c_call;
    setBackgroundColor:     #type (color: LCDSolidColor) -> void #c_call;
    setStencil:             #type (stencil: *LCDBitmap) -> void #c_call; // deprecated in favor of setStencilImage, which adds a "tile" flag
    setDrawMode:            #type (mode: LCDBitmapDrawMode) -> LCDBitmapDrawMode #c_call;
    setDrawOffset:          #type (dx: s32, dy: s32) -> void #c_call;
    setClipRect:            #type (x: s32, y: s32, width: s32, height: s32) -> void #c_call;
    clearClipRect:          #type () -> void #c_call;
    setLineCapStyle:        #type (endCapStyle: LCDLineCapStyle) -> void #c_call;
    setFont:                #type (font: *LCDFont) -> void #c_call;
    setTextTracking:        #type (tracking: s32) -> void #c_call;
    pushContext:            #type (target: *LCDBitmap) -> void #c_call;
    popContext:             #type () -> void #c_call;

    drawBitmap:             #type (bitmap: *LCDBitmap, x: s32, y: s32, flip: LCDBitmapFlip) -> void #c_call;
    tileBitmap:             #type (bitmap: *LCDBitmap, x: s32, y: s32, width: s32, height: s32, flip: LCDBitmapFlip) -> void #c_call;
    drawLine:               #type (x1: s32, y1: s32, x2: s32, y2: s32, width: s32, color: LCDColor) -> void #c_call;
    fillTriangle:           #type (x1: s32, y1: s32, x2: s32, y2: s32, x3: s32, y3: s32, color: LCDColor) -> void #c_call;
    drawRect:               #type (x: s32, y: s32, width: s32, height: s32, color: LCDColor) -> void #c_call;
    fillRect:               #type (x: s32, y: s32, width: s32, height: s32, color: LCDColor) -> void #c_call;
    drawEllipse:            #type (x: s32, y: s32, width: s32, height: s32, lineWidth: s32, startAngle: float, endAngle: float, color: LCDColor) -> void #c_call; // stroked inside the rect
    fillEllipse:            #type (x: s32, y: s32, width: s32, height: s32, startAngle: float, endAngle: float, color: LCDColor) -> void #c_call;
    drawScaledBitmap:       #type (bitmap: *LCDBitmap, x: s32, y: s32, xscale: float, yscale: float) -> void #c_call;
    drawText:               #type (text: *void, len: u64, encoding: PDStringEncoding, x: s32, y: s32) -> s32 #c_call;

    // LCDBitmap
    newBitmap:              #type (width: s32, height: s32, bgcolor: LCDColor) -> *LCDBitmap #c_call;
    freeBitmap:             #type (unknown0: *LCDBitmap) -> void #c_call;
    loadBitmap:             #type (path: *u8, outerr: **u8) -> *LCDBitmap #c_call;
    copyBitmap:             #type (bitmap: *LCDBitmap) -> *LCDBitmap #c_call;
    loadIntoBitmap:         #type (path: *u8, bitmap: *LCDBitmap, outerr: **u8) -> void #c_call;
    getBitmapData:          #type (bitmap: *LCDBitmap, width: *s32, height: *s32, rowbytes: *s32, mask: **u8, data: **u8) -> void #c_call;
    clearBitmap:            #type (bitmap: *LCDBitmap, bgcolor: LCDColor) -> void #c_call;
    rotatedBitmap:          #type (bitmap: *LCDBitmap, rotation: float, xscale: float, yscale: float, allocedSize: *s32) -> *LCDBitmap #c_call;

    // LCDBitmapTable
    newBitmapTable:         #type (count: s32, width: s32, height: s32) -> *LCDBitmapTable #c_call;
    freeBitmapTable:        #type (table: *LCDBitmapTable) -> void #c_call;
    loadBitmapTable:        #type (path: *u8, outerr: **u8) -> *LCDBitmapTable #c_call;
    loadIntoBitmapTable:    #type (path: *u8, table: *LCDBitmapTable, outerr: **u8) -> void #c_call;
    getTableBitmap:         #type (table: *LCDBitmapTable, idx: s32) -> *LCDBitmap #c_call;

    // LCDFont
    loadFont:               #type (path: *u8, outErr: **u8) -> *LCDFont #c_call;
    getFontPage:            #type (font: *LCDFont, c: u32) -> *LCDFontPage #c_call;
    getPageGlyph:           #type (page: *LCDFontPage, c: u32, bitmap: **LCDBitmap, advance: *s32) -> *LCDFontGlyph #c_call;
    getGlyphKerning:        #type (glyph: *LCDFontGlyph, glyphcode: u32, nextcode: u32) -> s32 #c_call;
    getTextWidth:           #type (font: *LCDFont, text: *void, len: u64, encoding: PDStringEncoding, tracking: s32) -> s32 #c_call;

    getFrame:               #type () -> *u8 #c_call; // row stride = LCD_ROWSIZE
    getDisplayFrame:        #type () -> *u8 #c_call; // row stride = LCD_ROWSIZE
    getDebugBitmap:         #type () -> *LCDBitmap #c_call; // valid in simulator only, function is NULL on device
    copyFrameBufferBitmap:  #type () -> *LCDBitmap #c_call;
    markUpdatedRows:        #type (start: s32, end: s32) -> void #c_call;
    display:                #type () -> void #c_call;

    // misc util.
    setColorToPattern:      #type (color: *LCDColor, bitmap: *LCDBitmap, x: s32, y: s32) -> void #c_call;
    checkMaskCollision:     #type (bitmap1: *LCDBitmap, x1: s32, y1: s32, flip1: LCDBitmapFlip, bitmap2: *LCDBitmap, x2: s32, y2: s32, flip2: LCDBitmapFlip, rect: LCDRect) -> s32 #c_call;

    // 1.1
    setScreenClipRect:      #type (x: s32, y: s32, width: s32, height: s32) -> void #c_call;

    // 1.1.1
    fillPolygon:            #type (nPoints: s32, coords: *s32, color: LCDColor, fillrule: LCDPolygonFillRule) -> void #c_call;
    getFontHeight:          #type (font: *LCDFont) -> u8 #c_call;

    // 1.7
    getDisplayBufferBitmap: #type () -> *LCDBitmap #c_call;
    drawRotatedBitmap:      #type (bitmap: *LCDBitmap, x: s32, y: s32, rotation: float, centerx: float, centery: float, xscale: float, yscale: float) -> void #c_call;
    setTextLeading:         #type (lineHeightAdustment: s32) -> void #c_call;

    // 1.8
    setBitmapMask:          #type (bitmap: *LCDBitmap, mask: *LCDBitmap) -> s32 #c_call;
    getBitmapMask:          #type (bitmap: *LCDBitmap) -> *LCDBitmap #c_call;

    // 1.10
    setStencilImage:        #type (stencil: *LCDBitmap, tile: s32) -> void #c_call;

    // 1.12
    makeFontFromData:       #type (data: *LCDFontData, wide: s32) -> *LCDFont #c_call;

    // 2.1
    getTextTracking:        #type () -> s32 #c_call;

    // 2.5
    setPixel:               #type (x: s32, y: s32, c: LCDColor) -> void #c_call;
    getBitmapPixel:         #type (bitmap: *LCDBitmap, x: s32, y: s32) -> LCDSolidColor #c_call;
    getBitmapTableInfo:     #type (table: *LCDBitmapTable, count: *s32, width: *s32) -> void #c_call;

    // 2.6
    drawTextInRect:         #type (text: *void, len: u64, encoding: PDStringEncoding, x: s32, y: s32, width: s32, height: s32, wrap: PDTextWrappingMode, align: PDTextAlignment) -> void #c_call;
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
    year:    u16;
    month:   u8; // 1-12
    day:     u8; // 1-31
    weekday: u8; // 1=monday-7=sunday
    hour:    u8; // 0-23
    minute:  u8;
    second:  u8;
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
    realloc:                    #type (ptr: *void, size: u64) -> *void #c_call; // ptr = NULL -> malloc, size = 0 -> free
    formatString:               #type (ret: **u8, fmt: *u8, __args: ..Any) -> s32 #c_call;
    logToConsole:               #type (fmt: *u8, __args: ..Any) -> void #c_call;
    error:                      #type (fmt: *u8, __args: ..Any) -> void #c_call;
    getLanguage:                #type () -> PDLanguage #c_call;
    getCurrentTimeMilliseconds: #type () -> u32 #c_call;
    getSecondsSinceEpoch:       #type (milliseconds: *u32) -> u32 #c_call;
    drawFPS:                    #type (x: s32, y: s32) -> void #c_call;

    setUpdateCallback:          #type (update: PDCallbackFunction, userdata: *void) -> void #c_call;
    getButtonState:             #type (current: *PDButtons, pushed: *PDButtons, released: *PDButtons) -> void #c_call;
    setPeripheralsEnabled:      #type (mask: PDPeripherals) -> void #c_call;
    getAccelerometer:           #type (outx: *float, outy: *float, outz: *float) -> void #c_call;

    getCrankChange:             #type () -> float #c_call;
    getCrankAngle:              #type () -> float #c_call;
    isCrankDocked:              #type () -> s32 #c_call;
    setCrankSoundsDisabled:     #type (flag: s32) -> s32 #c_call; // returns previous setting

    getFlipped:                 #type () -> s32 #c_call;
    setAutoLockDisabled:        #type (disable: s32) -> void #c_call;

    setMenuImage:               #type (bitmap: *LCDBitmap, xOffset: s32) -> void #c_call;
    addMenuItem:                #type (title: *u8, callback: PDMenuItemCallbackFunction, userdata: *void) -> *PDMenuItem #c_call;
    addCheckmarkMenuItem:       #type (title: *u8, value: s32, callback: PDMenuItemCallbackFunction, userdata: *void) -> *PDMenuItem #c_call;
    addOptionsMenuItem:         #type (title: *u8, optionTitles: **u8, optionsCount: s32, f: PDMenuItemCallbackFunction, userdata: *void) -> *PDMenuItem #c_call;
    removeAllMenuItems:         #type () -> void #c_call;
    removeMenuItem:             #type (menuItem: *PDMenuItem) -> void #c_call;
    getMenuItemValue:           #type (menuItem: *PDMenuItem) -> s32 #c_call;
    setMenuItemValue:           #type (menuItem: *PDMenuItem, value: s32) -> void #c_call;
    getMenuItemTitle:           #type (menuItem: *PDMenuItem) -> *u8 #c_call;
    setMenuItemTitle:           #type (menuItem: *PDMenuItem, title: *u8) -> void #c_call;
    getMenuItemUserdata:        #type (menuItem: *PDMenuItem) -> *void #c_call;
    setMenuItemUserdata:        #type (menuItem: *PDMenuItem, ud: *void) -> void #c_call;

    getReduceFlashing:          #type () -> s32 #c_call;

    // 1.1
    getElapsedTime:             #type () -> float #c_call;
    resetElapsedTime:           #type () -> void #c_call;

    // 1.4
    getBatteryPercentage:       #type () -> float #c_call;
    getBatteryVoltage:          #type () -> float #c_call;

    // 1.13
    getTimezoneOffset:          #type () -> s32 #c_call;
    shouldDisplay24HourTime:    #type () -> s32 #c_call;
    convertEpochToDateTime:     #type (epoch: u32, datetime: *PDDateTime) -> void #c_call;
    convertDateTimeToEpoch:     #type (datetime: *PDDateTime) -> u32 #c_call;

    // 2.0
    clearICache:                #type () -> void #c_call;

    // 2.4
    setButtonCallback:          #type (cb: PDButtonCallbackFunction, buttonud: *void, queuesize: s32) -> void #c_call;
    setSerialMessageCallback:   #type (callback: #type (data: *u8) -> void #c_call) -> void #c_call;
    vaFormatString:             *void /* function type contained C va_list argument */;
    parseString:                #type (str: *u8, format: *u8, __args: ..Any) -> s32 #c_call;
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
    name: *u8;
    func: lua_CFunction;
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
    name: *u8;
    type: l_valtype;
    v:    union {
        intval:   u32;
        floatval: float;
        strval:   *u8;
    };
}

playdate_lua :: struct {
    // these two return 1 on success, else 0 with an error message in outErr
    addFunction:             #type (f: lua_CFunction, name: *u8, outErr: **u8) -> s32 #c_call;
    registerClass:           #type (name: *u8, reg: *lua_reg, vals: *lua_val, isstatic: s32, outErr: **u8) -> s32 #c_call;

    pushFunction:            #type (f: lua_CFunction) -> void #c_call;
    indexMetatable:          #type () -> s32 #c_call;

    stop:                    #type () -> void #c_call;
    start:                   #type () -> void #c_call;

    // stack operations
    getArgCount:             #type () -> s32 #c_call;
    getArgType:              #type (pos: s32, outClass: **u8) -> LuaType #c_call;

    argIsNil:                #type (pos: s32) -> s32 #c_call;
    getArgBool:              #type (pos: s32) -> s32 #c_call;
    getArgInt:               #type (pos: s32) -> s32 #c_call;
    getArgFloat:             #type (pos: s32) -> float #c_call;
    getArgString:            #type (pos: s32) -> *u8 #c_call;
    getArgBytes:             #type (pos: s32, outlen: *u64) -> *u8 #c_call;
    getArgObject:            #type (pos: s32, type: *u8, outud: **LuaUDObject) -> *void #c_call;

    getBitmap:               #type (pos: s32) -> *LCDBitmap #c_call;
    getSprite:               #type (pos: s32) -> *LCDSprite #c_call;

    // for returning values back to Lua
    pushNil:                 #type () -> void #c_call;
    pushBool:                #type (val: s32) -> void #c_call;
    pushInt:                 #type (val: s32) -> void #c_call;
    pushFloat:               #type (val: float) -> void #c_call;
    pushString:              #type (str: *u8) -> void #c_call;
    pushBytes:               #type (str: *u8, len: u64) -> void #c_call;
    pushBitmap:              #type (bitmap: *LCDBitmap) -> void #c_call;
    pushSprite:              #type (sprite: *LCDSprite) -> void #c_call;

    pushObject:              #type (obj: *void, type: *u8, nValues: s32) -> *LuaUDObject #c_call;
    retainObject:            #type (obj: *LuaUDObject) -> *LuaUDObject #c_call;
    releaseObject:           #type (obj: *LuaUDObject) -> void #c_call;

    setUserValue:            #type (obj: *LuaUDObject, slot: u32) -> void #c_call; // sets item on top of stack and pops it
    getUserValue:            #type (obj: *LuaUDObject, slot: u32) -> s32 #c_call; // pushes item at slot to top of stack, returns stack position

    // calling lua from C has some overhead. use sparingly!
    callFunction_deprecated: #type (name: *u8, nargs: s32) -> void #c_call;
    callFunction:            #type (name: *u8, nargs: s32, outerr: **u8) -> s32 #c_call;
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
    type: u8;

    data: union {
        intval:    s32;
        floatval:  float;
        stringval: *u8;
        arrayval:  *void;
        tableval:  *void;
    };
}

json_intValue :: (value: json_value) -> s32 #foreign ;

json_floatValue :: (value: json_value) -> float #foreign ;

json_boolValue :: (value: json_value) -> s32 #foreign ;

json_stringValue :: (value: json_value) -> *u8 #foreign ;

json_decoder :: struct {
    decodeError:                   #type (decoder: *json_decoder, error: *u8, linenum: s32) -> void #c_call;

    // the following functions are each optional
    willDecodeSublist:             #type (decoder: *json_decoder, name: *u8, type: json_value_type) -> void #c_call;
    shouldDecodeTableValueForKey:  #type (decoder: *json_decoder, key: *u8) -> s32 #c_call;
    didDecodeTableValue:           #type (decoder: *json_decoder, key: *u8, value: json_value) -> void #c_call;
    shouldDecodeArrayValueAtIndex: #type (decoder: *json_decoder, pos: s32) -> s32 #c_call;
    didDecodeArrayValue:           #type (decoder: *json_decoder, pos: s32, value: json_value) -> void #c_call; // if pos==0, this was a bare value at the root of the file
    didDecodeSublist:              #type (decoder: *json_decoder, name: *u8, type: json_value_type) -> *void #c_call;

    userdata:                      *void;
    returnString:                  s32; // when set, the decoder skips parsing and returns the current subtree as a string
    path:                          *u8; // updated during parsing, reflects current position in tree
}

// convenience functions for setting up a table-only or array-only decoder
json_setTableDecode :: (decoder: *json_decoder, willDecodeSublist: #type (decoder: *json_decoder, name: *u8, type: json_value_type) -> void #c_call, didDecodeTableValue: #type (decoder: *json_decoder, key: *u8, value: json_value) -> void #c_call, didDecodeSublist: #type (decoder: *json_decoder, name: *u8, type: json_value_type) -> *void #c_call) -> void #foreign ;

json_setArrayDecode :: (decoder: *json_decoder, willDecodeSublist: #type (decoder: *json_decoder, name: *u8, type: json_value_type) -> void #c_call, didDecodeArrayValue: #type (decoder: *json_decoder, pos: s32, value: json_value) -> void #c_call, didDecodeSublist: #type (decoder: *json_decoder, name: *u8, type: json_value_type) -> *void #c_call) -> void #foreign ;

// fill buffer, return bytes written or -1 on end of data
json_readFunc :: #type (userdata: *void, buf: *u8, bufsize: s32) -> s32 #c_call;

json_reader :: struct {
    read:     json_readFunc;
    userdata: *void; // passed back to the read function above
}

// encoder
json_writeFunc :: #type (userdata: *void, str: *u8, len: s32) -> void #c_call;

json_encoder :: struct {
    writeStringFunc: json_writeFunc;
    userdata:        *void;

    pretty:          s32;
    #place pretty; /*bitfield 1*/ startedTable:    s32;
    #place pretty; /*bitfield 2*/ startedArray:    s32;
    #place pretty; /*bitfield 3*/ depth:           s32;

    startArray:      #type (encoder: *json_encoder) -> void #c_call;
    addArrayMember:  #type (encoder: *json_encoder) -> void #c_call;
    endArray:        #type (encoder: *json_encoder) -> void #c_call;
    startTable:      #type (encoder: *json_encoder) -> void #c_call;
    addTableMember:  #type (encoder: *json_encoder, name: *u8, len: s32) -> void #c_call;
    endTable:        #type (encoder: *json_encoder) -> void #c_call;
    writeNull:       #type (encoder: *json_encoder) -> void #c_call;
    writeFalse:      #type (encoder: *json_encoder) -> void #c_call;
    writeTrue:       #type (encoder: *json_encoder) -> void #c_call;
    writeInt:        #type (encoder: *json_encoder, num: s32) -> void #c_call;
    writeDouble:     #type (encoder: *json_encoder, num: float64) -> void #c_call;
    writeString:     #type (encoder: *json_encoder, str: *u8, len: s32) -> void #c_call;
}

playdate_json :: struct {
    initEncoder:  #type (encoder: *json_encoder, write: json_writeFunc, userdata: *void, pretty: s32) -> void #c_call;

    decode:       #type (functions: *json_decoder, reader: json_reader, outval: *json_value) -> s32 #c_call;
    decodeString: #type (functions: *json_decoder, jsonString: *u8, outval: *json_value) -> s32 #c_call;
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
    isdir:    s32;
    size:     u32;
    m_year:   s32;
    m_month:  s32;
    m_day:    s32;
    m_hour:   s32;
    m_minute: s32;
    m_second: s32;
}

playdate_file :: struct {
    geterr:    #type () -> *u8 #c_call;

    listfiles: #type (path: *u8, callback: #type (path: *u8, userdata: *void) -> void #c_call, userdata: *void, showhidden: s32) -> s32 #c_call;
    stat:      #type (path: *u8, stat: *FileStat) -> s32 #c_call;
    mkdir:     #type (path: *u8) -> s32 #c_call;
    unlink:    #type (name: *u8, recursive: s32) -> s32 #c_call;
    rename:    #type (from: *u8, to: *u8) -> s32 #c_call;

    open:      #type (name: *u8, mode: FileOptions) -> *SDFile #c_call;
    close:     #type (file: *SDFile) -> s32 #c_call;
    read:      #type (file: *SDFile, buf: *void, len: u32) -> s32 #c_call;
    write:     #type (file: *SDFile, buf: *void, len: u32) -> s32 #c_call;
    flush:     #type (file: *SDFile) -> s32 #c_call;
    tell:      #type (file: *SDFile) -> s32 #c_call;
    seek:      #type (file: *SDFile, pos: s32, whence: s32) -> s32 #c_call;
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
    x:      float;
    y:      float;
    width:  float;
    height: float;
}

PDRectMake :: (x: float, y: float, width: float, height: float) -> PDRect #foreign ;

CollisionPoint :: struct {
    x: float;
    y: float;
}

CollisionVector :: struct {
    x: s32;
    y: s32;
}

SpriteCollisionInfo :: struct {
    sprite:       *LCDSprite; // The sprite being moved
    other:        *LCDSprite; // The sprite colliding with the sprite being moved
    responseType: SpriteCollisionResponseType; // The result of collisionResponse
    overlaps:     u8; // True if the sprite was overlapping other when the collision started. False if it didn’t overlap but tunneled through other.
    ti:           float; // A number between 0 and 1 indicating how far along the movement to the goal the collision occurred
    move:         CollisionPoint; // The difference between the original coordinates and the actual ones when the collision happened
    normal:       CollisionVector; // The collision normal; usually -1, 0, or 1 in x and y. Use this value to determine things like if your character is touching the ground.
    touch:        CollisionPoint; // The coordinates where the sprite started touching other
    spriteRect:   PDRect; // The rectangle the sprite occupied when the touch happened
    otherRect:    PDRect; // The rectangle the sprite being collided with occupied when the touch happened
}

SpriteQueryInfo :: struct {
    sprite:     *LCDSprite; // The sprite being intersected by the segment

    ti1:        float; // entry point
    ti2:        float; // exit point
    entryPoint: CollisionPoint; // The coordinates of the first intersection between sprite and the line segment
    exitPoint:  CollisionPoint; // The coordinates of the second intersection between sprite and the line segment
}

CWCollisionInfo :: struct {}
CWItemInfo :: struct {}
LCDSpriteDrawFunction :: #type (sprite: *LCDSprite, bounds: PDRect, drawrect: PDRect) -> void #c_call;
LCDSpriteUpdateFunction :: #type (sprite: *LCDSprite) -> void #c_call;
LCDSpriteCollisionFilterProc :: #type (sprite: *LCDSprite, other: *LCDSprite) -> SpriteCollisionResponseType #c_call;

playdate_sprite :: struct {
    setAlwaysRedraw:              #type (flag: s32) -> void #c_call;
    addDirtyRect:                 #type (dirtyRect: LCDRect) -> void #c_call;
    drawSprites:                  #type () -> void #c_call;
    updateAndDrawSprites:         #type () -> void #c_call;

    newSprite:                    #type () -> *LCDSprite #c_call;
    freeSprite:                   #type (sprite: *LCDSprite) -> void #c_call;
    copy:                         #type (sprite: *LCDSprite) -> *LCDSprite #c_call;

    addSprite:                    #type (sprite: *LCDSprite) -> void #c_call;
    removeSprite:                 #type (sprite: *LCDSprite) -> void #c_call;
    removeSprites:                #type (sprites: **LCDSprite, count: s32) -> void #c_call;
    removeAllSprites:             #type () -> void #c_call;
    getSpriteCount:               #type () -> s32 #c_call;

    setBounds:                    #type (sprite: *LCDSprite, bounds: PDRect) -> void #c_call;
    getBounds:                    #type (sprite: *LCDSprite) -> PDRect #c_call;
    moveTo:                       #type (sprite: *LCDSprite, x: float, y: float) -> void #c_call;
    moveBy:                       #type (sprite: *LCDSprite, dx: float, dy: float) -> void #c_call;

    setImage:                     #type (sprite: *LCDSprite, image: *LCDBitmap, flip: LCDBitmapFlip) -> void #c_call;
    getImage:                     #type (sprite: *LCDSprite) -> *LCDBitmap #c_call;
    setSize:                      #type (s: *LCDSprite, width: float, height: float) -> void #c_call;
    setZIndex:                    #type (sprite: *LCDSprite, zIndex: s16) -> void #c_call;
    getZIndex:                    #type (sprite: *LCDSprite) -> s16 #c_call;

    setDrawMode:                  #type (sprite: *LCDSprite, mode: LCDBitmapDrawMode) -> void #c_call;
    setImageFlip:                 #type (sprite: *LCDSprite, flip: LCDBitmapFlip) -> void #c_call;
    getImageFlip:                 #type (sprite: *LCDSprite) -> LCDBitmapFlip #c_call;
    setStencil:                   #type (sprite: *LCDSprite, stencil: *LCDBitmap) -> void #c_call; // deprecated in favor of setStencilImage()

    setClipRect:                  #type (sprite: *LCDSprite, clipRect: LCDRect) -> void #c_call;
    clearClipRect:                #type (sprite: *LCDSprite) -> void #c_call;
    setClipRectsInRange:          #type (clipRect: LCDRect, startZ: s32, endZ: s32) -> void #c_call;
    clearClipRectsInRange:        #type (startZ: s32, endZ: s32) -> void #c_call;

    setUpdatesEnabled:            #type (sprite: *LCDSprite, flag: s32) -> void #c_call;
    updatesEnabled:               #type (sprite: *LCDSprite) -> s32 #c_call;
    setCollisionsEnabled:         #type (sprite: *LCDSprite, flag: s32) -> void #c_call;
    collisionsEnabled:            #type (sprite: *LCDSprite) -> s32 #c_call;
    setVisible:                   #type (sprite: *LCDSprite, flag: s32) -> void #c_call;
    isVisible:                    #type (sprite: *LCDSprite) -> s32 #c_call;
    setOpaque:                    #type (sprite: *LCDSprite, flag: s32) -> void #c_call;
    markDirty:                    #type (sprite: *LCDSprite) -> void #c_call;

    setTag:                       #type (sprite: *LCDSprite, tag: u8) -> void #c_call;
    getTag:                       #type (sprite: *LCDSprite) -> u8 #c_call;

    setIgnoresDrawOffset:         #type (sprite: *LCDSprite, flag: s32) -> void #c_call;

    setUpdateFunction:            #type (sprite: *LCDSprite, func: LCDSpriteUpdateFunction) -> void #c_call;
    setDrawFunction:              #type (sprite: *LCDSprite, func: LCDSpriteDrawFunction) -> void #c_call;

    getPosition:                  #type (sprite: *LCDSprite, x: *float, y: *float) -> void #c_call;

    // Collisions
    resetCollisionWorld:          #type () -> void #c_call;

    setCollideRect:               #type (sprite: *LCDSprite, collideRect: PDRect) -> void #c_call;
    getCollideRect:               #type (sprite: *LCDSprite) -> PDRect #c_call;
    clearCollideRect:             #type (sprite: *LCDSprite) -> void #c_call;

    // caller is responsible for freeing the returned array for all collision methods
    setCollisionResponseFunction: #type (sprite: *LCDSprite, func: LCDSpriteCollisionFilterProc) -> void #c_call;
    checkCollisions:              #type (sprite: *LCDSprite, goalX: float, goalY: float, actualX: *float, actualY: *float, len: *s32) -> *SpriteCollisionInfo #c_call; // access results using SpriteCollisionInfo *info = &results[i];
    moveWithCollisions:           #type (sprite: *LCDSprite, goalX: float, goalY: float, actualX: *float, actualY: *float, len: *s32) -> *SpriteCollisionInfo #c_call;
    querySpritesAtPoint:          #type (x: float, y: float, len: *s32) -> **LCDSprite #c_call;
    querySpritesInRect:           #type (x: float, y: float, width: float, height: float, len: *s32) -> **LCDSprite #c_call;
    querySpritesAlongLine:        #type (x1: float, y1: float, x2: float, y2: float, len: *s32) -> **LCDSprite #c_call;
    querySpriteInfoAlongLine:     #type (x1: float, y1: float, x2: float, y2: float, len: *s32) -> *SpriteQueryInfo #c_call; // access results using SpriteQueryInfo *info = &results[i];
    overlappingSprites:           #type (sprite: *LCDSprite, len: *s32) -> **LCDSprite #c_call;
    allOverlappingSprites:        #type (len: *s32) -> **LCDSprite #c_call;

    // added in 1.7
    setStencilPattern:            #type (sprite: *LCDSprite, pattern: *[8] u8) -> void #c_call;
    clearStencil:                 #type (sprite: *LCDSprite) -> void #c_call;

    setUserdata:                  #type (sprite: *LCDSprite, userdata: *void) -> void #c_call;
    getUserdata:                  #type (sprite: *LCDSprite) -> *void #c_call;

    // added in 1.10
    setStencilImage:              #type (sprite: *LCDSprite, stencil: *LCDBitmap, tile: s32) -> void #c_call;

    // 2.1
    setCenter:                    #type (s: *LCDSprite, x: float, y: float) -> void #c_call;
    getCenter:                    #type (s: *LCDSprite, x: *float, y: *float) -> void #c_call;
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
    setVolume:         #type (c: *SoundSource, lvol: float, rvol: float) -> void #c_call;
    getVolume:         #type (c: *SoundSource, outl: *float, outr: *float) -> void #c_call;
    isPlaying:         #type (c: *SoundSource) -> s32 #c_call;
    setFinishCallback: #type (c: *SoundSource, callback: sndCallbackProc, userdata: *void) -> void #c_call;
}

FilePlayer :: struct {}

playdate_sound_fileplayer :: struct {
    newPlayer:          #type () -> *FilePlayer #c_call;
    freePlayer:         #type (player: *FilePlayer) -> void #c_call;
    loadIntoPlayer:     #type (player: *FilePlayer, path: *u8) -> s32 #c_call;
    setBufferLength:    #type (player: *FilePlayer, bufferLen: float) -> void #c_call;
    play:               #type (player: *FilePlayer, repeat: s32) -> s32 #c_call;
    isPlaying:          #type (player: *FilePlayer) -> s32 #c_call;
    pause:              #type (player: *FilePlayer) -> void #c_call;
    stop:               #type (player: *FilePlayer) -> void #c_call;
    setVolume:          #type (player: *FilePlayer, left: float, right: float) -> void #c_call;
    getVolume:          #type (player: *FilePlayer, left: *float, right: *float) -> void #c_call;
    getLength:          #type (player: *FilePlayer) -> float #c_call;
    setOffset:          #type (player: *FilePlayer, offset: float) -> void #c_call;
    setRate:            #type (player: *FilePlayer, rate: float) -> void #c_call;
    setLoopRange:       #type (player: *FilePlayer, start: float, end: float) -> void #c_call;
    didUnderrun:        #type (player: *FilePlayer) -> s32 #c_call;
    setFinishCallback:  #type (player: *FilePlayer, callback: sndCallbackProc, userdata: *void) -> void #c_call;
    setLoopCallback:    #type (player: *FilePlayer, callback: sndCallbackProc, userdata: *void) -> void #c_call;
    getOffset:          #type (player: *FilePlayer) -> float #c_call;
    getRate:            #type (player: *FilePlayer) -> float #c_call;
    setStopOnUnderrun:  #type (player: *FilePlayer, flag: s32) -> void #c_call;
    fadeVolume:         #type (player: *FilePlayer, left: float, right: float, len: s32, finishCallback: sndCallbackProc, userdata: *void) -> void #c_call;
    setMP3StreamSource: #type (player: *FilePlayer, dataSource: #type (data: *u8, bytes: s32, userdata: *void) -> s32 #c_call, userdata: *void, bufferLen: float) -> void #c_call;
}

AudioSample :: struct {}
SamplePlayer :: struct {}

playdate_sound_sample :: struct {
    newSampleBuffer:   #type (byteCount: s32) -> *AudioSample #c_call;
    loadIntoSample:    #type (sample: *AudioSample, path: *u8) -> s32 #c_call;
    load:              #type (path: *u8) -> *AudioSample #c_call;
    newSampleFromData: #type (data: *u8, format: SoundFormat, sampleRate: u32, byteCount: s32, shouldFreeData: s32) -> *AudioSample #c_call;
    getData:           #type (sample: *AudioSample, data: **u8, format: *SoundFormat, sampleRate: *u32, bytelength: *u32) -> void #c_call;
    freeSample:        #type (sample: *AudioSample) -> void #c_call;
    getLength:         #type (sample: *AudioSample) -> float #c_call;

    // 2.4
    decompress:        #type (sample: *AudioSample) -> s32 #c_call;
}

playdate_sound_sampleplayer :: struct {
    newPlayer:         #type () -> *SamplePlayer #c_call;
    freePlayer:        #type (player: *SamplePlayer) -> void #c_call;
    setSample:         #type (player: *SamplePlayer, sample: *AudioSample) -> void #c_call;
    play:              #type (player: *SamplePlayer, repeat: s32, rate: float) -> s32 #c_call;
    isPlaying:         #type (player: *SamplePlayer) -> s32 #c_call;
    stop:              #type (player: *SamplePlayer) -> void #c_call;
    setVolume:         #type (player: *SamplePlayer, left: float, right: float) -> void #c_call;
    getVolume:         #type (player: *SamplePlayer, left: *float, right: *float) -> void #c_call;
    getLength:         #type (player: *SamplePlayer) -> float #c_call;
    setOffset:         #type (player: *SamplePlayer, offset: float) -> void #c_call;
    setRate:           #type (player: *SamplePlayer, rate: float) -> void #c_call;
    setPlayRange:      #type (player: *SamplePlayer, start: s32, end: s32) -> void #c_call;
    setFinishCallback: #type (player: *SamplePlayer, callback: sndCallbackProc, userdata: *void) -> void #c_call;
    setLoopCallback:   #type (player: *SamplePlayer, callback: sndCallbackProc, userdata: *void) -> void #c_call;
    getOffset:         #type (player: *SamplePlayer) -> float #c_call;
    getRate:           #type (player: *SamplePlayer) -> float #c_call;
    setPaused:         #type (player: *SamplePlayer, flag: s32) -> void #c_call;
}

PDSynthSignalValue :: struct {}
PDSynthSignal :: struct {}

signalStepFunc :: #type (userdata: *void, ioframes: *s32, ifval: *float) -> float #c_call;
signalNoteOnFunc :: #type (userdata: *void, note: MIDINote, vel: float, len: float) -> void #c_call;
signalNoteOffFunc :: #type (userdata: *void, stopped: s32, offset: s32) -> void #c_call;
signalDeallocFunc :: #type (userdata: *void) -> void #c_call;

playdate_sound_signal :: struct {
    newSignal:         #type (step: signalStepFunc, noteOn: signalNoteOnFunc, noteOff: signalNoteOffFunc, dealloc: signalDeallocFunc, userdata: *void) -> *PDSynthSignal #c_call;
    freeSignal:        #type (signal: *PDSynthSignal) -> void #c_call;
    getValue:          #type (signal: *PDSynthSignal) -> float #c_call;
    setValueScale:     #type (signal: *PDSynthSignal, scale: float) -> void #c_call;
    setValueOffset:    #type (signal: *PDSynthSignal, offset: float) -> void #c_call;

    // 2.6
    newSignalForValue: #type (value: *PDSynthSignalValue) -> *PDSynthSignal #c_call;
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
    newLFO:          #type (type: LFOType) -> *PDSynthLFO #c_call;
    freeLFO:         #type (lfo: *PDSynthLFO) -> void #c_call;

    setType:         #type (lfo: *PDSynthLFO, type: LFOType) -> void #c_call;
    setRate:         #type (lfo: *PDSynthLFO, rate: float) -> void #c_call;
    setPhase:        #type (lfo: *PDSynthLFO, phase: float) -> void #c_call;
    setCenter:       #type (lfo: *PDSynthLFO, center: float) -> void #c_call;
    setDepth:        #type (lfo: *PDSynthLFO, depth: float) -> void #c_call;
    setArpeggiation: #type (lfo: *PDSynthLFO, nSteps: s32, steps: *float) -> void #c_call;
    setFunction:     #type (lfo: *PDSynthLFO, lfoFunc: #type (lfo: *PDSynthLFO, userdata: *void) -> float #c_call, userdata: *void, interpolate: s32) -> void #c_call;
    setDelay:        #type (lfo: *PDSynthLFO, holdoff: float, ramptime: float) -> void #c_call;
    setRetrigger:    #type (lfo: *PDSynthLFO, flag: s32) -> void #c_call;

    getValue:        #type (lfo: *PDSynthLFO) -> float #c_call;

    // 1.10
    setGlobal:       #type (lfo: *PDSynthLFO, global: s32) -> void #c_call;

    // 2.2
    setStartPhase:   #type (lfo: *PDSynthLFO, phase: float) -> void #c_call;
}

PDSynthEnvelope :: struct {}

playdate_sound_envelope :: struct {
    newEnvelope:            #type (attack: float, decay: float, sustain: float, release: float) -> *PDSynthEnvelope #c_call;
    freeEnvelope:           #type (env: *PDSynthEnvelope) -> void #c_call;

    setAttack:              #type (env: *PDSynthEnvelope, attack: float) -> void #c_call;
    setDecay:               #type (env: *PDSynthEnvelope, decay: float) -> void #c_call;
    setSustain:             #type (env: *PDSynthEnvelope, sustain: float) -> void #c_call;
    setRelease:             #type (env: *PDSynthEnvelope, release: float) -> void #c_call;

    setLegato:              #type (env: *PDSynthEnvelope, flag: s32) -> void #c_call;
    setRetrigger:           #type (lfo: *PDSynthEnvelope, flag: s32) -> void #c_call;

    getValue:               #type (env: *PDSynthEnvelope) -> float #c_call;

    // 1.13
    setCurvature:           #type (env: *PDSynthEnvelope, amount: float) -> void #c_call;
    setVelocitySensitivity: #type (env: *PDSynthEnvelope, velsens: float) -> void #c_call;
    setRateScaling:         #type (env: *PDSynthEnvelope, scaling: float, start: MIDINote, end: MIDINote) -> void #c_call;
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
    newSynth:                #type () -> *PDSynth #c_call;
    freeSynth:               #type (synth: *PDSynth) -> void #c_call;

    setWaveform:             #type (synth: *PDSynth, wave: SoundWaveform) -> void #c_call;
    setGenerator_deprecated: #type (synth: *PDSynth, stereo: s32, render: synthRenderFunc, noteOn: synthNoteOnFunc, release: synthReleaseFunc, setparam: synthSetParameterFunc, dealloc: synthDeallocFunc, userdata: *void) -> void #c_call;
    setSample:               #type (synth: *PDSynth, sample: *AudioSample, sustainStart: u32, sustainEnd: u32) -> void #c_call;

    setAttackTime:           #type (synth: *PDSynth, attack: float) -> void #c_call;
    setDecayTime:            #type (synth: *PDSynth, decay: float) -> void #c_call;
    setSustainLevel:         #type (synth: *PDSynth, sustain: float) -> void #c_call;
    setReleaseTime:          #type (synth: *PDSynth, release: float) -> void #c_call;

    setTranspose:            #type (synth: *PDSynth, halfSteps: float) -> void #c_call;

    setFrequencyModulator:   #type (synth: *PDSynth, mod: *PDSynthSignalValue) -> void #c_call;
    getFrequencyModulator:   #type (synth: *PDSynth) -> *PDSynthSignalValue #c_call;
    setAmplitudeModulator:   #type (synth: *PDSynth, mod: *PDSynthSignalValue) -> void #c_call;
    getAmplitudeModulator:   #type (synth: *PDSynth) -> *PDSynthSignalValue #c_call;

    getParameterCount:       #type (synth: *PDSynth) -> s32 #c_call;
    setParameter:            #type (synth: *PDSynth, parameter: s32, value: float) -> s32 #c_call;
    setParameterModulator:   #type (synth: *PDSynth, parameter: s32, mod: *PDSynthSignalValue) -> void #c_call;
    getParameterModulator:   #type (synth: *PDSynth, parameter: s32) -> *PDSynthSignalValue #c_call;

    playNote:                #type (synth: *PDSynth, freq: float, vel: float, len: float, when: u32) -> void #c_call; // len == -1 for indefinite
    playMIDINote:            #type (synth: *PDSynth, note: MIDINote, vel: float, len: float, when: u32) -> void #c_call; // len == -1 for indefinite
    noteOff:                 #type (synth: *PDSynth, when: u32) -> void #c_call; // move to release part of envelope
    stop:                    #type (synth: *PDSynth) -> void #c_call; // stop immediately

    setVolume:               #type (synth: *PDSynth, left: float, right: float) -> void #c_call;
    getVolume:               #type (synth: *PDSynth, left: *float, right: *float) -> void #c_call;

    isPlaying:               #type (synth: *PDSynth) -> s32 #c_call;

    getEnvelope:             #type (synth: *PDSynth) -> *PDSynthEnvelope #c_call; // synth keeps ownership--don't free this!

    // 2.2
    setWavetable:            #type (synth: *PDSynth, sample: *AudioSample, log2size: s32, columns: s32, rows: s32) -> s32 #c_call;

    // 2.4
    setGenerator:            #type (synth: *PDSynth, stereo: s32, render: synthRenderFunc, noteOn: synthNoteOnFunc, release: synthReleaseFunc, setparam: synthSetParameterFunc, dealloc: synthDeallocFunc, copyUserdata: synthCopyUserdata, userdata: *void) -> void #c_call;
    copy:                    #type (synth: *PDSynth) -> *PDSynth #c_call;

    // 2.6
    clearEnvelope:           #type (synth: *PDSynth) -> void #c_call;
}

ControlSignal :: struct {}

playdate_control_signal :: struct {
    newSignal:               #type () -> *ControlSignal #c_call;
    freeSignal:              #type (signal: *ControlSignal) -> void #c_call;
    clearEvents:             #type (control: *ControlSignal) -> void #c_call;
    addEvent:                #type (control: *ControlSignal, step: s32, value: float, interpolate: s32) -> void #c_call;
    removeEvent:             #type (control: *ControlSignal, step: s32) -> void #c_call;
    getMIDIControllerNumber: #type (control: *ControlSignal) -> s32 #c_call;
}

PDSynthInstrument :: struct {}

playdate_sound_instrument :: struct {
    newInstrument:     #type () -> *PDSynthInstrument #c_call;
    freeInstrument:    #type (inst: *PDSynthInstrument) -> void #c_call;
    addVoice:          #type (inst: *PDSynthInstrument, synth: *PDSynth, rangeStart: MIDINote, rangeEnd: MIDINote, transpose: float) -> s32 #c_call;
    playNote:          #type (inst: *PDSynthInstrument, frequency: float, vel: float, len: float, when: u32) -> *PDSynth #c_call;
    playMIDINote:      #type (inst: *PDSynthInstrument, note: MIDINote, vel: float, len: float, when: u32) -> *PDSynth #c_call;
    setPitchBend:      #type (inst: *PDSynthInstrument, bend: float) -> void #c_call;
    setPitchBendRange: #type (inst: *PDSynthInstrument, halfSteps: float) -> void #c_call;
    setTranspose:      #type (inst: *PDSynthInstrument, halfSteps: float) -> void #c_call;
    noteOff:           #type (inst: *PDSynthInstrument, note: MIDINote, when: u32) -> void #c_call;
    allNotesOff:       #type (inst: *PDSynthInstrument, when: u32) -> void #c_call;
    setVolume:         #type (inst: *PDSynthInstrument, left: float, right: float) -> void #c_call;
    getVolume:         #type (inst: *PDSynthInstrument, left: *float, right: *float) -> void #c_call;
    activeVoiceCount:  #type (inst: *PDSynthInstrument) -> s32 #c_call;
}

SequenceTrack :: struct {}

playdate_sound_track :: struct {
    newTrack:               #type () -> *SequenceTrack #c_call;
    freeTrack:              #type (track: *SequenceTrack) -> void #c_call;

    setInstrument:          #type (track: *SequenceTrack, inst: *PDSynthInstrument) -> void #c_call;
    getInstrument:          #type (track: *SequenceTrack) -> *PDSynthInstrument #c_call;

    addNoteEvent:           #type (track: *SequenceTrack, step: u32, len: u32, note: MIDINote, velocity: float) -> void #c_call;
    removeNoteEvent:        #type (track: *SequenceTrack, step: u32, note: MIDINote) -> void #c_call;
    clearNotes:             #type (track: *SequenceTrack) -> void #c_call;

    getControlSignalCount:  #type (track: *SequenceTrack) -> s32 #c_call;
    getControlSignal:       #type (track: *SequenceTrack, idx: s32) -> *ControlSignal #c_call;
    clearControlEvents:     #type (track: *SequenceTrack) -> void #c_call;

    getPolyphony:           #type (track: *SequenceTrack) -> s32 #c_call;
    activeVoiceCount:       #type (track: *SequenceTrack) -> s32 #c_call;

    setMuted:               #type (track: *SequenceTrack, mute: s32) -> void #c_call;

    getLength:              #type (track: *SequenceTrack) -> u32 #c_call; // in steps, includes full last note
    getIndexForStep:        #type (track: *SequenceTrack, step: u32) -> s32 #c_call;
    getNoteAtIndex:         #type (track: *SequenceTrack, index: s32, outStep: *u32, outLen: *u32, outNote: *MIDINote, outVelocity: *float) -> s32 #c_call;

    // 1.10
    getSignalForController: #type (track: *SequenceTrack, controller: s32, create: s32) -> *ControlSignal #c_call;
}

SoundSequence :: struct {}
SequenceFinishedCallback :: #type (seq: *SoundSequence, userdata: *void) -> void #c_call;

playdate_sound_sequence :: struct {
    newSequence:         #type () -> *SoundSequence #c_call;
    freeSequence:        #type (sequence: *SoundSequence) -> void #c_call;

    loadMIDIFile:        #type (seq: *SoundSequence, path: *u8) -> s32 #c_call;
    getTime:             #type (seq: *SoundSequence) -> u32 #c_call;
    setTime:             #type (seq: *SoundSequence, time: u32) -> void #c_call;
    setLoops:            #type (seq: *SoundSequence, loopstart: s32, loopend: s32, loops: s32) -> void #c_call;
    getTempo_deprecated: #type (seq: *SoundSequence) -> s32 #c_call;
    setTempo:            #type (seq: *SoundSequence, stepsPerSecond: float) -> void #c_call;
    getTrackCount:       #type (seq: *SoundSequence) -> s32 #c_call;
    addTrack:            #type (seq: *SoundSequence) -> *SequenceTrack #c_call;
    getTrackAtIndex:     #type (seq: *SoundSequence, track: u32) -> *SequenceTrack #c_call;
    setTrackAtIndex:     #type (seq: *SoundSequence, track: *SequenceTrack, idx: u32) -> void #c_call;
    allNotesOff:         #type (seq: *SoundSequence) -> void #c_call;

    // 1.1
    isPlaying:           #type (seq: *SoundSequence) -> s32 #c_call;
    getLength:           #type (seq: *SoundSequence) -> u32 #c_call; // in steps, includes full last note
    play:                #type (seq: *SoundSequence, finishCallback: SequenceFinishedCallback, userdata: *void) -> void #c_call;
    stop:                #type (seq: *SoundSequence) -> void #c_call;
    getCurrentStep:      #type (seq: *SoundSequence, timeOffset: *s32) -> s32 #c_call;
    setCurrentStep:      #type (seq: *SoundSequence, step: s32, timeOffset: s32, playNotes: s32) -> void #c_call;

    // 2.5
    getTempo:            #type (seq: *SoundSequence) -> float #c_call;
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
    newFilter:             #type () -> *TwoPoleFilter #c_call;
    freeFilter:            #type (filter: *TwoPoleFilter) -> void #c_call;
    setType:               #type (filter: *TwoPoleFilter, type: TwoPoleFilterType) -> void #c_call;
    setFrequency:          #type (filter: *TwoPoleFilter, frequency: float) -> void #c_call;
    setFrequencyModulator: #type (filter: *TwoPoleFilter, signal: *PDSynthSignalValue) -> void #c_call;
    getFrequencyModulator: #type (filter: *TwoPoleFilter) -> *PDSynthSignalValue #c_call;
    setGain:               #type (filter: *TwoPoleFilter, gain: float) -> void #c_call;
    setResonance:          #type (filter: *TwoPoleFilter, resonance: float) -> void #c_call;
    setResonanceModulator: #type (filter: *TwoPoleFilter, signal: *PDSynthSignalValue) -> void #c_call;
    getResonanceModulator: #type (filter: *TwoPoleFilter) -> *PDSynthSignalValue #c_call;
}

OnePoleFilter :: struct {}

playdate_sound_effect_onepolefilter :: struct {
    newFilter:             #type () -> *OnePoleFilter #c_call;
    freeFilter:            #type (filter: *OnePoleFilter) -> void #c_call;
    setParameter:          #type (filter: *OnePoleFilter, parameter: float) -> void #c_call;
    setParameterModulator: #type (filter: *OnePoleFilter, signal: *PDSynthSignalValue) -> void #c_call;
    getParameterModulator: #type (filter: *OnePoleFilter) -> *PDSynthSignalValue #c_call;
}

BitCrusher :: struct {}

playdate_sound_effect_bitcrusher :: struct {
    newBitCrusher:           #type () -> *BitCrusher #c_call;
    freeBitCrusher:          #type (filter: *BitCrusher) -> void #c_call;
    setAmount:               #type (filter: *BitCrusher, amount: float) -> void #c_call;
    setAmountModulator:      #type (filter: *BitCrusher, signal: *PDSynthSignalValue) -> void #c_call;
    getAmountModulator:      #type (filter: *BitCrusher) -> *PDSynthSignalValue #c_call;
    setUndersampling:        #type (filter: *BitCrusher, undersampling: float) -> void #c_call;
    setUndersampleModulator: #type (filter: *BitCrusher, signal: *PDSynthSignalValue) -> void #c_call;
    getUndersampleModulator: #type (filter: *BitCrusher) -> *PDSynthSignalValue #c_call;
}

RingModulator :: struct {}

playdate_sound_effect_ringmodulator :: struct {
    newRingmod:            #type () -> *RingModulator #c_call;
    freeRingmod:           #type (filter: *RingModulator) -> void #c_call;
    setFrequency:          #type (filter: *RingModulator, frequency: float) -> void #c_call;
    setFrequencyModulator: #type (filter: *RingModulator, signal: *PDSynthSignalValue) -> void #c_call;
    getFrequencyModulator: #type (filter: *RingModulator) -> *PDSynthSignalValue #c_call;
}

DelayLine :: struct {}
DelayLineTap :: struct {}

playdate_sound_effect_delayline :: struct {
    newDelayLine:          #type (length: s32, stereo: s32) -> *DelayLine #c_call;
    freeDelayLine:         #type (filter: *DelayLine) -> void #c_call;
    setLength:             #type (d: *DelayLine, frames: s32) -> void #c_call;
    setFeedback:           #type (d: *DelayLine, fb: float) -> void #c_call;
    addTap:                #type (d: *DelayLine, delay: s32) -> *DelayLineTap #c_call;

    // note that DelayLineTap is a SoundSource, not a SoundEffect
    freeTap:               #type (tap: *DelayLineTap) -> void #c_call;
    setTapDelay:           #type (t: *DelayLineTap, frames: s32) -> void #c_call;
    setTapDelayModulator:  #type (t: *DelayLineTap, mod: *PDSynthSignalValue) -> void #c_call;
    getTapDelayModulator:  #type (t: *DelayLineTap) -> *PDSynthSignalValue #c_call;
    setTapChannelsFlipped: #type (t: *DelayLineTap, flip: s32) -> void #c_call;
}

Overdrive :: struct {}

playdate_sound_effect_overdrive :: struct {
    newOverdrive:       #type () -> *Overdrive #c_call;
    freeOverdrive:      #type (filter: *Overdrive) -> void #c_call;
    setGain:            #type (o: *Overdrive, gain: float) -> void #c_call;
    setLimit:           #type (o: *Overdrive, limit: float) -> void #c_call;
    setLimitModulator:  #type (o: *Overdrive, mod: *PDSynthSignalValue) -> void #c_call;
    getLimitModulator:  #type (o: *Overdrive) -> *PDSynthSignalValue #c_call;
    setOffset:          #type (o: *Overdrive, offset: float) -> void #c_call;
    setOffsetModulator: #type (o: *Overdrive, mod: *PDSynthSignalValue) -> void #c_call;
    getOffsetModulator: #type (o: *Overdrive) -> *PDSynthSignalValue #c_call;
}

SoundEffect :: struct {}
effectProc :: #type (e: *SoundEffect, left: *s32, right: *s32, nsamples: s32, bufactive: s32) -> s32 #c_call;

playdate_sound_effect :: struct {
    newEffect:       #type (proc: effectProc, userdata: *void) -> *SoundEffect #c_call;
    freeEffect:      #type (effect: *SoundEffect) -> void #c_call;

    setMix:          #type (effect: *SoundEffect, level: float) -> void #c_call;
    setMixModulator: #type (effect: *SoundEffect, signal: *PDSynthSignalValue) -> void #c_call;
    getMixModulator: #type (effect: *SoundEffect) -> *PDSynthSignalValue #c_call;

    setUserdata:     #type (effect: *SoundEffect, userdata: *void) -> void #c_call;
    getUserdata:     #type (effect: *SoundEffect) -> *void #c_call;

    twopolefilter:   *playdate_sound_effect_twopolefilter;
    onepolefilter:   *playdate_sound_effect_onepolefilter;
    bitcrusher:      *playdate_sound_effect_bitcrusher;
    ringmodulator:   *playdate_sound_effect_ringmodulator;
    delayline:       *playdate_sound_effect_delayline;
    overdrive:       *playdate_sound_effect_overdrive;
}

SoundChannel :: struct {}

AudioSourceFunction :: #type (_context: *void, left: *s16, right: *s16, len: s32) -> s32 #c_call;

playdate_sound_channel :: struct {
    newChannel:         #type () -> *SoundChannel #c_call;
    freeChannel:        #type (channel: *SoundChannel) -> void #c_call;
    addSource:          #type (channel: *SoundChannel, source: *SoundSource) -> s32 #c_call;
    removeSource:       #type (channel: *SoundChannel, source: *SoundSource) -> s32 #c_call;
    addCallbackSource:  #type (channel: *SoundChannel, callback: AudioSourceFunction, _context: *void, stereo: s32) -> *SoundSource #c_call;
    addEffect:          #type (channel: *SoundChannel, effect: *SoundEffect) -> void #c_call;
    removeEffect:       #type (channel: *SoundChannel, effect: *SoundEffect) -> void #c_call;
    setVolume:          #type (channel: *SoundChannel, volume: float) -> void #c_call;
    getVolume:          #type (channel: *SoundChannel) -> float #c_call;
    setVolumeModulator: #type (channel: *SoundChannel, mod: *PDSynthSignalValue) -> void #c_call;
    getVolumeModulator: #type (channel: *SoundChannel) -> *PDSynthSignalValue #c_call;
    setPan:             #type (channel: *SoundChannel, pan: float) -> void #c_call;
    setPanModulator:    #type (channel: *SoundChannel, mod: *PDSynthSignalValue) -> void #c_call;
    getPanModulator:    #type (channel: *SoundChannel) -> *PDSynthSignalValue #c_call;
    getDryLevelSignal:  #type (channel: *SoundChannel) -> *PDSynthSignalValue #c_call;
    getWetLevelSignal:  #type (channel: *SoundChannel) -> *PDSynthSignalValue #c_call;
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
    channel:           *playdate_sound_channel;
    fileplayer:        *playdate_sound_fileplayer;
    sample:            *playdate_sound_sample;
    sampleplayer:      *playdate_sound_sampleplayer;
    synth:             *playdate_sound_synth;
    sequence:          *playdate_sound_sequence;
    effect:            *playdate_sound_effect;
    lfo:               *playdate_sound_lfo;
    envelope:          *playdate_sound_envelope;
    source:            *playdate_sound_source;
    controlsignal:     *playdate_control_signal;
    track:             *playdate_sound_track;
    instrument:        *playdate_sound_instrument;

    getCurrentTime:    #type () -> u32 #c_call;
    addSource:         #type (callback: AudioSourceFunction, _context: *void, stereo: s32) -> *SoundSource #c_call;

    getDefaultChannel: #type () -> *SoundChannel #c_call;

    addChannel:        #type (channel: *SoundChannel) -> s32 #c_call;
    removeChannel:     #type (channel: *SoundChannel) -> s32 #c_call;

    setMicCallback:    #type (callback: RecordCallback, _context: *void, source: MicSource) -> s32 #c_call;
    getHeadphoneState: #type (headphone: *s32, headsetmic: *s32, changeCallback: #type (headphone: s32, mic: s32) -> void #c_call) -> void #c_call;
    setOutputsActive:  #type (headphone: s32, speaker: s32) -> void #c_call;

    // 1.5
    removeSource:      #type (source: *SoundSource) -> s32 #c_call;

    // 1.12
    signal:            *playdate_sound_signal;

    // 2.2
    getError:          #type () -> *u8 #c_call;
}

playdate_display :: struct {
    getWidth:       #type () -> s32 #c_call;
    getHeight:      #type () -> s32 #c_call;

    setRefreshRate: #type (rate: float) -> void #c_call;

    setInverted:    #type (flag: s32) -> void #c_call;
    setScale:       #type (s: u32) -> void #c_call;
    setMosaic:      #type (x: u32, y: u32) -> void #c_call;
    setFlipped:     #type (x: s32, y: s32) -> void #c_call;
    setOffset:      #type (x: s32, y: s32) -> void #c_call;
}

PDScore :: struct {
    rank:   u32;
    value:  u32;
    player: *u8;
}

PDScoresList :: struct {
    boardID:        *u8;
    count:          u32;
    lastUpdated:    u32;
    playerIncluded: s32;
    limit:          u32;
    scores:         *PDScore;
}

PDBoard :: struct {
    boardID: *u8;
    name:    *u8;
}

PDBoardsList :: struct {
    count:       u32;
    lastUpdated: u32;
    boards:      *PDBoard;
}

AddScoreCallback :: #type (score: *PDScore, errorMessage: *u8) -> void #c_call;
PersonalBestCallback :: #type (score: *PDScore, errorMessage: *u8) -> void #c_call;
BoardsListCallback :: #type (boards: *PDBoardsList, errorMessage: *u8) -> void #c_call;
ScoresCallback :: #type (scores: *PDScoresList, errorMessage: *u8) -> void #c_call;

playdate_scoreboards :: struct {
    addScore:        #type (boardId: *u8, value: u32, callback: AddScoreCallback) -> s32 #c_call;
    getPersonalBest: #type (boardId: *u8, callback: PersonalBestCallback) -> s32 #c_call;
    freeScore:       #type (score: *PDScore) -> void #c_call;

    getScoreboards:  #type (callback: BoardsListCallback) -> s32 #c_call;
    freeBoardsList:  #type (boardsList: *PDBoardsList) -> void #c_call;

    getScores:       #type (boardId: *u8, callback: ScoresCallback) -> s32 #c_call;
    freeScoresList:  #type (scoresList: *PDScoresList) -> void #c_call;
}

PlaydateAPI :: struct {
    system:      *playdate_sys;
    file:        *playdate_file;
    graphics:    *playdate_graphics;
    sprite:      *playdate_sprite;
    display:     *playdate_display;
    sound:       *playdate_sound;
    lua:         *playdate_lua;
    json:        *playdate_json;
    scoreboards: *playdate_scoreboards;
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


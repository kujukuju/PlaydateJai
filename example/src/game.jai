
#import "PlaydateJai";


// pd: *PlaydateAPI;

// update :: () -> s32 {
//     pd.graphics.clear(cast(u64) LCDSolidColor.kColorBlack);

//     // Draw a white rectangle in the middle of the screen
//     pd.graphics.fillRect(150, 110, 100, 40, cast(u64) LCDSolidColor.kColorWhite);

//     return 1;
// }

update :: (userdata: *void) -> s32 #c_call {
    pd := cast(*PlaydateAPI) userdata;

    // x: s32 = cast(s32) *((cast(*playdate_graphics) pd.graphics).__clear) - cast(s32) (cast(*playdate_graphics) pd.graphics);
    // y: s32 = cast(s32) *((cast(*playdate_graphics) pd.graphics).clear) - cast(s32) (cast(*playdate_graphics) pd.graphics);

    // (cast(#type (color: LCDColor) -> void #c_call) (cast(*playdate_graphics) pd.graphics).__clear)(cast(u64) LCDSolidColor.kColorBlack);
    // (cast(#type (x: s32, y: s32, width: s32, height: s32, color: LCDColor) -> void #c_call) (cast(*playdate_graphics) pd.graphics).__fillRect)(x, y, 100, 40, cast(u64) LCDSolidColor.kColorWhite);

    pd.graphics.clear(cast(u64) LCDSolidColor.kColorBlack);

    // // Draw a white rectangle in the middle of the screen
    pd.graphics.fillRect(150, 110, 100, 80, cast(u64) LCDSolidColor.kColorWhite);

    return 1;
    // ctx := cast(*Context) userdata;
    // push_context ctx.* {
    //     update();
    // }
    // return 1;
}

// somehow this works with the simulator I don't understand why though
#program_export
eventHandler :: (playdate: u32, event: PDSystemEvent, arg: u32) -> s32 #c_call {
    if event == .kEventInit {
        pd := cast(*PlaydateAPI) playdate;

        // #if OS == .WINDOWS {
        //     #import "Basic";
        //     empty: Context;
        //     push_context empty {
        //         thing: playdate_sys;
        //         pd.system.logToConsole(tprint("type of playdate is %\0", type_of(playdate)).data);
        //         pd.system.logToConsole(tprint("size of playdate is %\0", size_of(type_of(playdate))).data);
        //         pd.system.logToConsole(tprint("% - % should be 12\0", cast,no_check(u64) *thing.error, cast,no_check(u64) *thing.realloc).data);
        //         print("% - % should be 12\n", *thing.error, *thing.realloc);
        //     }
        // }

        // (cast(#type (update: #type (userdata: u32) -> s32, userdata: u32) -> void #c_call) pd.system.setUpdateCallback)(xx update, playdate);

        pd.system.setUpdateCallback(update, xx pd);
    }

    return 0;
}


#import "PlaydateJai";

// pd: *PlaydateAPI;

// update :: () -> s32 {
//     pd.graphics.clear(cast(u64) LCDSolidColor.kColorBlack);

//     // Draw a white rectangle in the middle of the screen
//     pd.graphics.fillRect(150, 110, 100, 40, cast(u64) LCDSolidColor.kColorWhite);

//     return 1;
// }

update :: (userdata: u32) -> s32 #c_call {
    pd := cast(*PlaydateAPI) userdata;

    (cast(#type (color: LCDColor) -> void #c_call) (cast(*playdate_graphics) pd.graphics).clear)(cast(u64) LCDSolidColor.kColorBlack);

    // Draw a white rectangle in the middle of the screen
    (cast(#type (x: s32, y: s32, width: s32, height: s32, color: LCDColor) -> void #c_call) (cast(*playdate_graphics) pd.graphics).fillRect)(150, 110, 100, 40, cast(u64) LCDSolidColor.kColorWhite);

    return 1;
    // ctx := cast(*Context) userdata;
    // push_context ctx.* {
    //     update();
    // }
    // return 1;
}

#program_export
eventHandler :: (playdate: u32, event: PDSystemEvent, arg: u32) -> s32 #c_call {
    if event == .kEventInit {
        pd := cast(*PlaydateAPI) playdate;

        (cast(#type (update: PDCallbackFunction, userdata: u32) -> void #c_call) (cast(*playdate_sys) pd.system).setUpdateCallback)(update, playdate);
    }

    return 0;
}

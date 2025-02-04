
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

    pd.graphics.clear(cast(u64) LCDSolidColor.kColorBlack);

    // Draw a white rectangle in the middle of the screen
    pd.graphics.fillRect(150, 110, 100, 40, cast(u64) LCDSolidColor.kColorWhite);

    return 1;
    // ctx := cast(*Context) userdata;
    // push_context ctx.* {
    //     update();
    // }
    // return 1;
}

#program_export
eventHandler :: (playdate: *PlaydateAPI, event: PDSystemEvent, arg: u32) -> s32 #c_call {
    if event == .kEventInit {
        pd := cast(*PlaydateAPI) playdate;

        pd.system.setUpdateCallback(update, pd);
    }

    return 0;
}

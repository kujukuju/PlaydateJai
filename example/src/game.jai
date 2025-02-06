
#import "PlaydateJai";

// #import "Basic";

background: *LCDBitmap;
// island: *LCDBitmap;

update :: (userdata: *void) -> s32 {
    pd := cast(*PlaydateAPI) userdata;

    pd.graphics.clear(cast(u32) LCDSolidColor.kColorBlack);
    pd.graphics.drawBitmap(background, 0, 0, .Unflipped);
    // pd.graphics.drawBitmap(island, 0, 0, .Unflipped);

    return 1;
}

#program_export
eventHandler :: (pd: *PlaydateAPI, event: PDSystemEvent, arg: u32) -> s32 #c_call {
    if event == {
        case .kEventInit;
            init();
            playdate_setup(pd);

            // background_path := u8.[#char "b", #char "g", #char ".", #char "p", #char "d", #char "i", #char "\0"];
            // island_path := u8.[#char "i", #char "s", #char "l", #char "a", #char "n", #char "d", #char ".", #char "p", #char "d", #char "i", #char "\0"];
            scene_path := u8.[#char "s", #char "c", #char "e", #char "n", #char "e", #char "_", #char "d", #char "i", #char "t", #char "h", #char "e", #char "r", #char "e", #char "d", #char ".", #char "p", #char "d", #char "i", #char "\0"] #align 4;

            err: *u8;
            background = pd.graphics.loadBitmap(scene_path.data, *err);
            // island = pd.graphics.loadBitmap(island_path.data, *err);

            pd.system.setUpdateCallback((userdata: *void) -> s32 #c_call {
                // empty: Context;
                // push_context empty {
                //     return update(userdata);
                // }
                push_context pd_context {
                    return update(userdata);
                }
            }, pd);
    }

    return 0;
}

init :: () #c_call {
    // data = null;
}

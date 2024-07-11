//بسم الله الرحمن الرحيم
//la ilaha illa Allah Mohammed Rassoul Allah
const std = @import("std");
const sf = struct {
    const sfml = @import("sfml");
    usingnamespace sfml;
    usingnamespace sfml.audio;
    usingnamespace sfml.graphics;
    usingnamespace sfml.window;
    usingnamespace sfml.system;
};

const NUMBER_OF_PAGES = 604;
const IMAGE_WIDTH = 1792;
const IMAGE_HEIGHT = 2560;

// var flag_zoomed_in: bool = false;

fn embed_quran_pictures() [NUMBER_OF_PAGES][]const u8 {
    var quran_pictures: [NUMBER_OF_PAGES][]const u8 = undefined;

    var i: usize = 0;
    while (i < NUMBER_OF_PAGES) : (i += 1) {
        var file_name_buffer: [64]u8 = undefined;
        const file_name_slice = std.fmt.bufPrint(&file_name_buffer, "res/{d}-scaled.jpg", .{i + 1}) catch |e| {
            // std.log.err("alhamdo li Allah error while writing to 'file_name_buffer': {any}\n", .{e});
            @compileLog("alhamdo li Allah error ", e, " while writing to 'file_name_buffer' ", i);
            @compileError("error while writing file name to buffer\n");
        };

        const file = @embedFile(file_name_slice);
        quran_pictures[i] = file;
    }

    return quran_pictures;
}

const quran_pictures_arr = embed_quran_pictures();
var current_page: usize = 0;

/// sets the page diplayed starting from 1
fn setPage(sprite: *sf.Sprite, target_page: usize) !void {
    if (current_page == target_page or target_page > NUMBER_OF_PAGES or 0 == target_page) return;

    sprite.setTexture(try sf.Texture.createFromMemory(quran_pictures_arr[target_page - 1], .{ .top = 0, .left = 0, .width = 0, .height = 0 }));

    // sprite.setTextureRect(sf.IntRect.init(393, 170, 1360, 2184));
    // sprite.setTextureRect(sf.IntRect.init(196, 85, 680, 1542));

    current_page = target_page;
}

pub fn main() !void {
    // notes:
    // image size: 1792x2560
    var window = try sf.RenderWindow.create(.{ .x = IMAGE_WIDTH / 2, .y = IMAGE_HEIGHT / 2 }, 16, "quran warsh - tajweed", sf.Style.defaultStyle, null);
    defer window.destroy();

    window.setFramerateLimit(30);

    window.setSize(.{ .x = IMAGE_WIDTH / 2, .y = IMAGE_HEIGHT / 2 });

    var quran_sprite = try sf.Sprite.create();
    defer quran_sprite.destroy();
    quran_sprite.setScale(.{ .x = 0.5, .y = 0.5 });

    try setPage(&quran_sprite, 1);

    var app_running: bool = true;
    while (window.isOpen() and app_running) {
        while (waitEvent(&window)) |event| {
            switch (event) {
                .closed => {
                    window.close();
                    app_running = false;
                    break;
                },
                .key_pressed => {
                    if (event.key_pressed.code == .left and current_page < NUMBER_OF_PAGES) {
                        try setPage(&quran_sprite, current_page + 1);
                    } else if (event.key_pressed.code == .right and current_page != 0) {
                        try setPage(&quran_sprite, current_page - 1);
                    }

                    // if (event.key_pressed.code == .I) {
                    //     flag_zoomed_in = !flag_zoomed_in;
                    // }
                },
                else => {},
            }

            window.clear(sf.Color.Black);
            defer window.display();

            //drawnig by the will of Allah
            window.draw(quran_sprite, null);
        }
    }
}

fn waitEvent(self: *sf.RenderWindow) ?sf.window.Event {
    var event: sf.c.sfEvent = undefined;
    if (sf.c.sfRenderWindow_waitEvent(self._ptr, &event) != 0) {
        return sf.window.Event._fromCSFML(event);
    } else return null;
}

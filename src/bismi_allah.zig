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

const NUMBER_OF_PAGES: comptime_int = 604;

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

pub fn main() !void {
    var window = try sf.RenderWindow.create(.{ .x = 1000, .y = 1000 }, 32, "مصحف التجويد لورش", sf.Style.defaultStyle, null);
    defer window.destroy();
    window.setSize(.{ .x = 200, .y = 200 });

    var quran_texture = try sf.Texture.createFromMemory(quran_pictures_arr[0], .{ .top = 0, .left = 0, .width = 0, .height = 0 });
    defer quran_texture.destroy();
    quran_texture.setSmooth(true);

    var quran_sprite = try sf.Sprite.createFromTexture(quran_texture);
    defer quran_sprite.destroy();
    quran_sprite.setScale(.{ .x = 0.5, .y = 0.5 });

    while (window.isOpen()) {
        while (window.pollEvent()) |event| switch (event) {
            .closed => window.close(),
            else => {
                std.debug.print("alhamdo li Allah event {any}\n", .{event});
            },
        };

        window.clear(sf.Color.Black);
        defer window.display();

        //drawnig by the will of Allah
        window.draw(quran_sprite, null);
    }
}

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

    const cwd = std.fs.cwd();
    defer cwd.close();

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
}

const quran_pictures_arr = embed_quran_pictures();

pub fn main() !void {
    var window = try sf.RenderWindow.create(.{ .x = 600, .y = 900 }, 32, "مصحف التجويد لورش", sf.Style.defaultStyle, null);
    defer window.destroy();
    std.debug.print("alhamdo li Allah {d}\n", .{NUMBER_OF_PAGES});

    quran_pictures_arr[3][2] = 1;
}

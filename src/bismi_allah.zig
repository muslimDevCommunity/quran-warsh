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

const Settings = struct {
    bookmarks: [10]usize,
    current_page: usize,
};

const page_navigator = @import("page_navigator.zig");
const ui = @import("ui.zig");

pub const IMAGE_WIDTH = 1792;
pub const IMAGE_HEIGHT = 2560;

// var flag_zoomed_in: bool = false;

var fixed_buffer: [1024]u8 = undefined;
pub var app_data_dir_path: []u8 = undefined;

var fba: std.heap.FixedBufferAllocator = undefined;
var allocator: std.mem.Allocator = undefined;

pub fn main() !void {
    // notes:
    // image size: 1792x2560
    fba = std.heap.FixedBufferAllocator.init(&fixed_buffer);
    allocator = fba.allocator();

    loadData() catch |e| {
        std.debug.print("alhamdo li Allah err: {any}\n", .{e});
    };

    get_self_exe_dir_path: {
        const dir_path = std.fs.selfExeDirPathAlloc(allocator) catch |e| {
            std.log.err("alhamdo li Allah error while getting 'selfExeDirPathAlloc': {any}\n", .{e});
            break :get_self_exe_dir_path;
        };
        defer allocator.free(dir_path);
        const res_path = std.mem.concat(allocator, u8, &[_][]u8{ dir_path, @constCast("/res") }) catch |e| {
            std.log.err("alhamdo li Allah error while concating 'self_dir' and 'res': {any}\n", .{e});
            break :get_self_exe_dir_path;
        };
        page_navigator.possible_quran_dir_paths_buffers[2] = res_path;
    }
    defer allocator.free(page_navigator.possible_quran_dir_paths_buffers[2]);

    ui.font = try sf.Font.createFromMemory(ui.font_data);
    defer ui.font.destroy();

    var window = try sf.RenderWindow.create(.{ .x = IMAGE_WIDTH, .y = IMAGE_HEIGHT }, 64, "quran warsh - tajweed quran", sf.Style.defaultStyle, null);
    defer window.destroy();

    window.setFramerateLimit(30);

    window.setSize(.{ .x = IMAGE_WIDTH / 2, .y = IMAGE_HEIGHT / 2 });

    var quran_sprite = try sf.Sprite.create();
    defer quran_sprite.destroy();
    // quran_sprite.setScale(.{ .x = 0.5, .y = 0.5 });

    page_navigator.goToPage(&quran_sprite, page_navigator.current_page);

    while (window.waitEvent()) |event| {
        switch (event) {
            .closed => {
                window.close();
                break;
            },
            .key_pressed => {
                if (event.key_pressed.shift) {
                    switch (event.key_pressed.code) {
                        .left => page_navigator.goToNextSurah(&quran_sprite),
                        .right => page_navigator.goToPreviousSurah(&quran_sprite),
                        .num0 => page_navigator.bookmarks[0] = page_navigator.current_page,
                        .num1 => page_navigator.bookmarks[1] = page_navigator.current_page,
                        .num2 => page_navigator.bookmarks[2] = page_navigator.current_page,
                        .num3 => page_navigator.bookmarks[3] = page_navigator.current_page,
                        .num4 => page_navigator.bookmarks[4] = page_navigator.current_page,
                        .num5 => page_navigator.bookmarks[5] = page_navigator.current_page,
                        .num6 => page_navigator.bookmarks[6] = page_navigator.current_page,
                        .num7 => page_navigator.bookmarks[7] = page_navigator.current_page,
                        .num8 => page_navigator.bookmarks[8] = page_navigator.current_page,
                        .num9 => page_navigator.bookmarks[9] = page_navigator.current_page,
                        else => {},
                    }
                } else if (event.key_pressed.control) {
                    switch (event.key_pressed.code) {
                        .left => page_navigator.goToNextHizb(&quran_sprite),
                        .right => page_navigator.goToPreviousHizb(&quran_sprite),
                        else => {},
                    }
                } else {
                    switch (event.key_pressed.code) {
                        .left => if (page_navigator.current_page < page_navigator.NUMBER_OF_PAGES) page_navigator.goToPage(&quran_sprite, page_navigator.current_page + 1),
                        .right => if (page_navigator.current_page > 1) page_navigator.goToPage(&quran_sprite, page_navigator.current_page - 1),
                        .num0 => page_navigator.goToPage(&quran_sprite, page_navigator.bookmarks[0]),
                        .num1 => page_navigator.goToPage(&quran_sprite, page_navigator.bookmarks[1]),
                        .num2 => page_navigator.goToPage(&quran_sprite, page_navigator.bookmarks[2]),
                        .num3 => page_navigator.goToPage(&quran_sprite, page_navigator.bookmarks[3]),
                        .num4 => page_navigator.goToPage(&quran_sprite, page_navigator.bookmarks[4]),
                        .num5 => page_navigator.goToPage(&quran_sprite, page_navigator.bookmarks[5]),
                        .num6 => page_navigator.goToPage(&quran_sprite, page_navigator.bookmarks[6]),
                        .num7 => page_navigator.goToPage(&quran_sprite, page_navigator.bookmarks[7]),
                        .num8 => page_navigator.goToPage(&quran_sprite, page_navigator.bookmarks[8]),
                        .num9 => page_navigator.goToPage(&quran_sprite, page_navigator.bookmarks[9]),
                        else => {},
                    }
                }

                // if (event.key_pressed.code == .I) {
                //        toggleZoom();
                // }
            },
            else => {},
        }

        window.clear(sf.Color.Black);
        defer window.display();

        //drawnig by the will of Allah
        window.draw(quran_sprite, null);

        ui.drawUi(&window, &quran_sprite) catch |e| {
            std.log.err("alhamdo li Allah error: {any}\n", .{e});
        };
    }

    try saveData();
}

fn saveData() !void {
    std.fs.makeDirAbsolute(app_data_dir_path) catch |e| switch (e) {
        std.fs.Dir.MakeError.PathAlreadyExists => {},
        else => return e,
    };

    var app_data_dir = try std.fs.openDirAbsolute(app_data_dir_path, .{});
    defer app_data_dir.close();

    var file = try app_data_dir.createFile("cache", .{ .read = true });
    defer file.close();

    var settings = Settings{ .bookmarks = undefined, .current_page = page_navigator.current_page };
    std.mem.copyForwards(usize, &settings.bookmarks, &page_navigator.bookmarks);
    try std.json.stringify(settings, .{}, file.writer());
}

fn loadData() !void {
    app_data_dir_path = try std.fs.getAppDataDir(allocator, "quran-warsh");

    var data_dir = try std.fs.openDirAbsolute(app_data_dir_path, .{});
    defer data_dir.close();

    var file = try data_dir.openFile("cache", .{ .mode = .read_write });
    defer file.close();

    const buffer = try allocator.alloc(u8, 512);
    defer allocator.free(buffer);

    const read_bytes = try file.readAll(buffer);

    const parsed = try std.json.parseFromSlice(Settings, allocator, buffer[0..read_bytes], .{ .ignore_unknown_fields = true, .duplicate_field_behavior = .use_last });
    defer parsed.deinit();

    page_navigator.current_page = parsed.value.current_page;
    std.mem.copyForwards(usize, &page_navigator.bookmarks, &parsed.value.bookmarks);
}

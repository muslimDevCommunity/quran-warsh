// بسم الله الرحمن الرحيم
// la ilaha illa Allah Mohammed Rassoul Allah

const std = @import("std");
const compile_config = @import("compile_config");
const builtin = @import("builtin");

const sf = struct {
    const sfml = @import("sfml");
    usingnamespace sfml;
    usingnamespace sfml.audio;
    usingnamespace sfml.graphics;
    usingnamespace sfml.window;
    usingnamespace sfml.system;
};

pub const NUMBER_OF_PAGES = 604;

pub const WINDOW_WIDTH = @import("bismi_allah.zig").WINDOW_WIDTH;
pub const WINDOW_HEIGHT = @import("bismi_allah.zig").WINDOW_HEIGHT;

pub var current_page: usize = 1;
pub var bookmarks: [10]usize = [1]usize{0} ** 10;

/// list of the number of pages every surah starts with
pub const surah_start_pages_list: [114]usize = [_]usize{ 1, 2, 50, 77, 106, 128, 151, 177, 187, 208, 221, 235, 249, 255, 262, 267, 282, 293, 305, 312, 322, 332, 342, 350, 359, 367, 377, 385, 396, 404, 411, 415, 418, 428, 434, 440, 446, 453, 458, 467, 477, 483, 489, 496, 499, 502, 507, 511, 515, 518, 520, 523, 526, 528, 531, 534, 537, 542, 545, 549, 551, 553, 554, 556, 558, 560, 562, 564, 566, 568, 570, 572, 574, 575, 577, 578, 580, 582, 583, 585, 586, 587, 587, 589, 590, 591, 591, 592, 593, 594, 595, 595, 596, 596, 597, 597, 598, 598, 599, 599, 600, 600, 601, 601, 601, 602, 602, 602, 603, 603, 603, 604, 604, 604 };
pub const hizb_start_pages_list: [60]usize = [60]usize{ 1, 11, 22, 32, 43, 51, 62, 72, 82, 92, 102, 111, 121, 132, 142, 151, 162, 173, 182, 192, 201, 212, 222, 231, 242, 252, 262, 272, 282, 292, 302, 312, 322, 332, 342, 352, 362, 371, 382, 392, 402, 413, 422, 431, 442, 451, 462, 472, 482, 491, 502, 513, 522, 531, 542, 553, 562, 572, 582, 591 };

var file_name_buffer: [std.fs.max_path_bytes]u8 = undefined;

fn embed_quran_pictures() ?[NUMBER_OF_PAGES][]const u8 {
    if (compile_config.embed_pictures) {
        var quran_pictures: [NUMBER_OF_PAGES][]const u8 = undefined;
        var comptime_file_name_buffer: [std.fs.max_path_bytes]u8 = undefined;

        var i: usize = 0;
        while (i < NUMBER_OF_PAGES) : (i += 1) {
            const comptime_file_name_slice = std.fmt.bufPrint(&comptime_file_name_buffer, "res/{d}-scaled.jpg", .{i + 1}) catch |e| {
                // std.log.err("alhamdo li Allah error while writing to 'comptime_file_name_buffer': {any}\n", .{e});
                @compileLog("alhamdo li Allah error ", e, " while writing to 'comptime_file_name_buffer' ", i);
                @compileError("error while writing file name to buffer\n");
            };

            const file = @embedFile(comptime_file_name_slice);
            quran_pictures[i] = file;
        }

        return quran_pictures;
    } else return null;
}

const quran_pictures_arr = if (compile_config.embed_pictures) embed_quran_pictures().? else undefined;

pub var possible_quran_dir_paths_buffers: [4][]u8 = .{
    // this is set by 'src/download_images.zig'
    // "res" is just a placeholder in case of error
    @constCast("res"),
    // this is set by 'src/bismi_allah.zig:get_self_exe_dir_path' block
    // "res" is just a placeholder in case of error
    @constCast("res"),
    @constCast("/usr/share/quran-warsh"),
    // alhamdo li Allah
    // for this "res" it looks in the path relative to the caller (just in case)
    @constCast("res"),
};

/// sets the page diplayed starting from 1
pub fn goToPage(sprite: *sf.Sprite, target_page: usize) void {
    if (target_page > NUMBER_OF_PAGES or 0 == target_page) return;

    if (sprite.getTexture()) |texture| {
        sf.c.sfTexture_destroy(@constCast(texture._const_ptr));
    }

    // possible_quran_dir_paths_buffers[0] = @constCast("/usr/share/quran_pictures");
    // std.fs.selfExeDirPath(&possible_quran_dir_paths_buffers[1]) catch {};

    if (compile_config.embed_pictures) {
        sprite.setTexture(sf.Texture.createFromMemory(quran_pictures_arr[target_page - 1], .{ .top = 0, .left = 0, .width = 0, .height = 0 }) catch unreachable);
    } else {
        for (possible_quran_dir_paths_buffers) |possible_quran_dir_path| {
            // by the will of Allah
            // TODO: change the "{s}/{d}-scaled.jpg" to be "{s}/{d}{s}"
            //       the last {s} should be .[_][]u8 {".jpg", "-scaled.jpg", ".png"}
            const file_name_slice = std.fmt.bufPrintZ(&file_name_buffer, "{s}/{d}.jpg", .{ possible_quran_dir_path, target_page }) catch |e| {
                if (builtin.mode == .Debug) {
                    std.log.err("alhamdo li Allah error while writing to 'file_name_buffer': {any} target_page {d}\n", .{ e, target_page });
                }
                continue;
            };

            var texture = sf.Texture.createFromFile(file_name_slice) catch |e| {
                if (builtin.mode == .Debug) {
                    std.log.err("alhamdo li Allah error while callings 'sf.Texture.createFromFile()' err: '{any}' \n", .{e});
                }
                continue;
            };
            texture.setSmooth(true);

            const texture_size = texture.getSize();
            const texture_size_float: sf.Vector2f = .{ .x = @floatFromInt(texture_size.x), .y = @floatFromInt(texture_size.y) };

            sprite.setScale(.{ .x = WINDOW_WIDTH / texture_size_float.x, .y = WINDOW_HEIGHT / texture_size_float.y });
            sprite.setTexture(texture);

            break; // bismi Allah: if we get here then the images was found
        }
    }

    current_page = target_page;
}

pub fn getCurrentSurahIndex() usize {
    var i: usize = 0;
    while (i < surah_start_pages_list.len) : (i += 1) {
        if (current_page <= surah_start_pages_list[i]) return i;
    }
    return 0;
}

pub fn goToSurahByIndex(sprite: *sf.Sprite, index: usize) void {
    goToPage(sprite, surah_start_pages_list[index]);
}

pub fn goToNextSurah(sprite: *sf.Sprite) void {
    const current_surah_index = getCurrentSurahIndex();
    const starting_page = current_page;
    if (current_page == NUMBER_OF_PAGES) {
        goToPage(sprite, 1);
    } else {
        goToPage(sprite, surah_start_pages_list[current_surah_index + 1]);
        if (starting_page == current_page) {
            goToPage(sprite, current_page + 1);
        }
    }
}

pub fn goToPreviousSurah(sprite: *sf.Sprite) void {
    const current_surah_index = getCurrentSurahIndex();
    if (current_surah_index == 0) {
        goToPage(sprite, surah_start_pages_list[surah_start_pages_list.len - 1]);
    } else {
        goToPage(sprite, surah_start_pages_list[current_surah_index - 1]);
    }
}

pub fn getCurrentHizbIndex() usize {
    var i: usize = 0;
    while (i < hizb_start_pages_list.len) : (i += 1) {
        if (current_page <= hizb_start_pages_list[i]) return i;
    }
    return 0;
}

pub fn goToHizbByIndex(sprite: *sf.Sprite, index: usize) void {
    goToPage(sprite, hizb_start_pages_list[index]);
}

pub fn goToNextHizb(sprite: *sf.Sprite) void {
    const current_hizb_index = getCurrentHizbIndex();
    if (current_hizb_index == 59) {
        goToPage(sprite, 1);
    } else {
        goToPage(sprite, hizb_start_pages_list[current_hizb_index + 1]);
    }
}

pub fn goToPreviousHizb(sprite: *sf.Sprite) void {
    const current_hizb_index = getCurrentHizbIndex();
    if (current_hizb_index == 0) {
        goToPage(sprite, hizb_start_pages_list[hizb_start_pages_list.len - 1]);
    } else {
        goToPage(sprite, hizb_start_pages_list[current_hizb_index - 1]);
    }
}

test "surah start pages list is ordered" {
    var i: usize = 0;
    while (i < surah_start_pages_list.len - 1) : (i += 1) {
        std.debug.assert(surah_start_pages_list[i] <= surah_start_pages_list[i + 1]);
    }
}

test "hizb start pages list is ordered" {
    var i: usize = 0;
    while (i < hizb_start_pages_list.len - 1) : (i += 1) {
        std.debug.assert(hizb_start_pages_list[i] <= hizb_start_pages_list[i + 1]);
    }
}

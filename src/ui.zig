//بسم الله الرحمن الرحيم
//la ilaha illa Allah Mohammed Rassoul Allah

const std = @import("std");
const compile_config = @import("compile_config");

const sf = struct {
    const sfml = @import("sfml");
    usingnamespace sfml;
    usingnamespace sfml.audio;
    usingnamespace sfml.graphics;
    usingnamespace sfml.window;
    usingnamespace sfml.system;
};

const page_navigator = @import("page_navigator.zig");
const downloadImagesWrapper = @import("download_images.zig").downloadImagesWrapper;

pub const font_data = @embedFile("res/18_Khebrat_Musamim_Regular.ttf");
pub var font: sf.Font = undefined;

pub var is_mouse_button_left_pressed: bool = false;
pub var mouse_position: sf.Vector2i = undefined;

const WINDOW_WIDTH = @import("bismi_allah.zig").WINDOW_WIDTH;
const WINDOW_HEIGHT = @import("bismi_allah.zig").WINDOW_HEIGHT;
const BUTTON_WIDTH = WINDOW_WIDTH / 2;
const BUTTON_HEIGHT: comptime_float = (3.90625 * WINDOW_HEIGHT) / 100.0;

const utf32_numbers_literals = blk: {
    var utf32_numbers: [61][:0]u32 = undefined;

    for (0..61) |i| {
        var number_buffer: [3]u8 = [1]u8{0} ** 3;
        const number_slice = std.fmt.bufPrintZ(&number_buffer, "{d}", .{i}) catch @compileError("alhamdo li Allah error while making utf32_numbers_literals");
        const number_slice_u32 = sf.toUnicodeComptime(number_slice);
        utf32_numbers[i] = @constCast(number_slice_u32);
    }

    break :blk utf32_numbers;
};

var state = enum {
    Menu,
    None,

    Surah,
    Hizb,

    BookmarkGet,
    BookmarkSet,
}.None;

var page_number: u8 = 0;

pub fn drawUi(window: *sf.RenderWindow, sprite: *sf.Sprite) !void {
    switch (state) {
        .Surah => {
            for (19 * page_number..page_number * 19 + 19) |i| {
                if (try imguiButton(window, .{ .left = WINDOW_WIDTH / 4, .top = @as(f32, @floatFromInt(i - 19 * page_number)) * BUTTON_HEIGHT + (WINDOW_HEIGHT / 10), .width = WINDOW_WIDTH / 2, .height = BUTTON_HEIGHT }, page_navigator.surah_names[i])) {
                    page_navigator.goToSurahByIndex(sprite, i);
                    state = .None;
                    page_number = 0;
                }
            }
            if (try imguiButton(window, .{ .left = 0, .top = WINDOW_HEIGHT - BUTTON_HEIGHT, .width = WINDOW_WIDTH / 3, .height = BUTTON_HEIGHT }, sf.toUnicodeComptime("next")) and page_number < 5) page_number += 1;
            if (try imguiButton(window, .{ .left = WINDOW_WIDTH - (WINDOW_WIDTH / 3), .top = WINDOW_HEIGHT - BUTTON_HEIGHT, .width = WINDOW_WIDTH / 3, .height = BUTTON_HEIGHT }, sf.toUnicodeComptime("previous")) and page_number > 0) page_number -= 1;
        },
        .Hizb => {
            for (20 * page_number..page_number * 20 + 20) |i| {
                if (try imguiButton(window, .{ .left = WINDOW_WIDTH / 4, .top = @as(f32, @floatFromInt(i - 20 * page_number)) * BUTTON_HEIGHT + (WINDOW_HEIGHT / 10), .width = WINDOW_WIDTH / 2, .height = BUTTON_HEIGHT }, utf32_numbers_literals[i + 1])) {
                    page_navigator.goToHizbByIndex(sprite, i);
                    state = .None;
                    page_number = 0;
                }
            }
            if (try imguiButton(window, .{ .left = 0, .top = WINDOW_HEIGHT - BUTTON_HEIGHT, .width = WINDOW_WIDTH / 3, .height = BUTTON_HEIGHT }, sf.toUnicodeComptime("next")) and page_number < 2) page_number += 1;
            if (try imguiButton(window, .{ .left = WINDOW_WIDTH - (WINDOW_WIDTH / 3), .top = WINDOW_HEIGHT - BUTTON_HEIGHT, .width = WINDOW_WIDTH / 3, .height = BUTTON_HEIGHT }, sf.toUnicodeComptime("previous")) and page_number > 0) page_number -= 1;
        },
        .None => {
            if (is_mouse_button_left_pressed) state = .Menu;
        },
        .Menu => {
            if (try imguiButton(window, .{ .top = (WINDOW_HEIGHT / 4), .left = WINDOW_WIDTH / 4, .width = WINDOW_WIDTH / 2, .height = BUTTON_HEIGHT }, sf.toUnicodeComptime("Surah"))) state = .Surah;
            if (try imguiButton(window, .{ .top = (WINDOW_HEIGHT / 4) + (BUTTON_HEIGHT * 1), .left = WINDOW_WIDTH / 4, .width = WINDOW_WIDTH / 2, .height = BUTTON_HEIGHT }, sf.toUnicodeComptime("Hizb"))) state = .Hizb;
            if (try imguiButton(window, .{ .top = (WINDOW_HEIGHT / 4) + (BUTTON_HEIGHT * 2), .left = WINDOW_WIDTH / 4, .width = WINDOW_WIDTH / 2, .height = BUTTON_HEIGHT }, sf.toUnicodeComptime("Go to bookmark"))) state = .BookmarkGet;
            if (try imguiButton(window, .{ .top = (WINDOW_HEIGHT / 4) + (BUTTON_HEIGHT * 3), .left = WINDOW_WIDTH / 4, .width = WINDOW_WIDTH / 2, .height = BUTTON_HEIGHT }, sf.toUnicodeComptime("Set Bookmark"))) state = .BookmarkSet;
            if (!compile_config.embed_pictures) {
                if (try imguiButton(window, .{ .top = (WINDOW_HEIGHT / 4) + (BUTTON_HEIGHT * 4), .left = WINDOW_WIDTH / 4, .width = WINDOW_WIDTH / 2, .height = BUTTON_HEIGHT }, sf.toUnicodeComptime("download high resolution images"))) {
                    try downloadImagesWrapper();
                    state = .None;
                }
            }
        },
        .BookmarkGet, .BookmarkSet => {
            for (0..10) |i| {
                if (try imguiButton(window, .{ .left = WINDOW_WIDTH / 4, .top = @as(f32, @floatFromInt(i)) * BUTTON_HEIGHT + (WINDOW_HEIGHT / 4), .width = WINDOW_WIDTH / 2, .height = BUTTON_HEIGHT }, utf32_numbers_literals[i + 1])) {
                    if (state == .BookmarkSet) page_navigator.bookmarks[i] = page_navigator.current_page else page_navigator.goToPage(sprite, page_navigator.bookmarks[i]);
                    state = .None;
                }
            }
        },
    }
    if (state != .None and try imguiButton(window, .{ .top = 0, .left = 0, .width = WINDOW_WIDTH / 5, .height = BUTTON_HEIGHT }, sf.toUnicodeComptime("close"))) {
        state = .None;
        page_number = 0;
    }
}

fn imguiButton(window: *sf.RenderWindow, rect: sf.Rect(f32), message: [:0]const u32) !bool {
    var button = try sf.RectangleShape.create(rect.getSize());
    button.setPosition(rect.getPosition());
    defer button.destroy();

    // button.setFillColor(.{ .r = 0, .g = 0, .b = 0, .a = 0 });
    button.setFillColor(sf.Color.Black);

    var text_message = try sf.Text.createWithTextUnicode(message, font, @intFromFloat(rect.height * 0.75));
    defer text_message.destroy();

    text_message.setFillColor(sf.Color.White);
    text_message.setPosition(rect.getPosition());

    window.draw(button, null);
    window.draw(text_message, null);

    if (!is_mouse_button_left_pressed) return false;
    // const mouse_pos = window.mapPixelToCoords(sf.mouse.getPosition(window.*), window.getView());
    return rect.contains(window.mapPixelToCoords(mouse_position, window.getView()));
}

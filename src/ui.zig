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

const page_navigator = @import("page_navigator.zig");

pub const font_data = @embedFile("res/18_Khebrat_Musamim_Regular.ttf");
pub var font: sf.Font = undefined;

const IMAGE_WIDTH = @import("bismi_allah.zig").IMAGE_WIDTH;
const IMAGE_HEIGHT = @import("bismi_allah.zig").IMAGE_HEIGHT;

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
                if (try imguiButton(window, .{ .left = IMAGE_WIDTH / 4, .top = @floatFromInt((i - 19 * page_number) * 100 + 300), .width = IMAGE_WIDTH / 2, .height = 100 }, page_navigator.surah_names[i])) {
                    page_navigator.goToSurahByIndex(sprite, i);
                    state = .None;
                    page_number = 0;
                }
            }
            if (try imguiButton(window, .{ .left = 10, .top = IMAGE_HEIGHT / 2, .width = 120, .height = 100 }, "next") and page_number < 5) page_number += 1;
            if (try imguiButton(window, .{ .left = IMAGE_WIDTH - 240, .top = IMAGE_HEIGHT / 2, .width = 230, .height = 100 }, "previous") and page_number > 0) page_number -= 1;
        },
        .Hizb => {
            var buffer_number_str: [3:0]u8 = undefined;
            for (20 * page_number..page_number * 20 + 20) |i| {
                if (try imguiButton(window, .{ .left = IMAGE_WIDTH / 4, .top = @floatFromInt((i - 20 * page_number) * 100 + 300), .width = IMAGE_WIDTH / 2, .height = 100 }, try std.fmt.bufPrintZ(&buffer_number_str, "{d}", .{i + 1}))) {
                    page_navigator.goToHizbByIndex(sprite, i);
                    state = .None;
                    page_number = 0;
                }
            }
            if (try imguiButton(window, .{ .left = 10, .top = IMAGE_HEIGHT / 2, .width = 120, .height = 100 }, "next") and page_number < 2) page_number += 1;
            if (try imguiButton(window, .{ .left = IMAGE_WIDTH - 240, .top = IMAGE_HEIGHT / 2, .width = 230, .height = 100 }, "previous") and page_number > 0) page_number -= 1;
        },
        .None => {
            if (sf.mouse.isButtonPressed(.left)) state = .Menu;
        },
        .Menu => {
            if (try imguiButton(window, .{ .top = 900, .left = IMAGE_WIDTH / 4, .width = IMAGE_WIDTH / 2, .height = 100 }, "Surah")) state = .Surah;
            if (try imguiButton(window, .{ .top = 1000, .left = IMAGE_WIDTH / 4, .width = IMAGE_WIDTH / 2, .height = 100 }, "Hizb")) state = .Hizb;
            if (try imguiButton(window, .{ .top = 1100, .left = IMAGE_WIDTH / 4, .width = IMAGE_WIDTH / 2, .height = 100 }, "Go to bookmark")) state = .BookmarkGet;
            if (try imguiButton(window, .{ .top = 1200, .left = IMAGE_WIDTH / 4, .width = IMAGE_WIDTH / 2, .height = 100 }, "Set Bookmark")) state = .BookmarkSet;
        },
        .BookmarkGet, .BookmarkSet => {
            var buffer_number_str: [10:0]u8 = undefined;
            for (0..10) |i| {
                if (try imguiButton(window, .{ .left = IMAGE_WIDTH / 4, .top = @floatFromInt(i * 100 + 600), .width = IMAGE_WIDTH / 2, .height = 100 }, try std.fmt.bufPrintZ(&buffer_number_str, "{d}", .{i + 1}))) {
                    if (state == .BookmarkSet) page_navigator.bookmarks[i] = page_navigator.current_page else page_navigator.goToPage(sprite, page_navigator.bookmarks[i]);
                    state = .None;
                }
            }
        },
    }
    if (state != .None and try imguiButton(window, .{ .top = 0, .left = 0, .width = 180, .height = 100 }, "close")) state = .None;
}

fn imguiButton(window: *sf.RenderWindow, rect: sf.Rect(f32), message: [:0]const u8) !bool {
    var button = try sf.RectangleShape.create(rect.getSize());
    button.setPosition(rect.getPosition());
    defer button.destroy();

    // button.setFillColor(.{ .r = 0, .g = 0, .b = 0, .a = 0 });
    button.setFillColor(sf.Color.Black);

    var text_message = try sf.Text.createWithText(message, font, @intFromFloat(rect.height * 0.75));
    defer text_message.destroy();

    text_message.setFillColor(sf.Color.White);
    text_message.setPosition(rect.getPosition());

    window.draw(button, null);
    window.draw(text_message, null);

    if (!sf.mouse.isButtonPressed(.left)) return false;
    // const mouse_pos = window.mapPixelToCoords(sf.mouse.getPosition(window.*), window.getView());
    return rect.contains(window.mapPixelToCoords(sf.mouse.getPosition(window.*), window.getView()));
}

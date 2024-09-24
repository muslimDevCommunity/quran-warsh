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

fn toUnicodeWrapper(utf8: []const u8) [:0]const u32 {
    @setEvalBranchQuota(10000); //minimal one required thanks to Allah
    return sf.toUnicodeComptime(utf8);
}

/// the names of every surah in utf32
/// it an array of utf8 converted to utf32 at compile time
/// note: these are utf codes 'as is' copied letter by letter rather
///       than writing letting a formatter format them
pub const surah_names = [114][:0]const u32{
    toUnicodeWrapper("\u{FE94}\u{FEA4}\u{FE97}\u{FE8E}\u{FED4}\u{FEDF}\u{FE8D}"), //al fatihah
    toUnicodeWrapper("\u{FE93}\u{FEAE}\u{FED8}\u{FE92}\u{FEDF}\u{FE8D}"), //al bakarah
    toUnicodeWrapper("\u{FEE5}\u{FE8D}\u{FEAE}\u{FEE4}\u{FECB} \u{FEDD}\u{FE81}"), //al imran
    toUnicodeWrapper("\u{FE80}\u{FE8E}\u{FEB4}\u{FEE8}\u{FEDF}\u{FE8D}"), //al nisa
    toUnicodeWrapper("\u{FE93}\u{FEAA}\u{FE8B}\u{FE8E}\u{FEE4}\u{FEDF}\u{FE8D}"), //al maidah
    toUnicodeWrapper("\u{FEE1}\u{FE8E}\u{FECC}\u{FEE7}\u{FEF7}\u{FE8D}"), //al anam
    toUnicodeWrapper("\u{FED1}\u{FE8D}\u{FEAE}\u{FECB}\u{FEF7}\u{FE8D}"), //al a'raf
    toUnicodeWrapper("\u{FEDD}\u{FE8E}\u{FED4}\u{FEE7}\u{FEF7}\u{FE8D}"), //al anfal
    toUnicodeWrapper("\u{FE94}\u{FE91}\u{FEEE}\u{FE98}\u{FEDF}\u{FE8D}"), //tawbah
    toUnicodeWrapper("\u{FEB2}\u{FEE7}\u{FEEE}\u{FEF3}"), //yunus
    toUnicodeWrapper("\u{FEA9}\u{FEEE}\u{FEEB}"), //hud
    toUnicodeWrapper("\u{FED2}\u{FEB3}\u{FEEE}\u{FEF3}"), //yusuf
    toUnicodeWrapper("\u{FEAA}\u{FECB}\u{FEAE}\u{FEDF}\u{FE8D}"), //al ra'd
    toUnicodeWrapper("\u{FEE2}\u{FEF4}\u{FEEB}\u{FE8D}\u{FEAE}\u{FE91}\u{FE87}"), //Ibrahim
    toUnicodeWrapper("\u{FEAE}\u{FEA0}\u{FEA4}\u{FEDF}\u{FE8D}"), //al hijr
    toUnicodeWrapper("\u{FEDE}\u{FEA4}\u{FEE8}\u{FEDF}\u{FE8D}"), //al nahl
    toUnicodeWrapper("\u{FE80}\u{FE8D}\u{FEAE}\u{FEB3}\u{FEF9}\u{FE8D}"), //al isra'
    toUnicodeWrapper("\u{FED2}\u{FEEC}\u{FEDC}\u{FEDF}\u{FE8D}"), //al kahf
    toUnicodeWrapper("\u{FEE2}\u{FEF3}\u{FEAE}\u{FEE3}"), //Mariem
    toUnicodeWrapper("\u{FEEA}\u{FEC1}"), //taha
    toUnicodeWrapper("\u{FE80}\u{FE8E}\u{FEF4}\u{FE92}\u{FEE7}\u{FEF7}\u{FE8D}"), //al anbia'
    toUnicodeWrapper("\u{FE9E}\u{FEA4}\u{FEDF}\u{FE8D}"), //al haj
    toUnicodeWrapper("\u{FEE5}\u{FEEE}\u{FEE8}\u{FEE3}\u{FEEE}\u{FEE4}\u{FEDF}\u{FE8D}"), //al muminun
    toUnicodeWrapper("\u{FEAD}\u{FEEE}\u{FEE8}\u{FEDF}\u{FE8D}"), //al nur
    toUnicodeWrapper("\u{FEE5}\u{FE8E}\u{FED7}\u{FEAE}\u{FED4}\u{FEDF}\u{FE8D}"), //al furqan
    toUnicodeWrapper("\u{FEEF}\u{FEAD}\u{FEEE}\u{FEB8}\u{FEDF}\u{FE8D}"), //shu'ara
    toUnicodeWrapper("\u{FEDE}\u{FEE4}\u{FEE8}\u{FEDF}\u{FE8D}"), //al naml
    toUnicodeWrapper("\u{FEBA}\u{FEBC}\u{FED8}\u{FEDF}\u{FE8D}"), //al qasas
    toUnicodeWrapper("\u{FE95}\u{FEEE}\u{FEDC}\u{FEE8}\u{FECC}\u{FEDF}\u{FE8D}"), //al ankabut
    toUnicodeWrapper("\u{FEE1}\u{FEED}\u{FEAE}\u{FEDF}\u{FE8D}"), //al rum
    toUnicodeWrapper("\u{FEE5}\u{FE8E}\u{FEE4}\u{FED8}\u{FEDF}"), //luqman
    toUnicodeWrapper("\u{FE93}\u{FEAA}\u{FEA0}\u{FEB4}\u{FEDF}\u{FE8D}"), //al sajdah
    toUnicodeWrapper("\u{FE8F}\u{FE8D}\u{FEB0}\u{FEA3}\u{FEF7}\u{FE8D}"), //al ahzab
    toUnicodeWrapper("\u{FE84}\u{FE92}\u{FEB3}"), //saba
    toUnicodeWrapper("\u{FEAE}\u{FEC3}\u{FE8E}\u{FED3}"), //fatir
    toUnicodeWrapper("\u{FEB2}\u{FEF3}"), //yasin
    toUnicodeWrapper("\u{FE95}\u{FE8E}\u{FED3}\u{FE8E}\u{FEBC}\u{FEDF}\u{FE8D}"), //saffat
    toUnicodeWrapper("\u{FEB9}"), //sad
    toUnicodeWrapper("\u{FEAE}\u{FEE3}\u{FEB0}\u{FEDF}\u{FE8D}"), //al zumar
    toUnicodeWrapper("\u{FEAE}\u{FED3}\u{FE8E}\u{FECF}"), //ghafir
    toUnicodeWrapper("ﺖ\u{FEE0}\u{FEBC}\u{FED3}"), //fussilat
    toUnicodeWrapper("ىرﻮﺸﻟﺍ"), //al shura
    toUnicodeWrapper("ﻑﺮﺧﺰﻟﺍ"), //zukhruf
    toUnicodeWrapper("ﻥﺎﺧﺪﻟﺍ"), //al dukhan
    toUnicodeWrapper("ﺔﻴﺛﺎﺠﻟﺍ"), //al jathiyah
    toUnicodeWrapper("ﻑﺎﻘﺣﻷﺍ"), //al ahqaf
    toUnicodeWrapper("ﺪﻤﺤﻣ"), //muhammad
    toUnicodeWrapper("ﺢﺘﻔﻟﺍ"), //al fath
    toUnicodeWrapper("ﺕﺍﺮﺠﺤﻟﺍ"), //al hujurat
    toUnicodeWrapper("ق"), //qaf
    toUnicodeWrapper("ﺕﺎﻳرﺍﺬﻟﺍ"), //al dhariyat
    toUnicodeWrapper("رﻮﻂﻟﺍ"), //al tur
    toUnicodeWrapper("ﻢﺠﻨﻟﺍ"), //al najm
    toUnicodeWrapper("ﺮﻤﻘﻟﺍ"), //al qamar
    toUnicodeWrapper("ﻥﺎﻤﺣﺮﻟﺍ"), //al rahman
    toUnicodeWrapper("ﺔﻌﻗاﻮﻟﺍ"), //al waqiah
    toUnicodeWrapper("ﺪﻳﺪﺤﻟﺍ"), //al hadid
    toUnicodeWrapper("ﺔﻟدﺎﺠﻤﻟﺍ"), //al mujadilah
    toUnicodeWrapper("ﺮﺸﺤﻟﺍ"), //al hashr
    toUnicodeWrapper("ﺔﻨﺤﺘﻤﻤﻟﺍ"), //al mumtahanah
    toUnicodeWrapper("ﻒﺼﻟﺍ"), //al saff
    toUnicodeWrapper("ﺔﻌﻤﺠﻟﺍ"), //al jumu'ah
    toUnicodeWrapper("نﻮﻘﻓﺎﻨﻤﻟﺍ"), //al munafiqun
    toUnicodeWrapper("ﻦﺑﺎﻐﺘﻟﺍ"), //ak taghabun
    toUnicodeWrapper("قﻼﻂﻟﺍ"), //al talaq
    toUnicodeWrapper("ﻢﻳﺮﺤﺘﻟﺍ"), //al tahrim
    toUnicodeWrapper("ﻚﻠﻤﻟﺍ"), //al mulk
    toUnicodeWrapper("ﻢﻠﻘﻟﺍ"), //al qalam
    toUnicodeWrapper("ﺔﻗﺎﺤﻟﺍ"), //al haqqah
    toUnicodeWrapper("جرﺎﻌﻤﻟﺍ"), //al maarij
    toUnicodeWrapper("حﻮﻧ"), //nuh
    toUnicodeWrapper("ﻦﺠﻟﺍ"), //al jinn
    toUnicodeWrapper("ﻞﻣﺰﻤﻟﺍ"), //al muzzammil
    toUnicodeWrapper("ﺮﺛﺪﻤﻟﺍ"), //al muddathir
    toUnicodeWrapper("ﺔﻣﺎﻴﻘﻟﺍ"), //al qiyamah
    toUnicodeWrapper("ﻥﺎﺴﻧﻹﺍ"), //al insan
    toUnicodeWrapper("تﻼﺳﺮﻤﻟﺍ"), //al mursalat
    toUnicodeWrapper("ﺄﺒﻨﻟﺍ"), //al naba
    toUnicodeWrapper("تﺎﻋﺯﺎﻨﻟﺍ"), //al naziat
    toUnicodeWrapper("ﺲﺒﻋ"), //abasa
    toUnicodeWrapper("ﺮﻳﻮﻜﺘﻟﺍ"), //al takwir
    toUnicodeWrapper("رﺎﻄﻔﻧﻹﺍ"), //al infitar
    toUnicodeWrapper("ﻦﻴﻔﻔﻄﻤﻟﺍ"), //al mutaffifin
    toUnicodeWrapper("قﺎﻘﺸﻧﻹﺍ"), //al inshiqaq
    toUnicodeWrapper("جوﺮﺒﻟﺍ"), //al buruj
    toUnicodeWrapper("قرﺎﻄﻟﺍ"), //al tariq
    toUnicodeWrapper("ﻰﻠﻋﻷﺍ"), //al a'la
    toUnicodeWrapper("ﺔﻴﺷﺎﻐﻟﺍ"), //al ghashiyah
    toUnicodeWrapper("ﺮﺠﻔﻟﺍ"), //al fajr
    toUnicodeWrapper("ﺪﻠﺒﻟﺍ"), //al balad
    toUnicodeWrapper("ﺲﻤﺸﻟﺍ"), //al shams
    toUnicodeWrapper("ﻞﻴﻠﻟﺍ"), //al layl
    toUnicodeWrapper("ﻰﺤﻀﻟﺍ"), //al duha
    toUnicodeWrapper("حﺮﺸﻟﺍ"), //al sharh
    toUnicodeWrapper("ﻦﻴﺘﻟﺍ"), //al tin
    toUnicodeWrapper("ﻖﻠﻌﻟﺍ"), //al alaq
    toUnicodeWrapper("رﺪﻘﻟﺍ"), //al qadr
    toUnicodeWrapper("ﺔﻨﻴﺒﻟﺍ"), //al bayyinah
    toUnicodeWrapper("ﺔﻟﺰﻟﺰﻟﺍ"), //al zalzalah
    toUnicodeWrapper("ﺕﺎﻳدﺎﻌﻟﺍ"), //al adiyat
    toUnicodeWrapper("ﺔﻋرﺎﻘﻟﺍ"), //al qari'ah
    toUnicodeWrapper("ﺮﺛﺎﻜﺘﻟﺍ"), //al takathur
    toUnicodeWrapper("ﺮﺼﻌﻟﺍ"), //al asr
    toUnicodeWrapper("ﺓﺰﻤﻬﻟﺍ"), //al humazah
    toUnicodeWrapper("ﻞﻴﻔﻟﺍ"), //al fil
    toUnicodeWrapper("ﺶﻳﺮﻗ"), //quraish
    toUnicodeWrapper("نﻮﻋﺎﻤﻟﺍ"), //al ma'un
    toUnicodeWrapper("ﺮﺛﻮﻜﻟﺍ"), //al kawthar
    toUnicodeWrapper("نوﺮﻓﺎﻜﻟﺍ"), //al kafirun
    toUnicodeWrapper("ﺮﺼﻨﻟﺍ"), //al nasr
    toUnicodeWrapper("ﺪﺴﻤﻟﺍ"), //al masad
    toUnicodeWrapper("صﻼﺧﻹﺍ"), //al ikhlas
    toUnicodeWrapper("ﻖﻠﻔﻟﺍ"), //al falaq
    toUnicodeWrapper("\u{FEB1}\u{FE8E}\u{FEE8}\u{FEDF}\u{FE8D}"), //al nas
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
                if (try imguiButton(window, .{ .left = WINDOW_WIDTH / 4, .top = @as(f32, @floatFromInt(i - 19 * page_number)) * BUTTON_HEIGHT + (WINDOW_HEIGHT / 10), .width = WINDOW_WIDTH / 2, .height = BUTTON_HEIGHT }, surah_names[i])) {
                    page_navigator.goToSurahByIndex(sprite, i);
                    state = .None;
                    page_number = 0;
                }
            }
            if (try imguiButton(window, .{ .left = WINDOW_WIDTH - (WINDOW_WIDTH / 3), .top = WINDOW_HEIGHT - BUTTON_HEIGHT, .width = WINDOW_WIDTH / 3, .height = BUTTON_HEIGHT }, sf.toUnicodeComptime("ﻲﻟﺎﺘﻟﺍ")) and page_number < 5) page_number += 1;
            if (try imguiButton(window, .{ .left = 0, .top = WINDOW_HEIGHT - BUTTON_HEIGHT, .width = WINDOW_WIDTH / 3, .height = BUTTON_HEIGHT }, sf.toUnicodeComptime("ﻖﺑﺎﺴﻟﺍ")) and page_number > 0) page_number -= 1;
        },
        .Hizb => {
            for (20 * page_number..page_number * 20 + 20) |i| {
                if (try imguiButton(window, .{ .left = WINDOW_WIDTH / 4, .top = @as(f32, @floatFromInt(i - 20 * page_number)) * BUTTON_HEIGHT + (WINDOW_HEIGHT / 10), .width = WINDOW_WIDTH / 2, .height = BUTTON_HEIGHT }, utf32_numbers_literals[i + 1])) {
                    page_navigator.goToHizbByIndex(sprite, i);
                    state = .None;
                    page_number = 0;
                }
            }
            if (try imguiButton(window, .{ .left = WINDOW_WIDTH - (WINDOW_WIDTH / 3), .top = WINDOW_HEIGHT - BUTTON_HEIGHT, .width = WINDOW_WIDTH / 3, .height = BUTTON_HEIGHT }, sf.toUnicodeComptime("ﻲﻟﺎﺘﻟﺍ")) and page_number < 2) page_number += 1;
            if (try imguiButton(window, .{ .left = 0, .top = WINDOW_HEIGHT - BUTTON_HEIGHT, .width = WINDOW_WIDTH / 3, .height = BUTTON_HEIGHT }, sf.toUnicodeComptime("ﻖﺑﺎﺴﻟﺍ")) and page_number > 0) page_number -= 1;
        },
        .None => {
            if (is_mouse_button_left_pressed) state = .Menu;
        },
        .Menu => {
            if (try imguiButton(window, .{ .top = (WINDOW_HEIGHT / 4), .left = WINDOW_WIDTH / 4, .width = WINDOW_WIDTH / 2, .height = BUTTON_HEIGHT }, sf.toUnicodeComptime("رﻮﺴﻟﺍ"))) state = .Surah;
            if (try imguiButton(window, .{ .top = (WINDOW_HEIGHT / 4) + (BUTTON_HEIGHT * 1), .left = WINDOW_WIDTH / 4, .width = WINDOW_WIDTH / 2, .height = BUTTON_HEIGHT }, sf.toUnicodeComptime("باﺰﺣﻷﺍ"))) state = .Hizb;
            if (try imguiButton(window, .{ .top = (WINDOW_HEIGHT / 4) + (BUTTON_HEIGHT * 2), .left = WINDOW_WIDTH / 4, .width = WINDOW_WIDTH / 2, .height = BUTTON_HEIGHT }, sf.toUnicodeComptime("ﺔﻣﻼﻌﻟا ﻰﻟإ ﻞﻘﺘﻧإ"))) state = .BookmarkGet;
            if (try imguiButton(window, .{ .top = (WINDOW_HEIGHT / 4) + (BUTTON_HEIGHT * 3), .left = WINDOW_WIDTH / 4, .width = WINDOW_WIDTH / 2, .height = BUTTON_HEIGHT }, sf.toUnicodeComptime("ﺔﻣﻼﻌﻟا ﻆﻔﺣ"))) state = .BookmarkSet;
            if (!compile_config.embed_pictures) {
                if (try imguiButton(window, .{ .top = (WINDOW_HEIGHT / 4) + (BUTTON_HEIGHT * 4), .left = WINDOW_WIDTH / 4, .width = WINDOW_WIDTH / 2, .height = BUTTON_HEIGHT }, sf.toUnicodeComptime("ةدﻮﺠﻟﺍ ﺔﻴﻟﺎﻋ رﻮﺼﻟﺍ ﻞﻳﺰﻨﺗ"))) {
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
    if (state != .None and try imguiButton(window, .{ .top = 0, .left = 0, .width = WINDOW_WIDTH / 5, .height = BUTTON_HEIGHT }, sf.toUnicodeComptime("ﻖﻠﻏأ"))) {
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
    {
        var final_text_pos = rect.getPosition();

        //TODO: make the '- 10' relative
        final_text_pos.x = (rect.left + rect.width) - text_message.getGlobalBounds().width - 10;

        text_message.setPosition(final_text_pos);
    }

    window.draw(button, null);
    window.draw(text_message, null);

    if (!is_mouse_button_left_pressed) return false;
    // const mouse_pos = window.mapPixelToCoords(sf.mouse.getPosition(window.*), window.getView());
    return rect.contains(window.mapPixelToCoords(mouse_position, window.getView()));
}

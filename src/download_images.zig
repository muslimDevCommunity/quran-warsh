//بسم الله الرحمن الرحيم
//la ilaha illa Allah Mohammed Rassoul Allah
const std = @import("std");

const NUMBER_OF_PAGES = @import("page_navigator.zig").NUMBER_OF_PAGES;

var is_downloading_images = false;
/// `app_data_dir_path` should be set in `bismi_allah.zig`
pub var app_data_dir_path: []u8 = undefined;

pub var buffer_images_dir_path: [std.fs.max_path_bytes]u8 = undefined;
pub var images_dir_path: []u8 = undefined;

var has_initialized_allocator = false;
var arena: std.heap.ArenaAllocator = undefined;
var allocator: std.mem.Allocator = undefined;

pub fn downloadImagesWrapper() !void {
    if (!is_downloading_images) {
        if (!has_initialized_allocator) {
            arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
            allocator = arena.allocator();
            has_initialized_allocator = true;
        }
        var thread = try std.Thread.spawn(.{}, downloadImages, .{});
        thread.detach();
    }
}

/// downloads images thanks to Allah
/// on error or completion sets the 'is_downloading_images' to false
fn downloadImages() !void {
    is_downloading_images = true;
    defer is_downloading_images = false;

    defer _ = arena.reset(.free_all);

    std.fs.makeDirAbsolute(images_dir_path) catch |e| {
        if (e != std.fs.Dir.MakeError.PathAlreadyExists) return e;
    };
    var images_dir = try std.fs.openDirAbsolute(images_dir_path, .{});
    defer images_dir.close();

    for (0..NUMBER_OF_PAGES) |i| {
        var image_file_path_buffer: [112]u8 = undefined;
        var uri_buffer: [2048]u8 = undefined;

        const image_file_path = try std.fmt.bufPrint(&image_file_path_buffer, "{d}.jpg", .{i + 1});
        const uri_str = try std.fmt.bufPrint(&uri_buffer, "https://raw.githubusercontent.com/IbrahimOuhamou/quran-images/main/nafie-warsh/azraq/tajweed-colored/{d}.jpg", .{i + 1});

        var image_file = images_dir.createFile(image_file_path, .{ .read = true }) catch |e| {
            if (e == std.fs.File.OpenError.PathAlreadyExists) continue;
            return e;
        };
        defer image_file.close();

        const uri = try std.Uri.parse(uri_str);

        var client = std.http.Client{ .allocator = allocator };
        defer client.deinit();

        var server_header_buffer: [2048]u8 = undefined;
        var request = try client.open(.GET, uri, .{ .server_header_buffer = &server_header_buffer });
        defer request.deinit();

        try request.send();
        try request.wait();

        const buffer_image = try allocator.alloc(u8, @intCast(request.response.content_length.?));

        const read_size = try request.readAll(buffer_image);
        try image_file.writeAll(buffer_image[0..read_size]);
    }
}

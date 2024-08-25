//بسم الله الرحمن الرحيم
//la ilaha illa Allah Mohammed Rassoul Allah
const std = @import("std");

var is_downloading_images = false;
const app_data_dir_path = &@import("bismi_allah.zig").app_data_dir_path;

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

    var buffer_images_dir_path: [std.fs.max_path_bytes]u8 = undefined;
    var images_dir_path: []u8 = undefined;

    {
        const res_path = try std.mem.concatWithSentinel(allocator, u8, &[_][]u8{ app_data_dir_path.*, @constCast("/warsh-images") }, 0);
        defer allocator.free(res_path);
        std.mem.copyForwards(u8, &buffer_images_dir_path, res_path);
        images_dir_path = buffer_images_dir_path[0..res_path.len];
    }

    std.fs.makeDirAbsolute(images_dir_path) catch |e| {
        if (e != std.fs.Dir.MakeError.PathAlreadyExists) return e;
    };
    var images_dir = try std.fs.openDirAbsolute(images_dir_path, .{});
    defer images_dir.close();

    std.debug.print("alhamdo li Allah will open image file\n", .{});
    var image_file = try images_dir.createFile("1-scaled.jpg", .{ .read = true });
    defer image_file.close();

    const uri = try std.Uri.parse("http://localhost:8000/1-scaled.jpg");

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

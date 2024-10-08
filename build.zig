//بسم الله الرحمن الرحيم
//la ilaha illa Allah Mohammed Rassoul Allah
const std = @import("std");
const sfml = @import("sfml");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});

    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "quran-warsh",
        .root_source_file = b.path("src/bismi_allah.zig"),
        .target = target,
        .optimize = optimize,
    });

    b.installArtifact(exe);

    const embed_quran_pictures = b.option(bool, "embed-pictures", "option to embed quran pictures default is false") orelse false;

    const compile_config = b.addOptions();
    compile_config.addOption(bool, "embed_pictures", embed_quran_pictures);
    exe.root_module.addOptions("compile_config", compile_config);

    const sfml_dep = b.dependency("sfml", .{});
    exe.root_module.addImport("sfml", sfml_dep.module("sfml"));
    if (target.result.os.tag == .windows or target.result.isMinGW()) {
        exe.linkLibC();
        // exe.linkLibCpp(); will wait to know if it is really needed

        // exe.addIncludePath(b.path("libs/CSFML/include"));
        sfml_dep.module("sfml").addIncludePath(b.path("libs/CSFML/include"));

        // exe.addObjectFile(b.path("libs/CSFML/lib/gcc/libcsfml-graphics.a"));
        exe.addObjectFile(b.path("libs/CSFML/bin/csfml-graphics.dll"));
        // exe.addSystemIncludePath(b.path("libs/CSFML/bin"));
        exe.subsystem = .Windows;
    } else {
        sfml.link(exe);
    }

    if (!embed_quran_pictures) {
        var i: usize = 0;
        var comptime_file_name_source_buffer: [std.fs.max_path_bytes]u8 = undefined;
        var comptime_file_name_destination_buffer: [std.fs.max_path_bytes]u8 = undefined;
        while (i < 604) : (i += 1) {
            const comptime_file_name_source_slice = try std.fmt.bufPrint(&comptime_file_name_source_buffer, "src/res/{d}-scaled.jpg", .{i + 1});
            const comptime_file_name_destination_slice = try std.fmt.bufPrint(&comptime_file_name_destination_buffer, "res/{d}.jpg", .{i + 1});
            b.installBinFile(comptime_file_name_source_slice, comptime_file_name_destination_slice);
        }
    }

    const run_cmd = b.addRunArtifact(exe);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const exe_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/bismi_allah.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_exe_unit_tests.step);
}

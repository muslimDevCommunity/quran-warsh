//بسم الله الرحمن الرحيم
//la ilaha illa Allah Mohammed Rassoul Allah
const std = @import("std");
const sfml = @import("sfml");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});

    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "quran-warsh",
        .root_source_file = b.path("src/bismi_allah.zig"),
        .target = target,
        .optimize = optimize,
    });

    b.installArtifact(exe);

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

const std = @import("std");

pub fn build(b: *std.Build) void {
    const optimize = b.standardOptimizeOption(.{});
    const exe = b.addExecutable(.{
        .name = "example",
        .root_module = b.createModule(.{
            .root_source_file = b.path("example.zig"),
            .optimize = optimize,
        }),
    });
    b.default_step.dependOn(&exe.step);

    // ### Libraries ###
    exe.linkSystemLibrary("vulkan");
    exe.linkSystemLibrary("dl");
    exe.linkSystemLibrary("pthread");
    exe.linkSystemLibrary("X11");
    exe.linkSystemLibrary("Xxf86vm");
    exe.linkSystemLibrary("Xrandr");
    exe.linkSystemLibrary("Xi");
    exe.linkSystemLibrary("glfw");
    exe.linkSystemLibrary("imgui");
    exe.linkSystemLibrary("cglm");
    // #################

    exe.linkLibCpp();
    b.installArtifact(exe);

    const run_exe = b.addRunArtifact(exe);
    const run_step = b.step("run", "Run the application");
    run_step.dependOn(&run_exe.step);
}

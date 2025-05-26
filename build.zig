const std = @import("std");
const zine = @import("zine");

pub fn build(b: *std.Build) !void {
    const dbus_example_mod = b.createModule(.{
        .root_source_file = b.path("content/blog/windchime-devlog-1/dbusMessage.zig"),
        .target = b.resolveTargetQuery(.{}),
    });
    dbus_example_mod.linkSystemLibrary("dbus-1", .{});
    const dbus_example = b.addExecutable(.{
        .name = "dbus_message",
        .root_module = dbus_example_mod,
        .optimize = .ReleaseSafe,
    });
    dbus_example.linkLibC();

    const website = zine.website(b, .{});
    website.step.dependOn(&dbus_example.step);
    b.getInstallStep().dependOn(&website.step);

    const serve = b.step("serve", "Start the Zine dev server");
    const run_zine = zine.serve(b, .{});
    serve.dependOn(&run_zine.step);

    const run_cmd = b.addRunArtifact(dbus_example);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run = b.step("run", "Run the example");
    run.dependOn(&run_cmd.step);
}

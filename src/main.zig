const std = @import("std");
const clap = @import("clap");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const params = comptime clap.parseParamsComptime(
        \\-h, --help           Display this help and exit.
        \\-n, --name <str>     The name of the project.
        \\-t, --type <str>     The project type (basic, web, tui).
        \\<str>...
    );

    var diag = clap.Diagnostic{};
    var res = clap.parse(clap.Help, &params, clap.parsers.default, .{
        .diagnostic = &diag,
        .allocator = allocator,
    }) catch |err| {
        diag.report(std.io.getStdErr().writer(), err) catch {};
        return err;
    };
    defer res.deinit();

    if (res.args.help != 0) {
        return clap.help(std.io.getStdOut().writer(), clap.Help, &params, .{});
    }

    const name = res.args.name orelse {
        std.io.getStdErr().writer().print("Error: Please specify a project name using --name\n", .{}) catch {};
        return;
    };
    
    const proj_type = res.args.type orelse "basic";

    try createProject(allocator, name, proj_type);
}

fn createProject(allocator: std.mem.Allocator, name: []const u8, proj_type: []const u8) !void {
    std.fs.cwd().makeDir(name) catch |err| {
        if (err == error.PathAlreadyExists) {
            std.debug.print("Error: Directory '{s}' already exists.\n", .{name});
            return;
        }
        return err;
    };

    var dir = try std.fs.cwd().openDir(name, .{});
    defer dir.close();

    try dir.makeDir("src");
    var src_dir = try dir.openDir("src", .{});
    defer src_dir.close();

    var main_file = try src_dir.createFile("main.zig", .{});
    defer main_file.close();
    
    var build_file = try dir.createFile("build.zig", .{});
    defer build_file.close();

    if (std.mem.eql(u8, proj_type, "web")) {
        try main_file.writer().writeAll(
            \\const std = @import("std");
            \\pub fn main() !void {
            \\    std.debug.print("Starting Web Server on :8080...\n", .{});
            \\}
        );
        try build_file.writer().writeAll(
            \\const std = @import("std");
            \\pub fn build(b: *std.Build) void {
            \\    const exe = b.addExecutable(.{ .name = "web-server", .root_source_file = .{ .path = "src/main.zig" }, .target = b.standardTargetOptions(.{}), .optimize = b.standardOptimizeOption(.{}) });
            \\    b.installArtifact(exe);
            \\}
        );
    } else if (std.mem.eql(u8, proj_type, "tui")) {
        try main_file.writer().writeAll(
            \\const std = @import("std");
            \\pub fn main() !void {
            \\    std.debug.print("Initializing TUI interface...\n", .{});
            \\}
        );
        try build_file.writer().writeAll(
            \\const std = @import("std");
            \\pub fn build(b: *std.Build) void {
            \\    const exe = b.addExecutable(.{ .name = "tui-app", .root_source_file = .{ .path = "src/main.zig" }, .target = b.standardTargetOptions(.{}), .optimize = b.standardOptimizeOption(.{}) });
            \\    b.installArtifact(exe);
            \\}
        );
    } else {
        try main_file.writer().writeAll(
            \\const std = @import("std");
            \\pub fn main() !void {
            \\    std.debug.print("Hello, World!\n", .{});
            \\}
        );
        try build_file.writer().writeAll(
            \\const std = @import("std");
            \\pub fn build(b: *std.Build) void {
            \\    const exe = b.addExecutable(.{ .name = "basic-project", .root_source_file = .{ .path = "src/main.zig" }, .target = b.standardTargetOptions(.{}), .optimize = b.standardOptimizeOption(.{}) });
            \\    b.installArtifact(exe);
            \\}
        );
    }

    std.debug.print("Project '{s}' ({s}) scaffolded successfully!\n", .{name, proj_type});
}

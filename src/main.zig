const std = @import("std");
const clap = @import("clap");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const params = comptime clap.parseParamsComptime(
        \\-h, --help           Display this help and exit.
        \\-n, --name <str>     The name of the project.
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

    if (res.args.name) |name| {
        try createProject(allocator, name);
    } else {
        std.io.getStdOut().writer().print("Please specify a project name using --name\n", .{}) catch {};
    }
}

fn createProject(allocator: std.mem.Allocator, name: []const u8) !void {
    // Create directory
    std.fs.cwd().makeDir(name) catch |err| {
        if (err == error.PathAlreadyExists) {
            std.debug.print("Error: Directory '{s}' already exists.\n", .{name});
            return;
        }
        return err;
    };

    var dir = try std.fs.cwd().openDir(name, .{});
    defer dir.close();

    // Create src directory
    try dir.makeDir("src");

    // Create main.zig
    const main_content = 
        \\const std = @import("std");
        \\
        \\pub fn main() !void {
        \\    std.debug.print("Hello, World!\n", .{});
        \\}
    ;
    
    var src_dir = try dir.openDir("src", .{});
    defer src_dir.close();
    
    const main_file = try src_dir.createFile("main.zig", .{});
    defer main_file.close();
    try main_file.writer().writeAll(main_content);

    // Create build.zig
    const build_content = 
        \\const std = @import("std");
        \\
        \\pub fn build(b: *std.Build) void {
        \\    const exe = b.addExecutable(.{
        \\        .name = "my-project",
        \\        .root_source_file = .{ .path = "src/main.zig" },
        \\        .target = b.standardTargetOptions(.{}),
        \\        .optimize = b.standardOptimizeOption(.{}),
        \\    });
        \\    b.installArtifact(exe);
        \\}
    ;

    const build_file = try dir.createFile("build.zig", .{});
    defer build_file.close();
    try build_file.writer().writeAll(build_content);

    std.debug.print("Project '{s}' scaffolded successfully!\n", .{name});
}

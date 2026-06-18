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
        std.debug.print("Creating project: {s}\n", .{name});
    } else {
        std.debug.print("Please specify a project name using --name\n", .{});
    }
}

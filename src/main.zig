const std = @import("std");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("Welcome to zforge - The Zig Project Scaffolder!\n", .{});
    try stdout.print("This is a placeholder for the interactive scaffolding CLI.\n", .{});
}

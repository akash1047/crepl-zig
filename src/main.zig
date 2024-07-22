const std = @import("std");
const repl = @import("repl.zig");

pub fn main() !void {
    try repl.start(std.io.getStdIn(), std.io.getStdOut(), std.io.getStdErr());
}

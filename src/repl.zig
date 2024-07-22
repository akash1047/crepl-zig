const std = @import("std");
const io = std.io;
const fs = std.fs;

const scanner = @import("scanner.zig");
const Scanner = scanner.Scanner;
const token = @import("token.zig");

pub fn start(in: fs.File, out: fs.File, err: fs.File) !void {
    var in_buffered = io.bufferedReader(in.reader());
    var out_buffered = io.bufferedWriter(out.writer());
    var err_buffered = io.bufferedWriter(err.writer());

    const reader = in_buffered.reader();
    const writer = out_buffered.writer();
    const rerror = err_buffered.writer();

    var buffer: [1024]u8 = undefined;

    while (true) {
        try rerror.print("\r> ", .{});
        try err_buffered.flush();
        const input = try reader.readUntilDelimiterOrEof(buffer[0..], '\n') orelse break;

        var sc = Scanner.new(input);
        sc.err = errorCallback;
        var sc_iter = sc.iter();

        while (sc_iter.next()) |t| {
            try writer.print("{s} = {s}\n", .{ token.string(t.tok), t.lit });
            try out_buffered.flush();
        }
    }
}

fn errorCallback(msg: []const u8) void {
    std.debug.print("Error: {s}\n", .{msg});
}

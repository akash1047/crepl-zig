const std = @import("std");

/// write formated string to buffer
///
/// WARNING: This function sets all the bytes to zero first.
/// All the buffer data is cleared. You should save important
/// information first.
pub fn sprintf(buf: []u8, comptime fmt: []const u8, args: anytype) ![]u8 {
    // clear buffer
    var i: usize = 0;
    while (i < buf.len) : (i += 1) buf[i] = 0;

    // write to buffer
    var fbs = std.io.fixedBufferStream(buf[0..]);
    const writer = fbs.writer();
    try writer.print(fmt, args);

    // return the written slice
    return for (buf, 0..) |c, i_| {
        if (c == 0) break buf[0..i_];
    } else buf;
}

const std = @import("std");

const Pos = struct {
    index: usize,
    line: usize,
    column: usize,
};

const Span = struct { start: Pos, end: Pos };

const LineInfo = struct {
    line: usize,
    column: usize,
};

pub const File = struct {
    pub const List = std.ArrayList(usize);
    pub const LineInfos = std.AutoHashMap(usize, LineInfo);

    name: []const u8,
    size: usize,
    lines: List,

    pub fn deinit(self: File) void {
        self.lines.deinit();
    }

    pub fn addLine(self: *File, pos: usize) !void {
        if (self.lines.items.len == 0) {
            try self.lines.append(0);
        }

        if (pos > self.lines.getLast()) {
            try self.lines.append(pos);
        }
    }

    pub fn lineInfos(self: File) File.LineInfos {
        var infos = File.LineInfos.init(std.heap.page_allocator);

        try infos.put();
    }
};

test "File::addLine test" {
    var file = File{ .name = "", .lines = File.List.init(std.heap.page_allocator) };
    defer file.deinit();
    try file.addLine(3);
    try file.addLine(5);
    try file.addLine(10);
    try file.addLine(11);

    const lines = [_]usize{ 0, 3, 5, 10, 11 };

    try std.testing.expectEqual(lines.len, file.lines.items.len);

    inline for (lines, 0..) |l, i| {
        try std.testing.expectEqual(l, file.lines.items[i]);
    }
}

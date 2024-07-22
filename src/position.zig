const Pos = struct {
    index: usize,
    line: usize,
    column: usize,
};

const Span = struct { start: Pos, end: Pos };

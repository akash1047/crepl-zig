const Token = @import("token.zig").Token;

pub const ExprTag = enum {
    BasicLit,
    Unary,
    Binary,
    Ident,
    FnCall,
    Subscript,
};

pub const BasicLit = struct {
    tok: Token,
    pos: usize,
    lit: []const u8,
};

pub const Unary = struct {
    op: Token,
    op_pos: usize,
    x: Expr,
};

pub const Binary = struct {
    x: Expr,
    op: Token,
    op_pos: usize,
    y: Expr,
};

pub const Ident = struct {
    pos: usize,
    name: []const u8,
};

pub const FnCall = struct {
    ident: Ident,
    open_paren_pos: usize,
    params: []const Expr,
    close_paran_pos: usize,
};

pub const Subscript = struct {
    ident: Ident,
    open_bracket_pos: usize,
    expr: Expr,
    close_bracket_pos: usize,
};

pub const Expr = union(ExprTag) {
    BasicLit: BasicLit,
    Unary: Unary,
    Binary: Binary,
    Ident: Ident,
    FnCall: FnCall,
    Subscript: Subscript,
};

pub const ExprTag = enum {
    BasicLit,
    Unary,
    Binary,
    Ident,
    FnCall,
    Subscript,
};

pub const Expr = union(ExprTag) {};

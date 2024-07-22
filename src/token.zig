const std = @import("std");
const mem = std.mem;

pub const Token = enum {
    ILLEGAL,
    EOF,

    IDENT,
    INT,
    FLOAT,
    CHAR,
    STRING,

    ASSIGN, // =
    ADD_ASSIGN, // +=
    SUB_ASSIGN, // -=
    STAR_ASSIGN, // *=
    DIV_ASSIGN, // /=
    REM_ASSIGN, // %=
    AND_ASSIGN, // &=
    OR_ASSIGN, // |=
    XOR_ASSIGN, // ^=
    LEFT_SHIFT_ASSIGN, // <<=
    RIGHT_SHIFT_ASSIGN, // >>=

    ADD, // +
    SUB, // -
    STAR, // *
    DIV, // /
    REM, // %

    TILDE, // ~
    AND, // &
    OR, // |
    XOR, // ^
    LEFT_SHIFT, // <<
    RIGHT_SHIFT, // >>

    INCREMENT, // ++
    DECREMENT, // --

    LOGICAL_NOT, // !
    LOGICAL_AND, // &&
    LOGICAL_OR, // ||

    EQUAL, // ==
    NOT_EQUAL, // !=
    LESS_THAN, // <
    GREATER_THAN, // >
    LESS_EQUAL, // <=
    GREATER_EQUAL, // >=

    PERIOD, // .
    ARROW, // ->

    TERNARY, // ?
    ELIPSIS, // ...

    OPEN_PAREN, // (
    OPEN_CURLY, // {
    OPEN_BRACKET, // [

    CLOSE_PAREN, // )
    CLOSE_CURLY, // }
    CLOSE_BRACKET, // ]

    COLON, // :
    COMMA, // ,
    SEMICOLON, // ;

    KW_AUTO, // auto
    KW_BREAK, // break
    KW_CASE, // case
    KW_CHAR, // char
    KW_CONST, // const
    KW_CONTINUE, // continue
    KW_DEFAULT, // default
    KW_DO, // do
    KW_DOUBLE, // double
    KW_ELSE, // else
    KW_ENUM, // enum
    KW_EXTERN, // extern
    KW_FLOAT, // float
    KW_FOR, // for
    KW_GOTO, // goto
    KW_IF, // if
    KW_INLINE, // inline
    KW_INT, // int
    KW_LONG, // long
    KW_REGISTER, // register
    KW_RESTRICT, // restrict
    KW_RETURN, // return
    KW_SHORT, // short
    KW_SIGNED, // signed
    KW_SIZEOF, // sizeof
    KW_STATIC, // static
    KW_STRUCT, // struct
    KW_SWITCH, // switch
    KW_TYPEDEF, // typedef
    KW_UNION, // union
    KW_UNSIGNED, // unsigned
    KW_VOID, // void
    KW_VOLATILE, // volatile
    KW_WHILE, // while

    HASH, // #
    HASH_HASH, // ##
    HASH_IF, //  #if
    HASH_ELIF, // #elif
    HASH_ELSE, // #else
    HASH_ENDIF, // #endif
    HASH_IFDEF, // #ifdef
    HASH_IFNDEF, // #ifndef
    HASH_DEFINE, // #define
    HASH_UNDEF, // #undef
    HASH_INCLUDE, // #include
    HASH_LINE, // #line
    HASH_ERROR, // #error
    HASH_PRAGMA, // #pragma
    HASH_DEFINED, // #defined
};

const KEYWORDS = [_]struct { tok: Token, lit: []const u8 }{
    .{ .tok = Token.KW_AUTO, .lit = "auto" },
    .{ .tok = Token.KW_BREAK, .lit = "break" },
    .{ .tok = Token.KW_CASE, .lit = "case" },
    .{ .tok = Token.KW_CHAR, .lit = "char" },
    .{ .tok = Token.KW_CONST, .lit = "const" },
    .{ .tok = Token.KW_CONTINUE, .lit = "continue" },
    .{ .tok = Token.KW_DEFAULT, .lit = "default" },
    .{ .tok = Token.KW_DO, .lit = "do" },
    .{ .tok = Token.KW_DOUBLE, .lit = "double" },
    .{ .tok = Token.KW_ELSE, .lit = "else" },
    .{ .tok = Token.KW_ENUM, .lit = "enum" },
    .{ .tok = Token.KW_EXTERN, .lit = "extern" },
    .{ .tok = Token.KW_FLOAT, .lit = "float" },
    .{ .tok = Token.KW_FOR, .lit = "for" },
    .{ .tok = Token.KW_GOTO, .lit = "goto" },
    .{ .tok = Token.KW_IF, .lit = "if" },
    .{ .tok = Token.KW_INLINE, .lit = "inline" },
    .{ .tok = Token.KW_INT, .lit = "int" },
    .{ .tok = Token.KW_LONG, .lit = "long" },
    .{ .tok = Token.KW_REGISTER, .lit = "register" },
    .{ .tok = Token.KW_RESTRICT, .lit = "restrict" },
    .{ .tok = Token.KW_RETURN, .lit = "return" },
    .{ .tok = Token.KW_SHORT, .lit = "short" },
    .{ .tok = Token.KW_SIGNED, .lit = "signed" },
    .{ .tok = Token.KW_SIZEOF, .lit = "sizeof" },
    .{ .tok = Token.KW_STATIC, .lit = "static" },
    .{ .tok = Token.KW_STRUCT, .lit = "struct" },
    .{ .tok = Token.KW_SWITCH, .lit = "switch" },
    .{ .tok = Token.KW_TYPEDEF, .lit = "typedef" },
    .{ .tok = Token.KW_UNION, .lit = "union" },
    .{ .tok = Token.KW_UNSIGNED, .lit = "unsigned" },
    .{ .tok = Token.KW_VOID, .lit = "void" },
    .{ .tok = Token.KW_VOLATILE, .lit = "volatile" },
    .{ .tok = Token.KW_WHILE, .lit = "while" },
};

pub fn lookup(ident: []const u8) Token {
    return inline for (KEYWORDS) |l| {
        if (mem.eql(u8, ident, l.lit)) break l.tok;
    } else Token.IDENT;
}

const PREPROCESSORS = [_]struct { tok: Token, lit: []const u8 }{
    .{ .tok = Token.HASH, .lit = "#" },
    .{ .tok = Token.HASH_HASH, .lit = "##" },
    .{ .tok = Token.HASH_IF, .lit = "#if" },
    .{ .tok = Token.HASH_ELIF, .lit = "#elif" },
    .{ .tok = Token.HASH_ELSE, .lit = "#else" },
    .{ .tok = Token.HASH_ENDIF, .lit = "#endif" },
    .{ .tok = Token.HASH_IFDEF, .lit = "#ifdef" },
    .{ .tok = Token.HASH_IFNDEF, .lit = "#ifndef" },
    .{ .tok = Token.HASH_DEFINE, .lit = "#define" },
    .{ .tok = Token.HASH_UNDEF, .lit = "#undef" },
    .{ .tok = Token.HASH_INCLUDE, .lit = "#include" },
    .{ .tok = Token.HASH_LINE, .lit = "#line" },
    .{ .tok = Token.HASH_ERROR, .lit = "#error" },
    .{ .tok = Token.HASH_PRAGMA, .lit = "#pragma" },
    .{ .tok = Token.HASH_DEFINED, .lit = "#defined" },
};

pub fn lookupPreprocessor(lit: []const u8) Token {
    return inline for (PREPROCESSORS) |p| {
        if (mem.eql(u8, lit, p.lit)) break p.tok;
    } else .ILLEGAL;
}

const TOKEN_STRING = [102][]const u8{
    "ILLEGAL",
    "EOF",

    "IDENT",
    "INT",
    "FLOAT",
    "CHAR",
    "STRING",

    "=",
    "+=",
    "-=",
    "*=",
    "/=",
    "%=",
    "&=",
    "|=",
    "^=",
    "<<=",
    ">>=",

    "+",
    "-",
    "*",
    "/",
    "%",

    "~",
    "&",
    "|",
    "^",
    "<<",
    ">>",

    "++",
    "--",

    "!",
    "&&",
    "||",

    "==",
    "!=",
    "<",
    ">",
    "<=",
    ">=",

    ".",
    "->",

    "?",
    "...",

    "(",
    "{",
    "[",

    ")",
    "}",
    "]",

    ":",
    ",",
    ";",

    "auto",
    "break",
    "case",
    "char",
    "const",
    "continue",
    "default",
    "do",
    "double",
    "else",
    "enum",
    "extern",
    "float",
    "for",
    "goto",
    "if",
    "inline",
    "int",
    "long",
    "register",
    "restrict",
    "return",
    "short",
    "signed",
    "sizeof",
    "static",
    "struct",
    "switch",
    "typedef",
    "union",
    "unsigned",
    "void",
    "volatile",
    "while",

    "#",
    "##",
    "#if",
    "#elif",
    "#else",
    "#endif",
    "#ifdef",
    "#ifndef",
    "#define",
    "#undef",
    "#include",
    "#line",
    "#error",
    "#pragma",
    "#defined",
};

pub fn string(t: Token) []const u8 {
    return TOKEN_STRING[@intFromEnum(t)];
}

const testing = @import("std").testing;

test "token::string" {
    const tests = [_]struct {
        t: Token,
        s: []const u8,
    }{
        .{ .t = Token.ILLEGAL, .s = "ILLEGAL" },
        .{ .t = Token.EOF, .s = "EOF" },
        .{ .t = Token.IDENT, .s = "IDENT" },
        .{ .t = Token.INT, .s = "INT" },
        .{ .t = Token.FLOAT, .s = "FLOAT" },
        .{ .t = Token.CHAR, .s = "CHAR" },
        .{ .t = Token.STRING, .s = "STRING" },

        .{ .t = Token.ASSIGN, .s = "=" },
        .{ .t = Token.ADD_ASSIGN, .s = "+=" },
        .{ .t = Token.SUB_ASSIGN, .s = "-=" },
        .{ .t = Token.STAR_ASSIGN, .s = "*=" },
        .{ .t = Token.DIV_ASSIGN, .s = "/=" },
        .{ .t = Token.REM_ASSIGN, .s = "%=" },
        .{ .t = Token.AND_ASSIGN, .s = "&=" },
        .{ .t = Token.OR_ASSIGN, .s = "|=" },
        .{ .t = Token.XOR_ASSIGN, .s = "^=" },
        .{ .t = Token.LEFT_SHIFT_ASSIGN, .s = "<<=" },
        .{ .t = Token.RIGHT_SHIFT_ASSIGN, .s = ">>=" },

        .{ .t = Token.ADD, .s = "+" },
        .{ .t = Token.SUB, .s = "-" },
        .{ .t = Token.STAR, .s = "*" },
        .{ .t = Token.DIV, .s = "/" },
        .{ .t = Token.REM, .s = "%" },

        .{ .t = Token.TILDE, .s = "~" },
        .{ .t = Token.AND, .s = "&" },
        .{ .t = Token.OR, .s = "|" },
        .{ .t = Token.XOR, .s = "^" },
        .{ .t = Token.LEFT_SHIFT, .s = "<<" },
        .{ .t = Token.RIGHT_SHIFT, .s = ">>" },

        .{ .t = Token.INCREMENT, .s = "++" },
        .{ .t = Token.DECREMENT, .s = "--" },

        .{ .t = Token.LOGICAL_NOT, .s = "!" },
        .{ .t = Token.LOGICAL_AND, .s = "&&" },
        .{ .t = Token.LOGICAL_OR, .s = "||" },

        .{ .t = Token.EQUAL, .s = "==" },
        .{ .t = Token.NOT_EQUAL, .s = "!=" },
        .{ .t = Token.LESS_THAN, .s = "<" },
        .{ .t = Token.GREATER_THAN, .s = ">" },
        .{ .t = Token.LESS_EQUAL, .s = "<=" },
        .{ .t = Token.GREATER_EQUAL, .s = ">=" },

        .{ .t = Token.PERIOD, .s = "." },
        .{ .t = Token.ARROW, .s = "->" },

        .{ .t = Token.TERNARY, .s = "?" },
        .{ .t = Token.ELIPSIS, .s = "..." },

        .{ .t = Token.OPEN_PAREN, .s = "(" },
        .{ .t = Token.OPEN_CURLY, .s = "{" },
        .{ .t = Token.OPEN_BRACKET, .s = "[" },

        .{ .t = Token.CLOSE_PAREN, .s = ")" },
        .{ .t = Token.CLOSE_CURLY, .s = "}" },
        .{ .t = Token.CLOSE_BRACKET, .s = "]" },

        .{ .t = Token.COLON, .s = ":" },
        .{ .t = Token.COMMA, .s = "," },
        .{ .t = Token.SEMICOLON, .s = ";" },

        .{ .t = Token.KW_AUTO, .s = "auto" },
        .{ .t = Token.KW_BREAK, .s = "break" },
        .{ .t = Token.KW_CASE, .s = "case" },
        .{ .t = Token.KW_CHAR, .s = "char" },
        .{ .t = Token.KW_CONST, .s = "const" },
        .{ .t = Token.KW_CONTINUE, .s = "continue" },
        .{ .t = Token.KW_DEFAULT, .s = "default" },
        .{ .t = Token.KW_DO, .s = "do" },
        .{ .t = Token.KW_DOUBLE, .s = "double" },
        .{ .t = Token.KW_ELSE, .s = "else" },
        .{ .t = Token.KW_ENUM, .s = "enum" },
        .{ .t = Token.KW_EXTERN, .s = "extern" },
        .{ .t = Token.KW_FLOAT, .s = "float" },
        .{ .t = Token.KW_FOR, .s = "for" },
        .{ .t = Token.KW_GOTO, .s = "goto" },
        .{ .t = Token.KW_IF, .s = "if" },
        .{ .t = Token.KW_INLINE, .s = "inline" },
        .{ .t = Token.KW_INT, .s = "int" },
        .{ .t = Token.KW_LONG, .s = "long" },
        .{ .t = Token.KW_REGISTER, .s = "register" },
        .{ .t = Token.KW_RESTRICT, .s = "restrict" },
        .{ .t = Token.KW_RETURN, .s = "return" },
        .{ .t = Token.KW_SHORT, .s = "short" },
        .{ .t = Token.KW_SIGNED, .s = "signed" },
        .{ .t = Token.KW_SIZEOF, .s = "sizeof" },
        .{ .t = Token.KW_STATIC, .s = "static" },
        .{ .t = Token.KW_STRUCT, .s = "struct" },
        .{ .t = Token.KW_SWITCH, .s = "switch" },
        .{ .t = Token.KW_TYPEDEF, .s = "typedef" },
        .{ .t = Token.KW_UNION, .s = "union" },
        .{ .t = Token.KW_UNSIGNED, .s = "unsigned" },
        .{ .t = Token.KW_VOID, .s = "void" },
        .{ .t = Token.KW_VOLATILE, .s = "volatile" },
        .{ .t = Token.KW_WHILE, .s = "while" },

        .{ .t = Token.HASH, .s = "#" },
        .{ .t = Token.HASH_HASH, .s = "##" },
        .{ .t = Token.HASH_IF, .s = "#if" },
        .{ .t = Token.HASH_ELIF, .s = "#elif" },
        .{ .t = Token.HASH_ELSE, .s = "#else" },
        .{ .t = Token.HASH_ENDIF, .s = "#endif" },
        .{ .t = Token.HASH_IFDEF, .s = "#ifdef" },
        .{ .t = Token.HASH_IFNDEF, .s = "#ifndef" },
        .{ .t = Token.HASH_DEFINE, .s = "#define" },
        .{ .t = Token.HASH_UNDEF, .s = "#undef" },
        .{ .t = Token.HASH_INCLUDE, .s = "#include" },
        .{ .t = Token.HASH_LINE, .s = "#line" },
        .{ .t = Token.HASH_ERROR, .s = "#error" },
        .{ .t = Token.HASH_PRAGMA, .s = "#pragma" },
        .{ .t = Token.HASH_DEFINED, .s = "#defined" },
    };

    inline for (tests) |t| {
        try testing.expectEqualStrings(t.s, string(t.t));
    }
}

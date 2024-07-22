const format = @import("format.zig");
const std = @import("std");
const ascii = std.ascii;

const token = @import("token.zig");
const Token = token.Token;

pub const Errorfn = *const fn ([]const u8) void;

pub const TokenPack = struct {
    tok: Token,
    lit: []const u8,
};

pub const Iter = struct {
    sc: *Scanner,

    pub fn next(self: *Iter) ?TokenPack {
        const t = self.sc.scan();
        if (t.tok == .EOF) return null;
        return t;
    }
};

pub const Scanner = struct {
    source: []const u8,
    position: usize,
    read_position: usize,
    ch: u8,
    err: ?Errorfn = null,
    last_error: [256]u8 = undefined,

    pub fn new(source: []const u8) Scanner {
        return .{
            .source = source,
            .position = 0,
            .read_position = 1,
            .ch = if (source.len > 0) source[0] else 0,
        };
    }

    pub fn iter(self: *Scanner) Iter {
        return .{ .sc = self };
    }

    fn next(self: *Scanner) void {
        if (self.read_position < self.source.len) {
            self.position = self.read_position;
            self.ch = self.source[self.read_position];
            self.read_position += 1;
        } else {
            self.position = self.source.len;
            self.ch = 0;
        }
    }

    fn peek(self: *const Scanner) u8 {
        return if (self.read_position < self.source.len)
            self.source[self.read_position]
        else
            0;
    }

    fn scanError(self: *Scanner, comptime fmt: []const u8, args: anytype) void {
        if (self.err) |err| {
            const err_msg = format.sprintf(self.last_error[0..], fmt, args) catch self.last_error[0..];
            err(err_msg);
        }
    }

    fn match(self: *Scanner, ch: u8) bool {
        if (self.ch == ch) {
            self.next();
            return true;
        }
        return false;
    }

    fn matchIf(self: *Scanner, f: fn (u8) bool) bool {
        if (f(self.ch)) {
            self.next();
            return true;
        }
        return false;
    }

    fn expect(self: *Scanner, def: Token, alt_ch: u8, alt: Token) Token {
        if (self.peek() == alt_ch) {
            self.next();
            return alt;
        }
        return def;
    }

    fn expect2(self: *Scanner, def: Token, ch1: u8, alt1: Token, ch2: u8, alt2: Token) Token {
        const peek_ch = self.peek();

        if (peek_ch == ch1) {
            self.next();
            return alt1;
        }

        if (peek_ch == ch2) {
            self.next();
            return alt2;
        }

        return def;
    }

    fn scanIdent(self: *Scanner) []const u8 {
        const mark = self.position;
        while (ascii.isAlphanumeric(self.ch)) : (self.next()) {}
        return self.source[mark..self.position];
    }

    fn scanChar(self: *Scanner, tok: *Token) []const u8 {
        const mark = self.position;
        tok.* = .CHAR;
        self.next(); // consume the starting quote '

        if (self.match('\\')) {
            switch (self.ch) {
                'n', 't', 'r', '\'', '\\', 'e' => {},
                else => {
                    tok.* = .ILLEGAL;
                    self.scanError("unknown escape character `{c}`", .{self.ch});
                },
            }

            self.next(); // consume the escape character
        } else if (self.ch == '\'') {
            tok.* = .ILLEGAL;
            self.scanError("no character in betwen quotes `''`", .{});
        } else {
            self.next(); // consume the char byte
        }

        if (!self.match('\'')) {
            tok.* = .ILLEGAL;
            self.scanError("expected closing quote `'` got {c}", .{self.ch});
        }
        return self.source[mark..self.position];
    }

    fn scanString(self: *Scanner, tok: *Token) []const u8 {
        const mark = self.position;
        tok.* = .STRING;
        self.next(); // consume starting double quote "

        while (self.ch != 0 or self.ch != '\"') : (self.next()) {
            if (self.match('\\')) {
                switch (self.ch) {
                    '\n', '\\', '\"' => {},
                    else => {
                        tok.* = .ILLEGAL;
                        self.scanError("unknown escape character `{c}`", .{self.ch});
                    },
                }

                self.next(); // consume the escape character
            }
        }

        if (!self.match('\"')) {
            tok.* = .ILLEGAL;
            self.scanError("string literal has no closing quote \"", .{});
        }

        return self.source[mark..self.position];
    }

    fn scanIntOrFloat(self: *Scanner, tok: *Token) []const u8 {
        const mark = self.position;

        if (!ascii.isDigit(self.ch)) @panic("number starts with non digit");

        tok.* = Token.INT;
        while (ascii.isDigit(self.ch)) : (self.next()) {}

        // float
        if (self.match('.')) {
            tok.* = Token.FLOAT;
            while (ascii.isDigit(self.ch)) : (self.next()) {}

            // exponent
            if (self.match('e') or self.match('E')) {
                _ = self.match('-') or self.match('+');

                if (!ascii.isDigit(self.ch)) {
                    tok.* = .ILLEGAL;
                    self.scanError("exponent has no digits: '{s}'", .{self.source[mark..self.position]});
                } else {
                    while (ascii.isDigit(self.ch)) : (self.next()) {}
                }
            }
            _ = self.match('f') or self.match('F');
        }

        { // errors
        }

        return self.source[mark..self.position];
    }

    pub fn scan(self: *Scanner) TokenPack {
        // skip whitespace
        while (ascii.isWhitespace(self.ch)) : (self.next()) {}

        var tok: Token = undefined;

        if (ascii.isAlphabetic(self.ch)) {
            const lit = self.scanIdent();
            tok = token.lookup(lit);
            return .{ .tok = tok, .lit = lit };
        }

        if (ascii.isDigit(self.ch)) {
            const lit = self.scanIntOrFloat(&tok);
            return .{ .tok = tok, .lit = lit };
        }

        const mark = self.position;

        tok = switch (self.ch) {
            '+' => self.expect2(.ADD, '+', .INCREMENT, '=', .ADD_ASSIGN),

            '-' => switch (self.peek()) {
                '-' => blk: {
                    self.next();
                    break :blk .DECREMENT;
                },

                '=' => blk: {
                    self.next();
                    break :blk .SUB_ASSIGN;
                },

                '>' => blk: {
                    self.next();
                    break :blk .ARROW;
                },

                else => .SUB,
            },

            '\'' => {
                const lit = self.scanChar(&tok);
                return .{ .tok = tok, .lit = lit };
            },

            '\"' => {
                const lit = self.scanString(&tok);
                return .{ .tok = tok, .lit = lit };
            },

            0 => return .{ .tok = Token.EOF, .lit = "" },
            else => Token.ILLEGAL,
        };

        self.next();

        return .{ .tok = tok, .lit = self.source[mark..self.position] };
    }
};

const testing = std.testing;

test "Scanner::scan" {
    const tests = [_]struct {
        t: Token,
        s: []const u8,
    }{
        .{ .t = .IDENT, .s = "abcd1234" },
        .{ .t = .INT, .s = "1234567890" },
        .{ .t = .FLOAT, .s = "123.456e-789f" },
        .{ .t = .CHAR, .s = "'a'" },
        // .{ .t = .STRING, .s = "\"A string literal.\"" },

        .{ .t = .ASSIGN, .s = "=" },
        .{ .t = .ADD_ASSIGN, .s = "+=" },
        .{ .t = .SUB_ASSIGN, .s = "-=" },
        .{ .t = .STAR_ASSIGN, .s = "*=" },
        .{ .t = .DIV_ASSIGN, .s = "/=" },
        .{ .t = .REM_ASSIGN, .s = "%=" },
        .{ .t = .AND_ASSIGN, .s = "&=" },
        .{ .t = .OR_ASSIGN, .s = "|=" },
        .{ .t = .XOR_ASSIGN, .s = "^=" },
        .{ .t = .LEFT_SHIFT_ASSIGN, .s = "<<=" },
        .{ .t = .RIGHT_SHIFT_ASSIGN, .s = ">>=" },

        .{ .t = .ADD, .s = "+" },
        .{ .t = .SUB, .s = "-" },
        .{ .t = .STAR, .s = "*" },
        .{ .t = .DIV, .s = "/" },
        .{ .t = .REM, .s = "%" },

        .{ .t = .TILDE, .s = "~" },
        .{ .t = .AND, .s = "&" },
        .{ .t = .OR, .s = "|" },
        .{ .t = .XOR, .s = "^" },
        .{ .t = .LEFT_SHIFT, .s = "<<" },
        .{ .t = .RIGHT_SHIFT, .s = ">>" },

        .{ .t = .INCREMENT, .s = "++" },
        .{ .t = .DECREMENT, .s = "--" },

        .{ .t = .LOGICAL_NOT, .s = "!" },
        .{ .t = .LOGICAL_AND, .s = "&&" },
        .{ .t = .LOGICAL_OR, .s = "||" },

        .{ .t = .EQUAL, .s = "==" },
        .{ .t = .NOT_EQUAL, .s = "!=" },
        .{ .t = .LESS_THAN, .s = "<" },
        .{ .t = .GREATER_THAN, .s = ">" },
        .{ .t = .LESS_EQUAL, .s = "<=" },
        .{ .t = .GREATER_EQUAL, .s = ">=" },

        .{ .t = .PERIOD, .s = "." },
        .{ .t = .ARROW, .s = "->" },

        .{ .t = .TERNARY, .s = "?" },
        .{ .t = .ELIPSIS, .s = "..." },

        .{ .t = .OPEN_PAREN, .s = "(" },
        .{ .t = .OPEN_CURLY, .s = "{" },
        .{ .t = .OPEN_BRACKET, .s = "[" },

        .{ .t = .CLOSE_PAREN, .s = ")" },
        .{ .t = .CLOSE_CURLY, .s = "}" },
        .{ .t = .CLOSE_BRACKET, .s = "]" },

        .{ .t = .COLON, .s = ":" },
        .{ .t = .COMMA, .s = "," },
        .{ .t = .SEMICOLON, .s = ";" },

        .{ .t = .KW_AUTO, .s = "auto" },
        .{ .t = .KW_BREAK, .s = "break" },
        .{ .t = .KW_CASE, .s = "case" },
        .{ .t = .KW_CHAR, .s = "char" },
        .{ .t = .KW_CONST, .s = "const" },
        .{ .t = .KW_CONTINUE, .s = "continue" },
        .{ .t = .KW_DEFAULT, .s = "default" },
        .{ .t = .KW_DO, .s = "do" },
        .{ .t = .KW_DOUBLE, .s = "double" },
        .{ .t = .KW_ELSE, .s = "else" },
        .{ .t = .KW_ENUM, .s = "enum" },
        .{ .t = .KW_EXTERN, .s = "extern" },
        .{ .t = .KW_FLOAT, .s = "float" },
        .{ .t = .KW_FOR, .s = "for" },
        .{ .t = .KW_GOTO, .s = "goto" },
        .{ .t = .KW_IF, .s = "if" },
        .{ .t = .KW_INLINE, .s = "inline" },
        .{ .t = .KW_INT, .s = "int" },
        .{ .t = .KW_LONG, .s = "long" },
        .{ .t = .KW_REGISTER, .s = "register" },
        .{ .t = .KW_RESTRICT, .s = "restrict" },
        .{ .t = .KW_RETURN, .s = "return" },
        .{ .t = .KW_SHORT, .s = "short" },
        .{ .t = .KW_SIGNED, .s = "signed" },
        .{ .t = .KW_SIZEOF, .s = "sizeof" },
        .{ .t = .KW_STATIC, .s = "static" },
        .{ .t = .KW_STRUCT, .s = "struct" },
        .{ .t = .KW_SWITCH, .s = "switch" },
        .{ .t = .KW_TYPEDEF, .s = "typedef" },
        .{ .t = .KW_UNION, .s = "union" },
        .{ .t = .KW_UNSIGNED, .s = "unsigned" },
        .{ .t = .KW_VOID, .s = "void" },
        .{ .t = .KW_VOLATILE, .s = "volatile" },
        .{ .t = .KW_WHILE, .s = "while" },

        .{ .t = .HASH, .s = "#" },
        .{ .t = .HASH_HASH, .s = "##" },
        .{ .t = .HASH_IF, .s = "#if" },
        .{ .t = .HASH_ELIF, .s = "elif" },
        .{ .t = .HASH_ELSE, .s = "#else" },
        .{ .t = .HASH_ENDIF, .s = "#endif" },
        .{ .t = .HASH_IFDEF, .s = "#ifdef" },
        .{ .t = .HASH_IFNDEF, .s = "#ifndef" },
        .{ .t = .HASH_DEFINE, .s = "#define" },
        .{ .t = .HASH_UNDEF, .s = "#undef" },
        .{ .t = .HASH_INCLUDE, .s = "#include" },
        .{ .t = .HASH_LINE, .s = "#line" },
        .{ .t = .HASH_ERROR, .s = "#error" },
        .{ .t = .HASH_PRAGMA, .s = "#pragma" },
        .{ .t = .HASH_DEFINED, .s = "#defined" },
    };

    comptime var len: usize = 0;
    inline for (tests) |t| {
        len += t.s.len;
    }
    len += tests.len;

    var source: [len]u8 = undefined;

    comptime var i: usize = 0;

    inline for (tests) |t| {
        std.mem.copyForwards(u8, source[i..], t.s ++ " ");
        i += t.s.len + 1;
    }

    comptime var test_count: usize = 0;

    var sc = Scanner.new(&source);
    errdefer std.debug.print("test[{}/{}] failed.\nsource[{}]: {s}", .{ test_count + 1, tests.len, source.len, source });

    inline for (tests, 0..) |tt, ti| {
        test_count = ti;
        const t = sc.scan();

        try testing.expectEqual(tt.t, t.tok);
        try testing.expectEqualStrings(tt.s, t.lit);
    }
}

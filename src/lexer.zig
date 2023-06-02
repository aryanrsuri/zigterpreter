const std = @import("std");
/// Token enum to define all Tokens and keyword identifiers
/// Note that all are define void expect for ident and int
/// However this could be change to explicitely define
/// The byte value of each token
pub const Token = union(enum) {
    identifier: []const u8,
    integer: []const u8,
    illegal,
    eof,
    assign,
    plus,
    minus,
    bang,
    asterisk,
    fslash,
    comma,
    semicolon,
    lparen,
    rparen,
    lbrace,
    rbrace,
    ltag,
    rtag,
    equal,
    not_equal,
    function,
    let,
    true_op,
    false_op,
    if_op,
    else_op,
    return_op,

    fn keyword(identifier: []const u8) ?Token {
        const map = std.ComptimeStringMap(Token, .{
            .{ "let", .let },
            .{ "fn", .function },
            .{ "true", .true_op },
            .{ "false", .false_op },
            .{ "if", .if_op },
            .{ "else", .else_op },
            .{ "return ", .return_op },
        });
        return map.get(identifier);
    }

    const tag = std.meta.Tag(Token);
};

fn is_letter(char: u8) bool {
    return std.ascii.isAlphabetic(char) or char == '_';
}

fn is_integer(char: u8) bool {
    return std.ascii.isDigit(char);
}

pub const Lexer = struct {
    input: []const u8,
    curr_position: u8 = 0,
    next_position: u8 = 0,
    curr_char: u8 = 0,

    pub fn init(input: []const u8) @This() {
        var lexer = @This(){
            .input = input,
        };
        lexer.read_char();
        return lexer;
    }

    pub fn read_char(self: *@This()) void {
        if (self.next_position >= self.input.len) {
            self.curr_char = 0;
        } else {
            self.curr_char = self.input[self.next_position];
        }
        self.curr_position = self.next_position;
        self.next_position += 1;
    }

    pub fn read_identifier(self: *@This()) []const u8 {
        const position = self.curr_position;
        while (is_letter(self.curr_char)) {
            self.read_char();
        }

        return self.input[position..self.curr_position];
    }

    pub fn read_integer(self: *@This()) []const u8 {
        const position = self.curr_position;
        while (is_integer(self.curr_char)) {
            self.read_char();
        }

        return self.input[position..self.curr_position];
    }
    pub fn next_token(self: *@This()) Token {
        self.skip_whitespace();
        const token: Token = switch (self.curr_char) {
            '=' => blk: {
                if (self.peek_char() == '=') {
                    self.read_char();
                    break :blk .equal;
                } else {
                    break :blk .assign;
                }
            },
            '!' => blk: {
                if (self.peek_char() == '=') {
                    self.read_char();
                    break :blk .not_equal;
                } else {
                    break :blk .bang;
                }
            },
            ';' => .semicolon,
            '(' => .lparen,
            ')' => .rparen,
            ',' => .comma,
            '+' => .plus,
            '-' => .minus,
            '*' => .asterisk,
            '/' => .fslash,
            '{' => .lbrace,
            '}' => .rbrace,
            '<' => .ltag,
            '>' => .rtag,
            'a'...'z', 'A'...'Z', '_' => {
                const literal = self.read_identifier();
                if (Token.keyword(literal)) |token| {
                    return token;
                }
                return .{ .identifier = literal };
            },
            '0'...'9' => {
                const integer = self.read_integer();
                return .{ .integer = integer };
            },
            0 => .eof,
            else => .illegal,
        };
        self.read_char();
        return token;
    }

    fn peek_char(self: *@This()) u8 {
        if (self.next_position >= self.input.len) {
            return 0;
        } else {
            return self.input[self.next_position];
        }
    }

    pub fn skip_whitespace(self: *@This()) void {
        while (std.ascii.isWhitespace(self.curr_char)) {
            self.read_char();
        }
    }
};

test "lexer" {
    const test_string = "let five == if fn(x / *y);";
    var lexer = Lexer.init(test_string);
    const tokens = [_]Token{
        .let,
        .{ .identifier = "five" },
        .equal,
        .if_op,
        .function,
        .lparen,
        .{ .identifier = "x" },
        .fslash,
        .asterisk,
        .{ .identifier = "y" },
        .rparen,
        .semicolon,
    };

    for (tokens) |tok| {
        const toktok = lexer.next_token();
        const toktag = std.meta.activeTag(toktok);
        std.debug.print("\ntest {} :: lexer: {} :: tag {}\n", .{ tok, toktok, toktag });
        try std.testing.expectEqualDeep(tok, toktok);
    }
}

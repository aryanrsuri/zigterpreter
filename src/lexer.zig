//! Defines the lexer file
//! implements the tokenising and lexer struct

const std = @import("std");

/// Token enum to define all Tokens and keyword identifiers
/// Note that all are define void expect for ident and int
/// However this could be change to explicitely define
/// The byte value of each token
pub const token_types = enum {
    identifier,
    integer,
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
};

pub const Token = struct {
    kind: token_types = .illegal,
    literal: []const u8 = "",
    pub fn init(kind: token_types, literal: []const u8) Token {
        return Token{
            .kind = kind,
            .literal = literal,
        };
    }

    pub fn keyword(identifier: []const u8) ?token_types {
        const map = std.ComptimeStringMap(token_types, .{
            .{ "let", .let },
            .{ "fn", .function },
            .{ "true", .true_op },
            .{ "false", .false_op },
            .{ "if", .if_op },
            .{ "else", .else_op },
            .{ "return", .return_op },
        });
        return map.get(identifier);
    }
};

/// returns true is char false if not
fn is_letter(char: u8) bool {
    return std.ascii.isAlphabetic(char) or char == '_';
}

/// returns true if digit false if not
fn is_integer(char: u8) bool {
    return std.ascii.isDigit(char);
}
/// defines lexer struct and its methods
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
        const sch: []const u8 = self.curr_string();
        var token = Token.init(.illegal, sch);
        switch (self.curr_char) {
            '=' => {
                if (self.peek_char() == '=') {
                    token.kind = .equal;
                    token.literal = self.input[self.curr_position..self.next_position];
                    self.read_char();
                } else {
                    token.kind = .assign;
                }
            },
            '!' => {
                if (self.peek_char() == '=') {
                    token.kind = .not_equal;
                    token.literal = self.input[self.curr_position..self.next_position];
                    self.read_char();
                } else {
                    token.kind = .bang;
                }
            },
            ';' => token.kind = .semicolon,
            '(' => token.kind = .lparen,
            ')' => token.kind = .rparen,
            ',' => token.kind = .comma,
            '+' => token.kind = .plus,
            '-' => token.kind = .minus,
            '*' => token.kind = .asterisk,
            '/' => token.kind = .fslash,
            '{' => token.kind = .lbrace,
            '}' => token.kind = .rbrace,
            '<' => token.kind = .ltag,
            '>' => token.kind = .rtag,
            'a'...'z', 'A'...'Z', '_' => {
                token.literal = self.read_identifier();
                if (Token.keyword(token.literal)) |tok| {
                    token.kind = tok;
                    return token;
                }
                token.kind = .identifier;
                return token;
            },
            '0'...'9' => {
                token.literal = self.read_integer();
                token.kind = .integer;
                return token;
            },
            0 => token.kind = .eof,
            else => token.kind = .illegal,
        }
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

    fn curr_string(self: *@This()) []const u8 {
        if (self.curr_position >= self.input.len) {
            return "0";
        } else {
            return self.input[self.curr_position..self.next_position];
        }
    }

    pub fn skip_whitespace(self: *@This()) void {
        while (std.ascii.isWhitespace(self.curr_char)) {
            self.read_char();
        }
    }
};

test "lexer" {
    const test_string = "let f = 3;";
    var lexer = Lexer.init(test_string);
    const tokens = [_]Token{
        Token.init(.let, "let"),
        Token.init(.identifier, "f"),
        Token.init(.assign, "="),
        Token.init(.integer, "3"),
        Token.init(.semicolon, ";"),
    };

    for (tokens) |tok| {
        const toktok = lexer.next_token();
        std.debug.print("\ntest {} ||| lexer: {} \n", .{ tok, toktok });
        try std.testing.expectEqualDeep(tok, toktok);
    }
}

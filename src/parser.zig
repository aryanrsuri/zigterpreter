const std = @import("std");
const l = @import("lexer.zig");
const ast = @import("ast.zig");
const Token = l.Token;
const Lexer = l.Lexer;
const Program = ast.Program;
const Statement = ast.Statement;
const Expression = ast.Expression;
const Identifier = ast.Identifier;

const Parser = struct {
    const Self = @This();
    allocator: std.mem.Allocator,
    lexer: *Lexer,
    curr_token: Token = undefined,
    peek_token: Token = undefined,
    parse_err: std.ArrayList([]const u8),

    pub fn init(allocator: std.mem.Allocator, lexer: *Lexer) Self {
        var parser = Self{
            .lexer = lexer,
            .allocator = allocator,
            .parse_err = std.ArrayList([]const u8).init(allocator),
        };

        parser.next_token();
        parser.next_token();
        return parser;
    }

    // pub fn deinit()

    pub fn next_token(self: *Self) void {
        self.curr_token = self.peek_token;
        self.peek_token = self.lexer.next_token();
    }

    pub fn parse_program(self: *Self) !Program {
        var program: Program = Program.init(self.allocator);
        while (self.curr_token.kind != .eof) {
            var stmt = self.parse_statement();
            if (stmt) |s| {
                try program.statements.append(s);
            }
            self.next_token();
        }

        return program;
    }

    fn parse_statement(self: *Self) ?Statement {
        return switch (self.curr_token.kind) {
            .let => self.parse_let_statement(),
            else => null,
        };
    }

    // statement parsing

    /// parse let : self -> let_statement
    fn parse_let_statement(self: *Self) ?Statement {
        var letstate: Statement.let_statement = Statement.let_statement{
            .token = self.curr_token,
            .ident = Token{},
            .value = null,
        };

        if (!self.expect_peek(.identifier)) {
            return null;
        }

        letstate.ident = self.curr_token;
        if (!self.expect_peek(.assign)) {
            return null;
        }

        // letstate.ident = self.lexer.read_identifier();
        return Statement{ .let_statement = letstate };
    }

    fn expect_peek(self: *Self, tok: l.token_types) bool {
        if (self.peek_token.kind == tok) {
            self.next_token();
            return true;
        } else {
            return false;
        }
    }
};

test "let statements" {
    const input =
        \\let  e=;
        \\let y = 10;
        \\let foobar = bar + 10;
        \\let foobar = add(x, y) + 10;
    ;

    var lex = Lexer.init(input);
    var parser = Parser.init(std.testing.allocator, &lex);
    var prog: Program = try parser.parse_program();
    defer prog.deinit();
    // defer parser.deinit();
    // try checkParseErrors(parser);
    try std.testing.expect(prog.statements.items.len == 4);

    const expected_idents = [_]ast.Identifier{
        Identifier.init(Token.init(.identifier, "e")),
        Identifier.init(Token.init(.identifier, "y")),
        Identifier.init(Token.init(.identifier, "foobar")),
        Identifier.init(Token.init(.identifier, "foobar")),
    };

    for (expected_idents, 0..) |ident, i| {
        const statement = prog.statements.items[i];
        var ls = statement.let_statement;
        const literal = ls.ident.literal;

        // std.debug.print("\n\nIDENT : {}\n", .{ident});
        // std.debug.print("STATEMENT {}\n", .{statement});
        // std.debug.print("LET STATE: {}\n", .{ls});

        try std.testing.expect(ls.token.kind == .let);

        // Compare token literal
        std.testing.expect(std.mem.eql(u8, ident.value, literal)) catch {
            std.debug.print("Expected: {s}, got: {s}\n", .{ ident.value, literal });
            return error.ValueMismatch;
        };
    }
    // }
}

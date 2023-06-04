const std = @import("std");
const l = @import("lexer.zig");
const ast = @import("ast.zig");
const Token = l.Token;
const Lexer = l.Lexer;
const Progam = ast.Program;

const Parser = struct {
    const Self = @This();
    allocator: std.mem.Allocator,
    lexer: *Lexer,
    curr_token: Token = undefined,
    peek_token: Token = undefined,

    pub fn init(allocator: std.mem.Allocator, lexer: *Lexer) Self {
        var parser = .{
            .lexer = lexer,
            .allocator = allocator,
        };

        parser.next_token();
        parser.next_token();
        return parser;
    }

    pub fn next_token(self: *Self) !void {
        self.curr_token = self.peek_token;
        self.peek_token = self.lexer.next_token();
    }

    fn parse_program(self: *Self) !*ast.Program {
        _ = self;
        return null;
    }
};

test "let statements" {
    const input =
        \\let x = 5;
        \\let y = 10;
        \\let foobar = bar + 10;
        \\let foobar = add(x, y) + 10;
    ;

    var lex = Lexer.init(input);
    // var parser = Parser.init(std.testing.allocator, &lex);

    // var prog: Progam = try parser.parse_program();
    // var prog: Program = try parser.parseProgram();
    // defer prog.deinit();
    // defer parser.deinit();

    // try checkParseErrors(parser);

    // try std.testing.expect(prog.statements.items.len == 4);

    const expected_idents = [_]ast.Identifier{
        ast.Identifier.init(Token{ .identifier = "x" }),
        ast.Identifier.init(Token{ .identifier = "y" }),
        ast.Identifier.init(Token{ .identifier = "foobar" }),
        ast.Identifier.init(Token{ .identifier = "foobar" }),
    };

    for (expected_idents, 0..) |ident, i| {
        // const statement = prog.statements.items[i];
        // var ls = statement.let_statement;

        _ = ident;
        _ = i;
        std.debug.print("{}", .{lex.next_token()});
        // std.debug.print("{}\n", .{statement});

        // try std.testing.expect(ls.token.kind == .LET);
        //
        // // Compare token literal
        // std.testing.expect(std.mem.eql(u8, ident.value, literal)) catch {
        //     std.debug.print("Expected: {s}, got: {s}\n", .{ ident.value, literal });
        //     return TestError.CompareFailed;
        // };
    }
}

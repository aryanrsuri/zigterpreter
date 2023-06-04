const std = @import("std");
const lexer = @import("lexer.zig");
const Token = lexer.Token;

pub const Node = union(enum) {
    const self = @This();
    expression: Expression,
    statement: Statement,
};

pub const Identifier = struct {
    const Self = @This();
    token: Token,

    pub fn init(token: Token) Self {
        return .{
            .token = token,
        };
    }
};

pub const Expression = union(enum) {
    indentifier: Identifier,
};

pub const Statement = union(enum) {
    let_statement: let_statement,

    pub const let_statement = struct {
        const Self = @This();
        // token serves also as a name
        token: Token,
        ident: Token,
        value: ?Expression,

        pub fn print(self: *Self) !void {
            const let = self.token;
            std.debug.print("token: {}\n", .{let});
        }
    };
};

pub const Program = struct {
    const Self = @This();
    allocator: std.mem.Allocator,
    statements: std.ArrayList(Statement),

    pub fn init(allocator: std.mem.Allocator) Self {
        return .{
            .allocator = allocator,
            .statements = std.ArrayList(Statement).init(allocator),
        };
    }

    pub fn deinit(self: *Self) void {
        // for (self.statements.items) |*state| {
        //     switch (state.*) {
        //         inline else => |*es| es.deinit(),
        //     }
        // }
        //
        self.statements.deinit();
    }
    pub fn token_literal(self: *Self) []const u8 {
        if (self.statements.items.len > 0) {
            return self.statements[0].token;
        } else {
            return "";
        }
    }
};

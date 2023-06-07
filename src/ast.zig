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
    value: []const u8,

    pub fn init(token: Token) Self {
        return .{
            .token = token,
            .value = token.literal,
        };
    }

    pub fn token_literal(self: *Self) []const u8 {
        return self.token.literal;
    }
};

pub const Expression = union(enum) {
    indentifier: Identifier,
    prefix_expression: PrefixExpression,
    infix_expression: InfixExpression,
};

pub const PrefixExpression = struct {
    const Self = @This();

    pub fn init() Self {}
};

pub const InfixExpression = struct {
    const Self = @This();

    pub fn init(expr: Expression) Self {}
};

pub const Statement = union(enum) {
    let_statement: let_statement,
    return_statement: return_statement,
    expression_statement: expression_statement,

    pub const let_statement = struct {
        const Self = @This();
        token: Token,
        ident: Token,
        value: ?Expression,

        pub fn print(self: *Self) !void {
            const let = self.token;
            std.debug.print("token: {}\n", .{let});
        }
    };

    pub const return_statement = struct {
        const Self = @This();
        token: Token,
        value: ?Expression,
    };

    pub const expression_statement = struct {
        token: Token,
        value: ?Expression,
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
        self.statements.deinit();
    }

    pub fn token_literal(self: *Self) []const u8 {
        if (self.statements.items.len > 0) {
            return self.statements[0].token.literal;
        } else {
            return "";
        }
    }
};

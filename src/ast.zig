const std = @import("std");
const lexer = @import("lexer.zig");
pub const Node = union(enum) {
    const self = @This();
    expression: Expression,
    statement: Statement,
};

pub const Expression;
pub const Statement = union(enum) {
    let,
    return_op,
};

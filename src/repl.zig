const std = @import("std");
const lexer = @import("lexer.zig");

pub fn init(allocator: std.mem.Allocator) !void {
    std.debug.print(">> ", .{});

    const input = try std.io.getStdIn().reader().readUntilDelimiterAlloc(allocator, '\n', 1024);
    defer allocator.free(input);
    var l = lexer.Lexer.init(input);
    var t: lexer.Token = l.next_token();
    while (true) : (t = l.next_token()) {
        if (t == .eof) break;
        std.debug.print("token: {}\n", .{t});
    }
}

test "replt" {
    const res = std.testing.allocator;
    _ = try init(res);
}

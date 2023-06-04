const std = @import("std");
const repl = @import("repl.zig");
var gp = std.heap.GeneralPurposeAllocator(.{}){};
const gpa = gp.allocator();

pub fn main() !void {
    const user = "admin";

    std.debug.print("Welcome {s} to the monkey lang repl\n", .{user});
    var i: usize = 0;
    while (i < 100) : (i += 1) {
        try repl.init(gpa);
    }
}

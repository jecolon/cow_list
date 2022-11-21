const std = @import("std");

pub fn CowList(comptime T: type) type {
    return struct {
        allocator: std.mem.Allocator,
        data: union(enum) {
            inmut: []const T,
            mut: std.ArrayList(T),
        },

        const Self = @This();

        pub fn initConst(allocator: std.mem.Allocator, slice: []const T) Self {
            return Self{ .allocator = allocator, .data = .{ .inmut = slice } };
        }

        pub fn initOwned(allocator: std.mem.Allocator, slice: []T) Self {
            return Self{ .allocator = allocator, .data = .{ .mut = std.ArrayList(T).fromOwnedSlice(allocator, slice) } };
        }

        pub fn deinit(self: *Self) void {
            if (self.data == .mut) {
                self.data.mut.deinit();
            }
        }

        pub fn asConstSlice(self: Self) []const T {
            return switch (self.data) {
                .inmut => |cs| cs,
                .mut => |l| l.items,
            };
        }

        fn to_mut(self: *Self) !void {
            var list = try std.ArrayList(T).initCapacity(self.allocator, self.data.inmut.len);
            list.appendSliceAssumeCapacity(self.data.inmut);
            self.data = .{ .mut = list };
        }

        pub fn asSlice(self: *Self) ![]T {
            if (self.data == .inmut) try self.to_mut();

            return self.data.mut.items;
        }

        pub fn asList(self: *Self) !*std.ArrayList(T) {
            if (self.data == .inmut) try self.to_mut();

            return &self.data.mut;
        }

        pub fn toOwnedSlice(self: *Self) ![]T {
            if (self.data == .inmut) try self.to_mut();

            return self.data.mut.toOwnedSlice();
        }
    };
}

pub fn main() !void {}

test {
    const allocator = std.testing.allocator;
    var str_cow = CowList(u8).initConst(allocator, "Hello");
    defer str_cow.deinit();

    try std.testing.expectEqualStrings("Hello", str_cow.asConstSlice());

    var mut_str_cow = try str_cow.asSlice();
    mut_str_cow[mut_str_cow.len - 1] = 'a';
    try std.testing.expectEqualStrings("Hella", str_cow.asConstSlice());

    var str_cow_list = try str_cow.asList();
    try str_cow_list.appendSlice(" World!");
    try std.testing.expectEqualStrings("Hella World!", str_cow.asConstSlice());
}

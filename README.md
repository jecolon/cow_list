# cow_list
cow_list provides a Copy-on-Write list / slice implementation for Zig.

## Usage Example

```zig
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
```

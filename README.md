# cow_list
## ⚠️ Attention! cow_list has moved to Codeberg!
Visit the repo at: https://codeberg.org/dude_the_builder/cow_list and update your dependencies! The source code 
on this GitHub repo will be removed on September 30, 2023 11:59 PM (AST-4), leaving only instructions on how to
find the project on Codeberg.org and integrate it into your project.

cow_list provides a Copy-on-Write list / slice implementation for Zig.

## Adding cow_list to your Project
cow_list uses the Zig build system and official package manager, so integration is the same as any other Zig 
module. To track the main development branch, in `build.zig.zon` add:

```
.dependencies = .{
    .zigstr = .{
        .url = "https://github.com/jecolon/cow_list/archive/refs/tags/v0.11.0.tar.gz",
    },
},
```

and in your `build.zig`:

```
const cow_list = b.dependency("cow_list", .{
    .target = target,
    .optimize = optimize,
});

// exe, lib, tests, etc.
exe.addModule("cow_list", cow_list.module("cow_list"));
```

When yu now try to build your project, the compiler will produce a hash mismatch error, indicating
the hash that you should add to `build.zig.zon` to make the build work.

To see available tags click [here](https://github.com/jecolon/cow_list/tags) and when you click
on a tag name, you'll see the link to the `tar.gz` file under **Assets**.

With all this, you can now `@import("cow_list")` in your project.

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

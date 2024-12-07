const std = @import("std");

pub const ComponentList = std.ArrayList(Component);

pub const TextComponent = struct {

    text: []const u8,
    decoration: u16, // Bitmask of TextDecoration.
};


/// An interface for all components to implement.
/// ptr represents a pointer to the implementing struct, both in this structs field, and the functions.
pub const Component = struct {
    ptr: *anyopaque, 
    children: ComponentList,

    toJsonFn: fn(ptr: *anyopaque) []const u8,
    appendFn: fn(ptr: *anyopaque) void
};
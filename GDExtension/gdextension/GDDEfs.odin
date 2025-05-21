package gdextension

//Will likely need to make some build specific definitions since the size of things changes based on the Godot build used.

/******************/
/******************/
/*******DEFS********/
/******************/
/******************/
//optional in Godot. These are mainly to define pointer etc variable lengths in C.
StringName:: struct{
    data: [8]u8
}
gdstring:: struct{
    data: [8]u8
}

//The use 16 if your Godot version was built with double precision support, which is not the default.
//else use 8
Vector2 :: struct {
    data: [2]f32,
}

//if double precision a Variant is 10!!!! ints wide?!
//Otherwise it's 'only' 6 ints. Dude what?
Variant :: struct {
    data: [6]i32
}

PropertyHint :: enum {
    PROPERTY_HINT_NONE
}

PropertyUsageFlags :: enum {
    PROPERTY_USAGE_NONE,
    PROPERTY_USAGE_STORAGE = 2,
    PROPERTY_USAGE_EDITOR = 4,
    PROPERTY_USAGE_DEFAULT = PROPERTY_USAGE_STORAGE | PROPERTY_USAGE_EDITOR
}
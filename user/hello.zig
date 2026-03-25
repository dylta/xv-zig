const c = @cImport({
    @cInclude("kernel/types.h");
    @cInclude("kernel/stat.h");
    @cInclude("user/user.h");
});

export fn main() c_int {
    c.printf("Hello from Zig\n");
    return 0;
}

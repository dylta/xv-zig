export fn memset(dst: *anyopaque, val: i32, n: u32) callconv(.c) *anyopaque {
    var vdst: [*]u8 = @ptrCast(dst);
    var i: usize = 0;
    const count: usize = n;
    const byte: u8 = @truncate(@as(u32, @bitCast(val)));
    while (i < count) : (i += 1)
        vdst[i] = byte;

    return dst;
}

export fn memcmp(v1: *const anyopaque, v2: *const anyopaque, n: u32) callconv(.c) i32 {
    var s1: [*]const u8 = @ptrCast(v1);
    var s2: [*]const u8 = @ptrCast(v2);
    var m = n;
    while (m > 0) {
        m -= 1;
        if (s1[0] != s2[0])
            return @as(i32, s1[0]) - @as(i32, s2[0]);
        s1 += 1;
        s2 += 1;
    }

    return 0;
}

export fn memmove(dst: *anyopaque, src: *const anyopaque, n: u32) callconv(.c) *anyopaque {
    if (n == 0)
        return dst;

    var s: [*]const u8 = @ptrCast(src);
    var d: [*]u8 = @ptrCast(dst);
    var m: usize = n;
    const s_addr = @intFromPtr(s);
    const d_addr = @intFromPtr(d);
    if (s_addr < d_addr and s_addr + m > d_addr) {
        s += m;
        d += m;
        while (m > 0) {
            m -= 1;
            d -= 1;
            s -= 1;
            d[0] = s[0];
        }
    } else {
        while (m > 0) {
            m -= 1;
            d[0] = s[0];
            d += 1;
            s += 1;
        }
    }

    return dst;
}

// memcpy exists to placate GCC. Use memmove.
export fn memcpy(dst: *anyopaque, src: *const anyopaque, n: u32) callconv(.c) *anyopaque {
    return memmove(dst, src, n);
}

export fn strncmp(str1: [*]const u8, str2: [*]const u8, n: u32) callconv(.c) i32 {
    var remaining = n;
    var s1 = str1;
    var s2 = str2;
    while (remaining > 0 and s1[0] != 0 and s1[0] == s2[0]) {
        remaining -= 1;
        s1 += 1;
        s2 += 1;
    }
    if (remaining == 0)
        return 0;
    return @as(i32, s1[0]) - @as(i32, s2[0]);
}

export fn strncpy(dst: [*]u8, src: [*]const u8, n: i32) callconv(.c) [*]u8 {
    const og = dst;
    var remaining = n;

    var d = dst;
    var s = src;
    while (remaining > 0) {
        remaining -= 1;
        d[0] = s[0];
        if (d[0] == 0)
            break;
        d += 1;
        s += 1;
    }
    while (remaining > 0) {
        remaining -= 1;
        d[0] = 0;
        d += 1;
    }
    return og;
}

// Like strncpy but guartanteed to NUL-terminate
export fn safestrcpy(dst: [*]u8, src: [*]const u8, n: i32) callconv(.c) [*]u8 {
    const og = dst;
    var remaining = n;
    if (remaining <= 0)
        return og;

    var d = dst;
    var s = src;
    while (remaining > 1) {
        remaining -= 1;
        d[0] = s[0];
        if (d[0] == 0)
            break;
        d += 1;
        s += 1;
    }
    d[0] = 0;
    return og;
}

export fn strlen(str: [*]const u8) callconv(.c) i32 {
    var n: usize = 0;
    while (str[n] != 0) : (n += 1) {}
    return @intCast(n);
}

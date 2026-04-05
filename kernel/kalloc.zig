// Physical memory allocator, for user proceses,
// kernel stacks, page-table pages,
// and pipe buffers. Allocates whole 4096-byte pages.

pub const c_kernel = @cImport({
    @cInclude("types.h");
    @cInclude("riscv.h");
    @cInclude("spinlock.h");
    @cInclude("defs.h");
});

pub const mem = @import("memlayout.zig");
pub const rv = @import("riscv.zig");

// Defined by kernel.ld.
// This refers to a byte at the memory location
// where the symbol 'end' is stored.
extern const end: u8;

pub const Run = struct {
    next: ?*Run,
};

var kmem = struct {
    lock: c_kernel.struct_spinlock,
    freelist: ?*Run,
}{ .lock = .{ .locked = 0, .name = null, .cpu = null }, .freelist = null };

export fn kinit() void {
    c_kernel.initlock(&kmem.lock, @constCast("kmem"));
    const end_addr: usize = @intFromPtr(&end);
    freerange(end_addr, mem.PHYSTOP);
}

fn freerange(pa_start: usize, pa_end: usize) void {
    var p: usize = @intCast(rv.pageRoundUp(pa_start));
    while (p + rv.PAGESIZE <= pa_end) : (p += rv.PAGESIZE) {
        kfree(@ptrFromInt(p));
    }
}

// Free the page of physical memory pointed at by pa,
// which normally should have been returned by a
// call to kalloc(). (The exception is when
// initializing the allocator, see kinit above.)
export fn kfree(pa: *anyopaque) void {
    const pa_addr = @intFromPtr(pa);
    const end_addr: usize = @intFromPtr(&end);
    if (pa_addr % rv.PAGESIZE != 0 or pa_addr < end_addr or pa_addr >= mem.PHYSTOP) {
        c_kernel.panic(@constCast("kfree"));
    }

    // Fill with junk to catch dangling refs.
    _ = c_kernel.memset(pa, 1, rv.PAGESIZE);

    var r: *Run = @ptrCast(@alignCast(pa));

    c_kernel.acquire(&kmem.lock);
    r.next = kmem.freelist;
    kmem.freelist = r;
    c_kernel.release(&kmem.lock);
}

// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
export fn kalloc() ?*anyopaque {
    c_kernel.acquire(&kmem.lock);
    const r = kmem.freelist;
    if (r) |ptr| {
        kmem.freelist = ptr.next;
    }
    c_kernel.release(&kmem.lock);

    if (r) |ptr| {
        _ = c_kernel.memset(ptr, 5, rv.PAGESIZE);
        return @ptrCast(ptr);
    }
    return null;
}

const std = @import("std");
const k = @cImport({
    @cInclude("types.h");
    @cInclude("param.h");
    @cInclude("memlayout.h");
    @cInclude("riscv.h");
    @cInclude("defs.h");
});

var started = 0;

// start() jumps here in supervisor mode on all CPUS.
pub fn main() callconv(.c) void {
    if (k.cpuid() == 0) {
        k.consoleinit();
        k.printfinit();
        std.debug.print("\nxv6 kernel is booting\n\n");
        k.kinit();
        k.kvminit();
        k.kvminithart();
        k.procinit(); // process table
        k.trapinit(); // trap vectors
        k.trapinithart(); // install kernel trap vector
        k.plicinit(); // set up interrupt controller
        k.plicinithart(); // ask PLIC for device interrupts
        k.binit(); // buffer cache
        k.iinit(); // inode table
        k.fileinit(); // file table
        k.virtio_disk_init(); // emulated hard disk
        k.userinit(); // first user process
    } else {
        while (started == 0) {}
        std.debug.print("hart %d starting\n", k.cpuid());
        k.kvminithart(); // turn on paging
        k.trapinithart(); // install kernel trap vector
        k.plicinithart(); // ask PLIC for device interrupts
    }

    k.scheduler();
}

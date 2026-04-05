// This is still a WIP. The basic skeleton is set up
// but will need to port a larger portion of the
// kernel before it can replace main.c

const k = @cImport({
    @cInclude("types.h");
    @cInclude("param.h");
    @cInclude("memlayout.h");
    @cInclude("riscv.h");
    @cInclude("defs.h");
});

var started: i32 = 0;

// start() jumps here in supervisor mode on all CPUS.
export fn main() callconv(.c) void {
    if (k.cpuid() == 0) {
        k.consoleinit();
        k.printfinit();
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
        @atomicStore(i32, &started, 1, .release);
    } else {
        while (@atomicLoad(i32, &started, .acquire) == 0) {}
        k.kvminithart(); // turn on paging
        k.trapinithart(); // install kernel trap vector
        k.plicinithart(); // ask PLIC for device interrupts
    }

    k.scheduler();
}

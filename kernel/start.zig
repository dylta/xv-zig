const k = @cImport({
    @cInclude("types.h");
    @cInclude("param.h");
    @cInclude("memlayout.h");
    @cInclude("riscv.h");
    @cInclude("defs.h");
});

const main_mod = @import("main.zig");

// entry.S needs one stack per CPU.
// export allows stack0 to be found by linker.
export var stack0: [4096 * k.NCPU]u8 align(16) = undefined;

// entry.S jumps here in machine mode on stack0.
fn start() void {
    // set M Previous Privilege mode to Supervisor, for mre
    var x = k.r_mstatus();
    x &= ~k.MSTATUS_MPP_MASK;
    x |= k.MSTATUS_MPP_S;
    k.w_mstatus(x);

    // set M Exception Program Counter to main, for mret.
    // requires gcc -mcmodel=medany
    k.w_mepc(@intFromPtr(main_mod.main));

    // disable paging for now.
    k.w_satp(0);

    // delegate all interrupts and exceptions to supervisor mode.
    k.w_medeleg(0xffff);
    k.w_mideleg(0xffff);
    k.w_sie(k.r_sie() | k.SIE_SEIE | k.SIE_STIE);

    // configure Physical Memory Protection to give supervisor mode
    // access to all of physical memory.
    k.w_pmpaddr0(0x3fffffffffffff);
    k.w_pmpcfg0(0xf);

    // ask for clock interrupts.
    k.timerinit();

    // keep each CPU's hartid in its tp register, for cpuid().
    const id = k.r_mhartid();
    k.w_tp(id);

    // switch to supervisor mode and jump to main().
    asm volatile ("mret");
}

// ask each hart to generate timer interrupts.
fn timerinit() void {
    // enable supervisor-mode timer interrupts.
    k.w_mie(k.r_mie() | k.MIE_STIE);

    // enable the sstc extension (i.e. stimecmp).
    k.w_menvcfg(k.r_menvcf() | (@as(c_long, 1) << 63));

    // allow supervisor to use stimecmp and time.
    k.w_mcounteren(k.r_mcounteren() | 2);

    // ask for the very first timer interrupt.
    k.w_stimecmp(k.r_time() + 1_000_000);
}

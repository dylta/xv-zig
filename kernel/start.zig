const riscv = @import("riscv.zig");
const param = @import("param.zig");

extern fn main() void;

// entry.S needs one stack per CPU.
// export allows stack0 to be found by linker.
export var stack0: [4096 * param.NCPU]u8 align(16) = undefined;

// entry.S jumps here in machine mode on stack0.
export fn start() void {
    // set riscv.M Previous Privilege mode to Supervisor, for mre
    var x: u64 = riscv.r_mstatus();
    x &= ~@as(u64, riscv.MSTATUS_MPP_MASK);
    x |= @as(u64, riscv.MSTATUS_MPP_S);
    riscv.w_mstatus(x);

    // set riscv.M Exception Program Counter to main, for mret.
    // requires gcc -mcmodel=medany
    riscv.w_mepc(@intFromPtr(&main));

    // disable paging for now.
    riscv.w_satp(0);

    // delegate all interrupts and exceptions to supervisor mode.
    riscv.w_medeleg(0xffff);
    riscv.w_mideleg(0xffff);
    riscv.w_sie(riscv.r_sie() | riscv.SIE_SEIE | riscv.SIE_STIE);

    // configure Physical Memory Protection to give supervisor mode
    // access to all of physical memory.
    riscv.w_pmpaddr0(0x3fffffffffffff);
    riscv.w_pmpcfg0(0xf);

    // ask for clock interrupts.
    timerinit();

    // keep each CPU's hartid in its tp register, for cpuid().
    const id = riscv.r_mhartid();
    riscv.w_tp(id);

    // switch to supervisor mode and jump to main().
    asm volatile ("mret");
}

// ask each hart to generate timer interrupts.
fn timerinit() void {
    // enable supervisor-mode timer interrupts.
    riscv.w_mie(riscv.r_mie() | riscv.MIE_STIE);

    // enable the sstc extension (i.e. stimecmp).
    riscv.w_menvcfg(riscv.r_menvcfg() | (@as(c_ulong, 1) << 63));

    // allow supervisor to use stimecmp and time.
    riscv.w_mcounteren(riscv.r_mcounteren() | 2);

    // ask for the very first timer interrupt.
    riscv.w_stimecmp(riscv.r_time() + 1_000_000);
}

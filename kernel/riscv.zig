// which hart (core) is this?
pub inline fn r_mhartid() u64 {
    return asm volatile ("csrr %[ret], mhartid"
        : [ret] "=r" (-> u64),
    );
}

// Machine Status Register, mstatus

pub const MSTATUS_MPP_MASK = 3 << 11; // previous mode.
pub const MSTATUS_MPP_M = 3 << 11;
pub const MSTATUS_MPP_S = 1 << 11;
pub const MSTATUS_MPP_U = 0 << 11;

pub inline fn r_mstatus() u64 {
    return asm volatile ("csrr %[ret], mstatus"
        : [ret] "=r" (-> u64),
    );
}

pub inline fn w_mstatus(x: u64) void {
    asm volatile ("csrw mstatus, %[x]"
        :
        : [x] "r" (x),
    );
}

pub inline fn w_mepc(x: u64) void {
    asm volatile ("csrw mepc, %[x]"
        :
        : [x] "r" (x),
    );
}

// Supervisor Status Register, sstatus

pub const SSTATUS_SPP = 1 << 8; // Previous mode, 1=Supervisor, 0=User
pub const SSTATUS_SPIE = 1 << 5; // Supervisor Previous Interrupt Enable
pub const SSTATUS_UPIE = 1 << 4; // User Previous Interrupt Enable
pub const SSTATUS_SIE = 1 << 1; // Supervisor Interrupt Enable
pub const SSTATUS_UIE = 1 << 0; // User Interrupt Enable

pub inline fn r_sstatus() u64 {
    return asm volatile ("csrr %[ret], sstatus"
        : [ret] "=r" (-> u64),
    );
}

pub inline fn w_sstatus(x: u64) void {
    asm volatile ("csrw sstatus, %[x]"
        :
        : [x] "r" (x),
    );
}

// Supervisor Interrupt Pending
pub inline fn r_sip() u64 {
    return asm volatile ("csrr %[ret], sip"
        : [ret] "=r" (-> u64),
    );
}

pub inline fn w_sip(x: u64) void {
    asm volatile ("csrw sip, %[x]"
        :
        : [x] "r" (x),
    );
}

// Supervisor Interrupt Enable
pub const SIE_SEIE = 1 << 9; // external
pub const SIE_STIE = 1 << 5; // timer
pub inline fn r_sie() u64 {
    return asm volatile ("csrr %[ret], sie"
        : [ret] "=r" (-> u64),
    );
}

pub inline fn w_sie(x: u64) void {
    asm volatile ("csrw sie, %[x]"
        :
        : [x] "r" (x),
    );
}

// Machine-mode Interrupt Enable
pub const MIE_STIE = 1 << 5; // supervisor timer

pub inline fn r_mie() u64 {
    return asm volatile ("csrr %[ret], mie"
        : [ret] "=r" (-> u64),
    );
}

pub inline fn w_mie(x: u64) void {
    asm volatile ("csrw mie, %[x]"
        :
        : [x] "r" (x),
    );
}

// supervisor exception program counter, holds the
// instruction address to which a return from
// exception will go.
pub inline fn w_sepc(x: u64) void {
    asm volatile ("csrw sepc, %[x]"
        :
        : [x] "r" (x),
    );
}

pub inline fn r_sepc() u64 {
    return asm volatile ("csrr %[ret], sepc"
        : [ret] "=r" (-> u64),
    );
}

// Machine Exception Delegation
pub inline fn r_medeleg() u64 {
    return asm volatile ("csrr %[ret], medeleg"
        : [ret] "=r" (-> u64),
    );
}

pub inline fn w_medeleg(x: u64) void {
    asm volatile ("csrw medeleg, %[x]"
        :
        : [x] "r" (x),
    );
}

// Machine Interrupt Delegation
pub inline fn r_mideleg() u64 {
    return asm volatile ("csrr %[ret], mideleg"
        : [ret] "=r" (-> u64),
    );
}

pub inline fn w_mideleg(x: u64) void {
    asm volatile ("csrw mideleg, %[x]"
        :
        : [x] "r" (x),
    );
}

// Supervisor Trap-Vector Base Address
// low two bits are mode.
pub inline fn w_stvec(x: u64) void {
    asm volatile ("csrw stvec, %[x]"
        :
        : [x] "r" (x),
    );
}

pub inline fn r_stvec() u64 {
    return asm volatile ("csrr %[ret], stvec"
        : [ret] "=r" (-> u64),
    );
}

// Supervisor Timer Comparison Register
pub inline fn r_stimecmp() u64 {
    return asm volatile ("csrr %[ret], 0x14d"
        : [ret] "=r" (-> u64),
    );
}

pub inline fn w_stimecmp(x: u64) void {
    asm volatile ("csrw 0x14d, %[x]"
        :
        : [x] "r" (x),
    );
}

// Machine Environment Configuration Register
pub inline fn r_menvcfg() u64 {
    return asm volatile ("csrr %[ret], 0x30a"
        : [ret] "=r" (-> u64),
    );
}

pub inline fn w_menvcfg(x: u64) void {
    asm volatile ("csrw 0x30a, %[x]"
        :
        : [x] "r" (x),
    );
}

// Physical Memory Protection
pub inline fn w_pmpcfg0(x: u64) void {
    asm volatile ("csrw pmpcfg0, %[x]"
        :
        : [x] "r" (x),
    );
}

pub inline fn w_pmpaddr0(x: u64) void {
    asm volatile ("csrw pmpaddr0, %[x]"
        :
        : [x] "r" (x),
    );
}

// use riscv's sv39 page table scheme.
pub const SATP_SV39 = 8 << 60;

pub inline fn make_satp(pagetable: u64) u64 {
    return SATP_SV39 | (pagetable >> 12);
}

// supervisor address translation and protection;
// holds the address of the page table.
pub inline fn w_satp(x: u64) void {
    asm volatile ("csrw satp, %[x]"
        :
        : [x] "r" (x),
    );
}

pub inline fn r_satp() u64 {
    return asm volatile ("csrr %[ret], satp"
        : [ret] "=r" (-> u64),
    );
}

// Supervisor Trap Cause
pub inline fn r_scause() u64 {
    return asm volatile ("csrr %[ret], scause"
        : [ret] "=r" (-> u64),
    );
}

// Supervisor Trap Value
pub inline fn r_stval() u64 {
    return asm volatile ("csrr %[ret], stval"
        : [ret] "=r" (-> u64),
    );
}

// Machine-mode Counter-Enable
pub inline fn w_mcounteren(x: u64) void {
    asm volatile ("csrw mcounteren, %[x]"
        :
        : [x] "r" (x),
    );
}

pub inline fn r_mcounteren() u64 {
    return asm volatile ("csrr %[ret], mcounteren"
        : [ret] "=r" (-> u64),
    );
}

// machine-mode cycle counter
pub inline fn r_time() u64 {
    return asm volatile ("csrr %[ret], time"
        : [ret] "=r" (-> u64),
    );
}

// enable device interrupts
pub inline fn intr_on() void {
    w_sstatus(r_sstatus() | SSTATUS_SIE);
}

// disable device interrupts
pub inline fn intr_off() void {
    w_sstatus(r_sstatus() & ~SSTATUS_SIE);
}

// are device interrupts enabled?
pub inline fn intr_get() u64 {
    const x = r_sstatus();
    return (x & SSTATUS_SIE) != 0;
}

pub inline fn r_sp() u64 {
    return asm volatile ("mv %[ret], sp"
        : [ret] "=r" (-> u64),
    );
}

// read and write tp, the thread pointer, which xv6 uses to hold
// this core's hartid (core number), the index into cpus[].
pub inline fn r_tp() u64 {
    return asm volatile ("mv %[ret], tp"
        : [ret] "=r" (-> u64),
    );
}

pub inline fn w_tp(x: u64) void {
    asm volatile ("mv tp, %[x]"
        :
        : [x] "r" (x),
    );
}

pub inline fn r_ra() u64 {
    return asm volatile ("mv %[ret], ra"
        : [ret] "=r" (-> u64),
    );
}

// flush the TLB.
pub inline fn sfence_vma() void {
    // the zero, zero means flush all TLB entries.
    asm volatile ("sfence.vma zero, zero");
}

pub const pte_t = u64;
pub const pagetable_t = [*]pte_t; // 512 PTEs

pub const PAGE_SIZE = 4096; // bytes per page
pub const PAGE_SHIFT = 12; // bits of offset within a page

pub inline fn pageRoundUp(sz: u64) u64 {
    return (sz + PAGE_SIZE - 1) & ~(PAGE_SIZE - 1);
}

pub inline fn pageRoundDown(a: u64) u64 {
    return a & ~(PAGE_SIZE - 1);
}

pub const PTE_V = 1 << 0; // valid
pub const PTE_R = 1 << 1;
pub const PTE_W = 1 << 2;
pub const PTE_X = 1 << 3;
pub const PTE_U = 1 << 4; // user can access

// shift a physical address to the right place for a PTE.
pub inline fn pa2pte(pa: u64) u64 {
    return (pa >> 12) << 10;
}

pub inline fn pte2pa(pte: u64) u64 {
    return (pte >> 10) << 12;
}

pub inline fn pte_flags(pte: u64) u64 {
    return pte & 0x3FF;
}

// extract the three 9-bit page table indices from a virtual address.
pub const PXMASK = 0x1FF; // 9 bits

pub inline fn pxshift(level: u64) u64 {
    return PAGE_SHIFT + (9 * level);
}

pub inline fn px(level: u64, va: u64) u64 {
    return (va >> pxshift(level)) & PXMASK;
}

// one beyond the highest possible virtual address.
// MAXVA is actually one bit less than the max allowed by
// Sv39, to avoid having to sign-extend virtual addresses
// that have the high bit set.
pub const MAXVA = 1 << (9 + 9 + 9 + 12 - 1);

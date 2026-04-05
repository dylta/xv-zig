// Physical memory layout

// qemu -machine virt is set up like this,
// based on qemu's hw/rsicv/virt.c:
//
// 00001000 -- boot ROM, provided by qemu
// 02000000 -- CLINT
// 0C000000 -- PLIC
// 10000000 -- uart0
// 10001000 -- virtio disk
// 80000000 -- qemu's boot ROM loads the kernel here,
//             then jumps here.
// unused RAM after 80000000.

// the kernel uses physical memory thus:
// 80000000 -- entry.S, then kernel text and data
// end -- start of kernel page allocation area
// PHYSTOP -- end RAM used by the kernel

const riscv = @import("riscv.zig");

// qemu puts UART registers here in physical memory.
pub const UART0 = 0x10000000;
pub const UART0_IRQ = 10;

// virtio mmio interface
pub const VIRTIO0 = 0x10001000;
pub const VIRTIO0_IRQ = 1;

// qemu puts platform-level interrupt controller (PLIC) here.
pub const PLIC = 0x0C000000;
pub const PLIC_PRIORITY = PLIC + 0x0;

pub fn plic_senable(hart: comptime_int) usize {
    return PLIC + 0x2080 + hart * 0x100;
}

pub fn plic_spriority(hart: comptime_int) usize {
    return PLIC + 0x201000 + hart * 0x2000;
}

pub fn plic_sclaim(hart: comptime_int) usize {
    return PLIC + 0x201004 + hart * 0x2000;
}

// the kernel expects there to be RAM
// for use by the kernel and user pages
// from physical address 0x80000000 to PHYSTOP.
pub const KERNBASE: usize = 0x80000000;
pub const PHYSTOP: usize = KERNBASE + 128 * 1024 * 1024;

// map the trampoline page to the highest address,
// in both user and kernel space.
pub const TRAMPOLINE = riscv.MAXVA - riscv.PGSIZE;

// map kernel stacks beneath the trampoline,
// each surrounded by invalid guard pages.
pub fn kstack(p: comptime_int) u64 {
    return TRAMPOLINE - ((p + 1) * 2 * riscv.PGSIZE);
}

// User memory layout.
// Address zero first:
//  text
//  original data and bss
//  fixed-size stack
//  expandable heap
//  ...
//  TRAPFRAME (p->trapframe, used by the trampoline)
//  TRAMPOLINE (the same page as in the kernel)
const TRAPFRAME = TRAMPOLINE - riscv.PGSIZE;

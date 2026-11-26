savedcmd_synaptics_tcm_core.o := clang -Wp,-MMD,./.synaptics_tcm_core.o.d -nostdinc -I/home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include -I/home/venus/lemonadep-6.18/build/out/arch/arm64/include/generated -I/home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include -I/home/venus/lemonadep-6.18/build/out/include -I/home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/uapi -I/home/venus/lemonadep-6.18/build/out/arch/arm64/include/generated/uapi -I/home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/uapi -I/home/venus/lemonadep-6.18/build/out/include/generated/uapi -include /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/compiler-version.h -include /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/kconfig.h -include /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/compiler_types.h -D__KERNEL__ --target=aarch64-linux-gnu -fintegrated-as -Werror=unknown-warning-option -Werror=ignored-optimization-argument -Werror=option-ignored -Werror=unused-command-line-argument -mlittle-endian -DKASAN_SHADOW_SCALE_SHIFT= -std=gnu11 -fshort-wchar -funsigned-char -fno-common -fno-PIE -fno-strict-aliasing -mgeneral-regs-only -DCONFIG_CC_HAS_K_CONSTRAINT=1 -Wno-psabi -fasynchronous-unwind-tables -mbranch-protection=pac-ret -Wa,-march=armv8.5-a -DARM64_ASM_ARCH='"armv8.5-a"' -ffixed-x18 -DKASAN_SHADOW_SCALE_SHIFT= -fno-delete-null-pointer-checks -O2 -fstack-protector-strong -fno-omit-frame-pointer -fno-optimize-sibling-calls -ftrivial-auto-var-init=zero -fno-stack-clash-protection -fsanitize=kcfi -fsanitize-cfi-icall-experimental-normalize-integers -falign-functions=4 -fstrict-flex-arrays=3 -fno-strict-overflow -fno-stack-check -fno-builtin-wcslen -Wall -Wextra -Wundef -Werror=implicit-function-declaration -Werror=implicit-int -Werror=return-type -Werror=strict-prototypes -Wno-format-security -Wno-trigraphs -Wno-frame-address -Wno-address-of-packed-member -Wmissing-declarations -Wmissing-prototypes -Wframe-larger-than=2048 -Wno-gnu -Wno-format-overflow-non-kprintf -Wno-format-truncation-non-kprintf -Wno-default-const-init-unsafe -Wno-pointer-sign -Wcast-function-type -Wno-unterminated-string-initialization -Wimplicit-fallthrough -Werror=date-time -Werror=incompatible-pointer-types -Wenum-conversion -Wunused -Wno-unused-but-set-variable -Wno-unused-const-variable -Wno-format-overflow -Wno-override-init -Wno-pointer-to-enum-cast -Wno-tautological-constant-out-of-range-compare -Wno-unaligned-access -Wno-enum-compare-conditional -Wno-missing-field-initializers -Wno-type-limits -Wno-shift-negative-value -Wno-enum-enum-conversion -Wno-sign-compare -Wno-unused-parameter -g -gdwarf-5 -gz=zstd -mstack-protector-guard=sysreg -mstack-protector-guard-reg=sp_el0 -mstack-protector-guard-offset=1824 -I././include  -fsanitize=array-bounds -fsanitize=local-bounds -fsanitize-trap=undefined    -fdebug-info-for-profiling -mllvm -enable-fs-discriminator=true -mllvm -improved-fs-discriminator=true  -DMODULE  -DKBUILD_BASENAME='"synaptics_tcm_core"' -DKBUILD_MODNAME='"synaptics_tcm_core"' -D__KBUILD_MODNAME=kmod_synaptics_tcm_core -c -o synaptics_tcm_core.o synaptics_tcm_core.c  

source_synaptics_tcm_core.o := synaptics_tcm_core.c

deps_synaptics_tcm_core.o := \
    $(wildcard include/config/PM) \
    $(wildcard include/config/DRM) \
    $(wildcard include/config/FB) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/compiler-version.h \
    $(wildcard include/config/CC_VERSION_TEXT) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/kconfig.h \
    $(wildcard include/config/CPU_BIG_ENDIAN) \
    $(wildcard include/config/BOOGER) \
    $(wildcard include/config/FOO) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/compiler_types.h \
    $(wildcard include/config/DEBUG_INFO_BTF) \
    $(wildcard include/config/PAHOLE_HAS_BTF_TAG) \
    $(wildcard include/config/FUNCTION_ALIGNMENT) \
    $(wildcard include/config/CC_HAS_SANE_FUNCTION_ALIGNMENT) \
    $(wildcard include/config/X86_64) \
    $(wildcard include/config/ARM64) \
    $(wildcard include/config/LD_DEAD_CODE_DATA_ELIMINATION) \
    $(wildcard include/config/LTO_CLANG) \
    $(wildcard include/config/HAVE_ARCH_COMPILER_H) \
    $(wildcard include/config/KCSAN) \
    $(wildcard include/config/CC_HAS_ASSUME) \
    $(wildcard include/config/CC_HAS_COUNTED_BY) \
    $(wildcard include/config/CC_HAS_MULTIDIMENSIONAL_NONSTRING) \
    $(wildcard include/config/UBSAN_INTEGER_WRAP) \
    $(wildcard include/config/CFI) \
    $(wildcard include/config/ARCH_USES_CFI_GENERIC_LLVM_PASS) \
    $(wildcard include/config/CC_HAS_ASM_INLINE) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/compiler-context-analysis.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/compiler_attributes.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/compiler-clang.h \
    $(wildcard include/config/ARCH_USE_BUILTIN_BSWAP) \
    $(wildcard include/config/CC_HAS_TYPEOF_UNQUAL) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/compiler.h \
    $(wildcard include/config/ARM64_PTR_AUTH_KERNEL) \
    $(wildcard include/config/ARM64_PTR_AUTH) \
    $(wildcard include/config/BUILTIN_RETURN_ADDRESS_STRIPS_PAC) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/gpio.h \
    $(wildcard include/config/GPIOLIB) \
    $(wildcard include/config/GPIOLIB_LEGACY) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/types.h \
    $(wildcard include/config/HAVE_UID16) \
    $(wildcard include/config/UID16) \
    $(wildcard include/config/ARCH_DMA_ADDR_T_64BIT) \
    $(wildcard include/config/PHYS_ADDR_T_64BIT) \
    $(wildcard include/config/64BIT) \
    $(wildcard include/config/ARCH_32BIT_USTAT_F_TINODE) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/uapi/linux/types.h \
  /home/venus/lemonadep-6.18/build/out/arch/arm64/include/generated/uapi/asm/types.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/uapi/asm-generic/types.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/asm-generic/int-ll64.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/uapi/asm-generic/int-ll64.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/uapi/asm/bitsperlong.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/asm-generic/bitsperlong.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/uapi/asm-generic/bitsperlong.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/uapi/linux/posix_types.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/stddef.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/uapi/linux/stddef.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/uapi/asm/posix_types.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/uapi/asm-generic/posix_types.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/gpio/consumer.h \
    $(wildcard include/config/HTE) \
    $(wildcard include/config/ACPI) \
    $(wildcard include/config/GPIO_SYSFS) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/bits.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/vdso/bits.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/vdso/const.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/uapi/linux/const.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/uapi/linux/bits.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/build_bug.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/compiler.h \
    $(wildcard include/config/TRACE_BRANCH_PROFILING) \
    $(wildcard include/config/PROFILE_ALL_BRANCHES) \
    $(wildcard include/config/OBJTOOL) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/rwonce.h \
    $(wildcard include/config/LTO) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/asm-generic/rwonce.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/kasan-checks.h \
    $(wildcard include/config/KASAN_GENERIC) \
    $(wildcard include/config/KASAN_SW_TAGS) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/kcsan-checks.h \
    $(wildcard include/config/KCSAN_WEAK_MEMORY) \
    $(wildcard include/config/KCSAN_IGNORE_ATOMICS) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/overflow.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/limits.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/uapi/linux/limits.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/vdso/limits.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/const.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/err.h \
  /home/venus/lemonadep-6.18/build/out/arch/arm64/include/generated/uapi/asm/errno.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/uapi/asm-generic/errno.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/uapi/asm-generic/errno-base.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/bug.h \
    $(wildcard include/config/GENERIC_BUG) \
    $(wildcard include/config/PRINTK) \
    $(wildcard include/config/BUG_ON_DATA_CORRUPTION) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/bug.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/stringify.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/asm-bug.h \
    $(wildcard include/config/DEBUG_BUGVERBOSE) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/brk-imm.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/asm-generic/bug.h \
    $(wildcard include/config/BUG) \
    $(wildcard include/config/GENERIC_BUG_RELATIVE_POINTERS) \
    $(wildcard include/config/SMP) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/instrumentation.h \
    $(wildcard include/config/NOINSTR_VALIDATION) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/once_lite.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/panic.h \
    $(wildcard include/config/PANIC_TIMEOUT) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/stdarg.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/printk.h \
    $(wildcard include/config/MESSAGE_LOGLEVEL_DEFAULT) \
    $(wildcard include/config/CONSOLE_LOGLEVEL_DEFAULT) \
    $(wildcard include/config/CONSOLE_LOGLEVEL_QUIET) \
    $(wildcard include/config/EARLY_PRINTK) \
    $(wildcard include/config/PRINTK_INDEX) \
    $(wildcard include/config/DYNAMIC_DEBUG) \
    $(wildcard include/config/DYNAMIC_DEBUG_CORE) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/init.h \
    $(wildcard include/config/MEMORY_HOTPLUG) \
    $(wildcard include/config/HAVE_ARCH_PREL32_RELOCATIONS) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/kern_levels.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/linkage.h \
    $(wildcard include/config/ARCH_USE_SYM_ANNOTATIONS) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/export.h \
    $(wildcard include/config/MODVERSIONS) \
    $(wildcard include/config/GENDWARFKSYMS) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/linkage.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/ratelimit_types.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/uapi/linux/param.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/uapi/asm/param.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/asm-generic/param.h \
    $(wildcard include/config/HZ) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/uapi/asm-generic/param.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/spinlock_types_raw.h \
    $(wildcard include/config/DEBUG_SPINLOCK) \
    $(wildcard include/config/DEBUG_LOCK_ALLOC) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/spinlock_types.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/asm-generic/qspinlock_types.h \
    $(wildcard include/config/NR_CPUS) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/asm-generic/qrwlock_types.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/uapi/asm/byteorder.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/byteorder/little_endian.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/uapi/linux/byteorder/little_endian.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/swab.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/uapi/linux/swab.h \
  /home/venus/lemonadep-6.18/build/out/arch/arm64/include/generated/uapi/asm/swab.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/uapi/asm-generic/swab.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/byteorder/generic.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/lockdep_types.h \
    $(wildcard include/config/PROVE_RAW_LOCK_NESTING) \
    $(wildcard include/config/LOCKDEP) \
    $(wildcard include/config/LOCK_STAT) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/kthread.h \
    $(wildcard include/config/BLK_CGROUP) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/sched.h \
    $(wildcard include/config/DEBUG_ATOMIC_SLEEP) \
    $(wildcard include/config/PREEMPT_RT) \
    $(wildcard include/config/VIRT_CPU_ACCOUNTING_NATIVE) \
    $(wildcard include/config/SCHED_INFO) \
    $(wildcard include/config/SCHEDSTATS) \
    $(wildcard include/config/SCHED_CORE) \
    $(wildcard include/config/FAIR_GROUP_SCHED) \
    $(wildcard include/config/RT_GROUP_SCHED) \
    $(wildcard include/config/RT_MUTEXES) \
    $(wildcard include/config/UCLAMP_TASK) \
    $(wildcard include/config/UCLAMP_BUCKETS_COUNT) \
    $(wildcard include/config/KMAP_LOCAL) \
    $(wildcard include/config/THREAD_INFO_IN_TASK) \
    $(wildcard include/config/MEM_ALLOC_PROFILING) \
    $(wildcard include/config/SCHED_CLASS_EXT) \
    $(wildcard include/config/CGROUP_SCHED) \
    $(wildcard include/config/CFS_BANDWIDTH) \
    $(wildcard include/config/PREEMPT_NOTIFIERS) \
    $(wildcard include/config/BLK_DEV_IO_TRACE) \
    $(wildcard include/config/PREEMPT_RCU) \
    $(wildcard include/config/TASKS_RCU) \
    $(wildcard include/config/TASKS_TRACE_RCU) \
    $(wildcard include/config/MEMCG_V1) \
    $(wildcard include/config/LRU_GEN) \
    $(wildcard include/config/COMPAT_BRK) \
    $(wildcard include/config/CGROUPS) \
    $(wildcard include/config/PSI) \
    $(wildcard include/config/PAGE_OWNER) \
    $(wildcard include/config/EVENTFD) \
    $(wildcard include/config/ARCH_HAS_CPU_PASID) \
    $(wildcard include/config/X86_BUS_LOCK_DETECT) \
    $(wildcard include/config/TASK_DELAY_ACCT) \
    $(wildcard include/config/STACKPROTECTOR) \
    $(wildcard include/config/ARCH_HAS_SCALED_CPUTIME) \
    $(wildcard include/config/CPU_FREQ_TIMES) \
    $(wildcard include/config/VIRT_CPU_ACCOUNTING_GEN) \
    $(wildcard include/config/NO_HZ_FULL) \
    $(wildcard include/config/POSIX_CPUTIMERS) \
    $(wildcard include/config/POSIX_CPU_TIMERS_TASK_WORK) \
    $(wildcard include/config/KEYS) \
    $(wildcard include/config/SYSVIPC) \
    $(wildcard include/config/DETECT_HUNG_TASK) \
    $(wildcard include/config/IO_URING) \
    $(wildcard include/config/AUDIT) \
    $(wildcard include/config/AUDITSYSCALL) \
    $(wildcard include/config/SCHED_PROXY_EXEC) \
    $(wildcard include/config/DETECT_HUNG_TASK_BLOCKER) \
    $(wildcard include/config/TRACE_IRQFLAGS) \
    $(wildcard include/config/UBSAN) \
    $(wildcard include/config/UBSAN_TRAP) \
    $(wildcard include/config/COMPACTION) \
    $(wildcard include/config/TASK_XACCT) \
    $(wildcard include/config/CPUSETS) \
    $(wildcard include/config/X86_CPU_RESCTRL) \
    $(wildcard include/config/FUTEX) \
    $(wildcard include/config/COMPAT) \
    $(wildcard include/config/PERF_EVENTS) \
    $(wildcard include/config/DEBUG_PREEMPT) \
    $(wildcard include/config/NUMA) \
    $(wildcard include/config/NUMA_BALANCING) \
    $(wildcard include/config/RSEQ) \
    $(wildcard include/config/DEBUG_RSEQ) \
    $(wildcard include/config/SCHED_MM_CID) \
    $(wildcard include/config/FAULT_INJECTION) \
    $(wildcard include/config/LATENCYTOP) \
    $(wildcard include/config/KMSAN) \
    $(wildcard include/config/KUNIT) \
    $(wildcard include/config/FUNCTION_GRAPH_TRACER) \
    $(wildcard include/config/TRACING) \
    $(wildcard include/config/KCOV) \
    $(wildcard include/config/MEMCG) \
    $(wildcard include/config/UPROBES) \
    $(wildcard include/config/BCACHE) \
    $(wildcard include/config/MMU) \
    $(wildcard include/config/VMAP_STACK) \
    $(wildcard include/config/LIVEPATCH) \
    $(wildcard include/config/SECURITY) \
    $(wildcard include/config/BPF_SYSCALL) \
    $(wildcard include/config/KSTACK_ERASE) \
    $(wildcard include/config/KSTACK_ERASE_METRICS) \
    $(wildcard include/config/X86_MCE) \
    $(wildcard include/config/KRETPROBES) \
    $(wildcard include/config/RETHOOK) \
    $(wildcard include/config/ARCH_HAS_PARANOID_L1D_FLUSH) \
    $(wildcard include/config/RV) \
    $(wildcard include/config/RV_PER_TASK_MONITORS) \
    $(wildcard include/config/USER_EVENTS) \
    $(wildcard include/config/UNWIND_USER) \
    $(wildcard include/config/PREEMPTION) \
    $(wildcard include/config/PREEMPT_DYNAMIC) \
    $(wildcard include/config/HAVE_PREEMPT_DYNAMIC_CALL) \
    $(wildcard include/config/HAVE_PREEMPT_DYNAMIC_KEY) \
    $(wildcard include/config/MEM_ALLOC_PROFILING_DEBUG) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/uapi/linux/sched.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/current.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/processor.h \
    $(wildcard include/config/ARM64_64K_PAGES) \
    $(wildcard include/config/KUSER_HELPERS) \
    $(wildcard include/config/ARM64_FORCE_52BIT) \
    $(wildcard include/config/HAVE_HW_BREAKPOINT) \
    $(wildcard include/config/ARM64_MTE) \
    $(wildcard include/config/ARM64_GCS) \
    $(wildcard include/config/ARM64_TAGGED_ADDR_ABI) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/cache.h \
    $(wildcard include/config/ARCH_HAS_CACHE_LINE_SIZE) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/uapi/linux/kernel.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/uapi/linux/sysinfo.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/vdso/cache.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/cache.h \
    $(wildcard include/config/KASAN_HW_TAGS) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/bitops.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/typecheck.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/asm-generic/bitops/generic-non-atomic.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/barrier.h \
    $(wildcard include/config/ARM64_PSEUDO_NMI) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/alternative-macros.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/cpucaps.h \
    $(wildcard include/config/ARM64_PAN) \
    $(wildcard include/config/ARM64_EPAN) \
    $(wildcard include/config/ARM64_SVE) \
    $(wildcard include/config/ARM64_SME) \
    $(wildcard include/config/ARM64_CNP) \
    $(wildcard include/config/ARM64_BTI) \
    $(wildcard include/config/ARM64_TLB_RANGE) \
    $(wildcard include/config/ARM64_POE) \
    $(wildcard include/config/ARM64_HAFT) \
    $(wildcard include/config/UNMAP_KERNEL_AT_EL0) \
    $(wildcard include/config/ARM64_ERRATUM_843419) \
    $(wildcard include/config/ARM64_ERRATUM_1742098) \
    $(wildcard include/config/ARM64_ERRATUM_2645198) \
    $(wildcard include/config/ARM64_ERRATUM_2658417) \
    $(wildcard include/config/CAVIUM_ERRATUM_23154) \
    $(wildcard include/config/NVIDIA_CARMEL_CNP_ERRATUM) \
    $(wildcard include/config/ARM64_WORKAROUND_REPEAT_TLBI) \
    $(wildcard include/config/ARM64_ERRATUM_3194386) \
    $(wildcard include/config/ARM64_ERRATUM_4193714) \
    $(wildcard include/config/HW_PERF_EVENTS) \
  /home/venus/lemonadep-6.18/build/out/arch/arm64/include/generated/asm/cpucap-defs.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/insn-def.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/asm-generic/barrier.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/bitops.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/asm-generic/bitops/builtin-__ffs.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/asm-generic/bitops/builtin-ffs.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/asm-generic/bitops/builtin-__fls.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/asm-generic/bitops/builtin-fls.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/asm-generic/bitops/ffz.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/asm-generic/bitops/fls64.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/asm-generic/bitops/sched.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/asm-generic/bitops/hweight.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/asm-generic/bitops/arch_hweight.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/asm-generic/bitops/const_hweight.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/asm-generic/bitops/atomic.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/atomic.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/atomic.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/cmpxchg.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/lse.h \
    $(wildcard include/config/ARM64_LSE_ATOMICS) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/atomic_ll_sc.h \
    $(wildcard include/config/CC_HAS_K_CONSTRAINT) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/alternative.h \
    $(wildcard include/config/MODULES) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/atomic_lse.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/atomic/atomic-arch-fallback.h \
    $(wildcard include/config/GENERIC_ATOMIC64) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/atomic/atomic-long.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/atomic/atomic-instrumented.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/instrumented.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/kmsan-checks.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/asm-generic/bitops/instrumented-atomic.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/asm-generic/bitops/lock.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/asm-generic/bitops/instrumented-lock.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/asm-generic/bitops/non-atomic.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/asm-generic/bitops/non-instrumented-non-atomic.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/asm-generic/bitops/le.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/asm-generic/bitops/ext2-atomic-setbit.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/kasan-enabled.h \
    $(wildcard include/config/ARCH_DEFER_KASAN) \
    $(wildcard include/config/KASAN) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/static_key.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/jump_label.h \
    $(wildcard include/config/JUMP_LABEL) \
    $(wildcard include/config/HAVE_ARCH_JUMP_LABEL_RELATIVE) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/cleanup.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/args.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/jump_label.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/insn.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/cputype.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/sysreg.h \
    $(wildcard include/config/BROKEN_GAS_INST) \
    $(wildcard include/config/ARM64_PA_BITS_52) \
    $(wildcard include/config/ARM64_4K_PAGES) \
    $(wildcard include/config/ARM64_16K_PAGES) \
    $(wildcard include/config/AMPERE_ERRATUM_AC04_CPU_23) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/kasan-tags.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/gpr-num.h \
  /home/venus/lemonadep-6.18/build/out/arch/arm64/include/generated/asm/sysreg-defs.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/bitfield.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/mte-def.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/string.h \
    $(wildcard include/config/BINARY_PRINTF) \
    $(wildcard include/config/FORTIFY_SOURCE) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/array_size.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/errno.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/uapi/linux/errno.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/uapi/linux/string.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/string.h \
    $(wildcard include/config/ARCH_HAS_UACCESS_FLUSHCACHE) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/fortify-string.h \
    $(wildcard include/config/CC_HAS_KASAN_MEMINTRINSIC_PREFIX) \
    $(wildcard include/config/GENERIC_ENTRY) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/thread_info.h \
    $(wildcard include/config/ARCH_HAS_PREEMPT_LAZY) \
    $(wildcard include/config/HAVE_ARCH_WITHIN_STACK_FRAMES) \
    $(wildcard include/config/SH) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/restart_block.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/thread_info.h \
    $(wildcard include/config/ARM64_SW_TTBR0_PAN) \
    $(wildcard include/config/SHADOW_CALL_STACK) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/memory.h \
    $(wildcard include/config/ARM64_VA_BITS) \
    $(wildcard include/config/KASAN_SHADOW_OFFSET) \
    $(wildcard include/config/EXECMEM) \
    $(wildcard include/config/RANDOMIZE_BASE) \
    $(wildcard include/config/DEBUG_VIRTUAL) \
    $(wildcard include/config/EFI) \
    $(wildcard include/config/ARM_GIC_V3_ITS) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/sizes.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/page-def.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/vdso/page.h \
    $(wildcard include/config/PAGE_SHIFT) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/mmdebug.h \
    $(wildcard include/config/DEBUG_VM) \
    $(wildcard include/config/DEBUG_VM_IRQSOFF) \
    $(wildcard include/config/DEBUG_VM_PGFLAGS) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/boot.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/sections.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/asm-generic/sections.h \
    $(wildcard include/config/HAVE_FUNCTION_DESCRIPTORS) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/asm-generic/memory_model.h \
    $(wildcard include/config/FLATMEM) \
    $(wildcard include/config/SPARSEMEM_VMEMMAP) \
    $(wildcard include/config/SPARSEMEM) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/pfn.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/stack_pointer.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/android_vendor.h \
    $(wildcard include/config/ANDROID_VENDOR_OEM_DATA) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/vdso/processor.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/vdso/processor.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/cpufeature.h \
    $(wildcard include/config/ARM64_DEBUG_PRIORITY_MASKING) \
    $(wildcard include/config/ARM64_BTI_KERNEL) \
    $(wildcard include/config/ARM64_PA_BITS) \
    $(wildcard include/config/ARM64_HW_AFDBM) \
    $(wildcard include/config/ARM64_AMU_EXTN) \
    $(wildcard include/config/ARM64_LPA2) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/hwcap.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/uapi/asm/hwcap.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/log2.h \
    $(wildcard include/config/ARCH_HAS_ILOG2_U32) \
    $(wildcard include/config/ARCH_HAS_ILOG2_U64) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/kernel.h \
    $(wildcard include/config/PREEMPT_VOLUNTARY_BUILD) \
    $(wildcard include/config/PREEMPT_) \
    $(wildcard include/config/PROVE_LOCKING) \
    $(wildcard include/config/DYNAMIC_FTRACE) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/align.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/vdso/align.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/container_of.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/hex.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/kstrtox.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/math.h \
  /home/venus/lemonadep-6.18/build/out/arch/arm64/include/generated/asm/div64.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/asm-generic/div64.h \
    $(wildcard include/config/CC_OPTIMIZE_FOR_PERFORMANCE) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/minmax.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/sprintf.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/static_call_types.h \
    $(wildcard include/config/HAVE_STATIC_CALL) \
    $(wildcard include/config/HAVE_STATIC_CALL_INLINE) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/instruction_pointer.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/util_macros.h \
    $(wildcard include/config/FOO_SUSPEND) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/wordpart.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/cpumask.h \
    $(wildcard include/config/FORCE_NR_CPUS) \
    $(wildcard include/config/HOTPLUG_CPU) \
    $(wildcard include/config/DEBUG_PER_CPU_MAPS) \
    $(wildcard include/config/CPUMASK_OFFSTACK) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/bitmap.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/find.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/bitmap-str.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/cpumask_types.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/threads.h \
    $(wildcard include/config/BASE_SMALL) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/gfp_types.h \
    $(wildcard include/config/SLAB_OBJ_EXT) \
    $(wildcard include/config/CMA) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/numa.h \
    $(wildcard include/config/NUMA_KEEP_MEMINFO) \
    $(wildcard include/config/HAVE_ARCH_NODE_DEV_GROUP) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/nodemask.h \
    $(wildcard include/config/HIGHMEM) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/nodemask_types.h \
    $(wildcard include/config/NODES_SHIFT) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/random.h \
    $(wildcard include/config/VMGENID) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/list.h \
    $(wildcard include/config/LIST_HARDENED) \
    $(wildcard include/config/DEBUG_LIST) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/poison.h \
    $(wildcard include/config/ILLEGAL_POINTER_VALUE) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/uapi/linux/random.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/uapi/linux/ioctl.h \
  /home/venus/lemonadep-6.18/build/out/arch/arm64/include/generated/uapi/asm/ioctl.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/asm-generic/ioctl.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/uapi/asm-generic/ioctl.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/irqnr.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/uapi/linux/irqnr.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/hw_breakpoint.h \
    $(wildcard include/config/CPU_PM) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/virt.h \
    $(wildcard include/config/KVM) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/ptrace.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/uapi/asm/ptrace.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/uapi/asm/sve_context.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/irqchip/arm-gic-v3-prio.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/stacktrace/frame.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/kasan.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/mte-kasan.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/pgtable-types.h \
    $(wildcard include/config/PGTABLE_LEVELS) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/asm-generic/pgtable-nopud.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/asm-generic/pgtable-nop4d.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/pgtable-hwdef.h \
    $(wildcard include/config/ARM64_CONT_PTE_SHIFT) \
    $(wildcard include/config/ARM64_CONT_PMD_SHIFT) \
    $(wildcard include/config/ARM64_VA_BITS_52) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/pointer_auth.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/uapi/linux/prctl.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/spectre.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/smp.h \
    $(wildcard include/config/UP_LATE_INIT) \
    $(wildcard include/config/CSD_LOCK_WAIT_DEBUG) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/smp_types.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/llist.h \
    $(wildcard include/config/ARCH_HAVE_NMI_SAFE_CMPXCHG) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/preempt.h \
    $(wildcard include/config/PREEMPT_COUNT) \
    $(wildcard include/config/TRACE_PREEMPT_TOGGLE) \
    $(wildcard include/config/PREEMPT_NONE) \
    $(wildcard include/config/PREEMPT_VOLUNTARY) \
    $(wildcard include/config/PREEMPT) \
    $(wildcard include/config/PREEMPT_LAZY) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/preempt.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/smp.h \
    $(wildcard include/config/ARM64_ACPI_PARKING_PROTOCOL) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/percpu.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/asm-generic/percpu.h \
    $(wildcard include/config/HAVE_SETUP_PER_CPU_AREA) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/percpu-defs.h \
    $(wildcard include/config/ARCH_MODULE_NEEDS_WEAK_PER_CPU) \
    $(wildcard include/config/DEBUG_FORCE_WEAK_PER_CPU) \
    $(wildcard include/config/AMD_MEM_ENCRYPT) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/fpsimd.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/uapi/asm/sigcontext.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/irqflags_types.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/pid_types.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/sem_types.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/shm.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/page.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/personality.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/uapi/linux/personality.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/asm-generic/getorder.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/shmparam.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/asm-generic/shmparam.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/kmsan_types.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/mutex_types.h \
    $(wildcard include/config/MUTEX_SPIN_ON_OWNER) \
    $(wildcard include/config/DEBUG_MUTEXES) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/osq_lock.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/spinlock_types.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/rwlock_types.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/plist_types.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/hrtimer_types.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/timerqueue_types.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/rbtree_types.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/timer_types.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/seccomp_types.h \
    $(wildcard include/config/SECCOMP) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/refcount_types.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/resource.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/uapi/linux/resource.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/uapi/linux/time_types.h \
  /home/venus/lemonadep-6.18/build/out/arch/arm64/include/generated/uapi/asm/resource.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/asm-generic/resource.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/uapi/asm-generic/resource.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/latencytop.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/sched/prio.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/sched/types.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/signal_types.h \
    $(wildcard include/config/OLD_SIGACTION) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/uapi/linux/signal.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/signal.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/uapi/asm/signal.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/asm-generic/signal.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/uapi/asm-generic/signal.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/uapi/asm-generic/signal-defs.h \
  /home/venus/lemonadep-6.18/build/out/arch/arm64/include/generated/uapi/asm/siginfo.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/uapi/asm-generic/siginfo.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/spinlock.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/irqflags.h \
    $(wildcard include/config/IRQSOFF_TRACER) \
    $(wildcard include/config/PREEMPT_TRACER) \
    $(wildcard include/config/DEBUG_IRQFLAGS) \
    $(wildcard include/config/TRACE_IRQFLAGS_SUPPORT) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/irqflags.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/interrupt_rc.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/bottom_half.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/lockdep.h \
    $(wildcard include/config/DEBUG_LOCKING_API_SELFTESTS) \
  /home/venus/lemonadep-6.18/build/out/arch/arm64/include/generated/asm/mmiowb.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/asm-generic/mmiowb.h \
    $(wildcard include/config/MMIOWB) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/spinlock.h \
  /home/venus/lemonadep-6.18/build/out/arch/arm64/include/generated/asm/qspinlock.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/asm-generic/qspinlock.h \
  /home/venus/lemonadep-6.18/build/out/arch/arm64/include/generated/asm/qrwlock.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/asm-generic/qrwlock.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/rwlock.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/spinlock_api_smp.h \
    $(wildcard include/config/INLINE_SPIN_LOCK) \
    $(wildcard include/config/INLINE_SPIN_LOCK_BH) \
    $(wildcard include/config/INLINE_SPIN_LOCK_IRQ) \
    $(wildcard include/config/INLINE_SPIN_LOCK_IRQSAVE) \
    $(wildcard include/config/INLINE_SPIN_TRYLOCK) \
    $(wildcard include/config/INLINE_SPIN_TRYLOCK_BH) \
    $(wildcard include/config/UNINLINE_SPIN_UNLOCK) \
    $(wildcard include/config/INLINE_SPIN_UNLOCK_BH) \
    $(wildcard include/config/INLINE_SPIN_UNLOCK_IRQ) \
    $(wildcard include/config/INLINE_SPIN_UNLOCK_IRQRESTORE) \
    $(wildcard include/config/GENERIC_LOCKBREAK) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/rwlock_api_smp.h \
    $(wildcard include/config/INLINE_READ_LOCK) \
    $(wildcard include/config/INLINE_WRITE_LOCK) \
    $(wildcard include/config/INLINE_READ_LOCK_BH) \
    $(wildcard include/config/INLINE_WRITE_LOCK_BH) \
    $(wildcard include/config/INLINE_READ_LOCK_IRQ) \
    $(wildcard include/config/INLINE_WRITE_LOCK_IRQ) \
    $(wildcard include/config/INLINE_READ_LOCK_IRQSAVE) \
    $(wildcard include/config/INLINE_WRITE_LOCK_IRQSAVE) \
    $(wildcard include/config/INLINE_READ_TRYLOCK) \
    $(wildcard include/config/INLINE_WRITE_TRYLOCK) \
    $(wildcard include/config/INLINE_READ_UNLOCK) \
    $(wildcard include/config/INLINE_WRITE_UNLOCK) \
    $(wildcard include/config/INLINE_READ_UNLOCK_BH) \
    $(wildcard include/config/INLINE_WRITE_UNLOCK_BH) \
    $(wildcard include/config/INLINE_READ_UNLOCK_IRQ) \
    $(wildcard include/config/INLINE_WRITE_UNLOCK_IRQ) \
    $(wildcard include/config/INLINE_READ_UNLOCK_IRQRESTORE) \
    $(wildcard include/config/INLINE_WRITE_UNLOCK_IRQRESTORE) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/syscall_user_dispatch_types.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/mm_types_task.h \
    $(wildcard include/config/ARCH_WANT_BATCHED_UNMAP_TLB_FLUSH) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/tlbbatch.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/android_kabi.h \
    $(wildcard include/config/ANDROID_KABI_RESERVE) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/netdevice_xmit.h \
    $(wildcard include/config/NET_EGRESS) \
    $(wildcard include/config/NET_ACT_MIRRED) \
    $(wildcard include/config/NF_DUP_NETDEV) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/task_io_accounting.h \
    $(wildcard include/config/TASK_IO_ACCOUNTING) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/posix-timers_types.h \
    $(wildcard include/config/POSIX_TIMERS) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/uapi/linux/rseq.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/seqlock_types.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/kcsan.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/rv.h \
    $(wildcard include/config/RV_LTL_MONITOR) \
    $(wildcard include/config/RV_REACTORS) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/uidgid_types.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/tracepoint-defs.h \
    $(wildcard include/config/TRACEPOINTS) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/unwind_deferred_types.h \
  /home/venus/lemonadep-6.18/build/out/arch/arm64/include/generated/asm/kmap_size.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/asm-generic/kmap_size.h \
    $(wildcard include/config/DEBUG_KMAP_LOCAL) \
  /home/venus/lemonadep-6.18/build/out/include/generated/rq-offsets.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/sched/ext.h \
    $(wildcard include/config/EXT_GROUP_SCHED) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/interrupt.h \
    $(wildcard include/config/IRQ_FORCED_THREADING) \
    $(wildcard include/config/RT_SOFTIRQ_AWARE_SCHED) \
    $(wildcard include/config/GENERIC_IRQ_PROBE) \
    $(wildcard include/config/PROC_FS) \
    $(wildcard include/config/IRQ_TIMINGS) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/irqreturn.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/hardirq.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/context_tracking_state.h \
    $(wildcard include/config/CONTEXT_TRACKING_USER) \
    $(wildcard include/config/CONTEXT_TRACKING) \
    $(wildcard include/config/CONTEXT_TRACKING_IDLE) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/percpu.h \
    $(wildcard include/config/RANDOM_KMALLOC_CACHES) \
    $(wildcard include/config/PAGE_SIZE_4KB) \
    $(wildcard include/config/NEED_PER_CPU_PAGE_FIRST_CHUNK) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/alloc_tag.h \
    $(wildcard include/config/MEM_ALLOC_PROFILING_ENABLED_BY_DEFAULT) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/codetag.h \
    $(wildcard include/config/CODE_TAGGING) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/context_tracking_irq.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/ftrace_irq.h \
    $(wildcard include/config/HWLAT_TRACER) \
    $(wildcard include/config/OSNOISE_TRACER) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/vtime.h \
    $(wildcard include/config/VIRT_CPU_ACCOUNTING) \
    $(wildcard include/config/IRQ_TIME_ACCOUNTING) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/hardirq.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/irq.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/asm-generic/irq.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/kvm_arm.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/esr.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/asm-generic/hardirq.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/irq.h \
    $(wildcard include/config/GENERIC_IRQ_EFFECTIVE_AFF_MASK) \
    $(wildcard include/config/GENERIC_IRQ_IPI) \
    $(wildcard include/config/IRQ_DOMAIN_HIERARCHY) \
    $(wildcard include/config/DEPRECATED_IRQ_CPU_ONOFFLINE) \
    $(wildcard include/config/GENERIC_IRQ_MIGRATION) \
    $(wildcard include/config/GENERIC_PENDING_IRQ) \
    $(wildcard include/config/HARDIRQS_SW_RESEND) \
    $(wildcard include/config/GENERIC_IRQ_CHIP) \
    $(wildcard include/config/GENERIC_IRQ_MULTI_HANDLER) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/irqhandler.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/topology.h \
    $(wildcard include/config/USE_PERCPU_NUMA_NODE_ID) \
    $(wildcard include/config/HAVE_MEMORYLESS_NODES) \
    $(wildcard include/config/SCHED_SMT) \
    $(wildcard include/config/GENERIC_ARCH_TOPOLOGY) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/arch_topology.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/mmzone.h \
    $(wildcard include/config/ARCH_FORCE_MAX_ORDER) \
    $(wildcard include/config/PAGE_BLOCK_MAX_ORDER) \
    $(wildcard include/config/MEMORY_ISOLATION) \
    $(wildcard include/config/ZSMALLOC) \
    $(wildcard include/config/UNACCEPTED_MEMORY) \
    $(wildcard include/config/IOMMU_SUPPORT) \
    $(wildcard include/config/SWAP) \
    $(wildcard include/config/HUGETLB_PAGE) \
    $(wildcard include/config/TRANSPARENT_HUGEPAGE) \
    $(wildcard include/config/LRU_GEN_STATS) \
    $(wildcard include/config/LRU_GEN_WALKS_MMU) \
    $(wildcard include/config/ZONE_DMA) \
    $(wildcard include/config/ZONE_DMA32) \
    $(wildcard include/config/ZONE_DEVICE) \
    $(wildcard include/config/MEMORY_FAILURE) \
    $(wildcard include/config/PAGE_EXTENSION) \
    $(wildcard include/config/DEFERRED_STRUCT_PAGE_INIT) \
    $(wildcard include/config/SPARSEMEM_EXTREME) \
    $(wildcard include/config/SPARSEMEM_VMEMMAP_PREINIT) \
    $(wildcard include/config/HAVE_ARCH_PFN_VALID) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/list_nulls.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/wait.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/seqlock.h \
    $(wildcard include/config/CC_IS_GCC) \
    $(wildcard include/config/GCC_VERSION) \
    $(wildcard include/config/UBSAN_ALIGNMENT) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/mutex.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/debug_locks.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/pageblock-flags.h \
    $(wildcard include/config/HUGETLB_PAGE_SIZE_VARIABLE) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/page-flags-layout.h \
  /home/venus/lemonadep-6.18/build/out/include/generated/bounds.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/sparsemem.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/pgtable-prot.h \
    $(wildcard include/config/HAVE_ARCH_USERFAULTFD_WP) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/rsi.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/rsi_cmds.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/arm-smccc.h \
    $(wildcard include/config/HAVE_ARM_SMCCC) \
    $(wildcard include/config/ARM) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/uuid.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/rsi_smc.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/mm_types.h \
    $(wildcard include/config/HAVE_ALIGNED_STRUCT_PAGE) \
    $(wildcard include/config/HUGETLB_PMD_PAGE_TABLE_SHARING) \
    $(wildcard include/config/PTSHARE) \
    $(wildcard include/config/SLAB_FREELIST_HARDENED) \
    $(wildcard include/config/USERFAULTFD) \
    $(wildcard include/config/ANON_VMA_NAME) \
    $(wildcard include/config/PER_VMA_LOCK) \
    $(wildcard include/config/HAVE_ARCH_COMPAT_MMAP_BASES) \
    $(wildcard include/config/MEMBARRIER) \
    $(wildcard include/config/FUTEX_PRIVATE_HASH) \
    $(wildcard include/config/ARCH_HAS_ELF_CORE_EFLAGS) \
    $(wildcard include/config/AIO) \
    $(wildcard include/config/MMU_NOTIFIER) \
    $(wildcard include/config/SPLIT_PMD_PTLOCKS) \
    $(wildcard include/config/IOMMU_MM_DATA) \
    $(wildcard include/config/KSM) \
    $(wildcard include/config/MM_ID) \
    $(wildcard include/config/CORE_DUMP_DEFAULT_ELF_HEADERS) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/auxvec.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/uapi/linux/auxvec.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/uapi/asm/auxvec.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/kref.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/refcount.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/rbtree.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/rcupdate.h \
    $(wildcard include/config/TINY_RCU) \
    $(wildcard include/config/RCU_STRICT_GRACE_PERIOD) \
    $(wildcard include/config/RCU_LAZY) \
    $(wildcard include/config/RCU_STALL_COMMON) \
    $(wildcard include/config/VIRT_XFER_TO_GUEST_WORK) \
    $(wildcard include/config/RCU_NOCB_CPU) \
    $(wildcard include/config/TASKS_RCU_GENERIC) \
    $(wildcard include/config/TASKS_RUDE_RCU) \
    $(wildcard include/config/TREE_RCU) \
    $(wildcard include/config/DEBUG_OBJECTS_RCU_HEAD) \
    $(wildcard include/config/PROVE_RCU) \
    $(wildcard include/config/ARCH_WEAK_RELEASE_ACQUIRE) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/rcutree.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/maple_tree.h \
    $(wildcard include/config/MAPLE_RCU_DISABLED) \
    $(wildcard include/config/DEBUG_MAPLE_TREE) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/rwsem.h \
    $(wildcard include/config/RWSEM_SPIN_ON_OWNER) \
    $(wildcard include/config/DEBUG_RWSEMS) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/completion.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/swait.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/uprobes.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/timer.h \
    $(wildcard include/config/DEBUG_OBJECTS_TIMERS) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/ktime.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/jiffies.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/math64.h \
    $(wildcard include/config/ARCH_SUPPORTS_INT128) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/vdso/math64.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/time.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/time64.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/vdso/time64.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/uapi/linux/time.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/time32.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/timex.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/uapi/linux/timex.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/timex.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/arch_timer.h \
    $(wildcard include/config/ARM_ARCH_TIMER_OOL_WORKAROUND) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/clocksource/arm_arch_timer.h \
    $(wildcard include/config/ARM_ARCH_TIMER) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/timecounter.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/asm-generic/timex.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/vdso/time32.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/vdso/time.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/vdso/jiffies.h \
  /home/venus/lemonadep-6.18/build/out/include/generated/timeconst.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/vdso/ktime.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/timekeeping.h \
    $(wildcard include/config/POSIX_AUX_CLOCKS) \
    $(wildcard include/config/GENERIC_CMOS_UPDATE) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/clocksource_ids.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/debugobjects.h \
    $(wildcard include/config/DEBUG_OBJECTS) \
    $(wildcard include/config/DEBUG_OBJECTS_FREE) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/uprobes.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/debug-monitors.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/probes.h \
    $(wildcard include/config/KPROBES) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/workqueue.h \
    $(wildcard include/config/DEBUG_OBJECTS_WORK) \
    $(wildcard include/config/FREEZER) \
    $(wildcard include/config/SYSFS) \
    $(wildcard include/config/WQ_WATCHDOG) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/workqueue_types.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/percpu_counter.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/mmu.h \
    $(wildcard include/config/ARM64_E0PD) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/page-flags.h \
    $(wildcard include/config/PAGE_IDLE_FLAG) \
    $(wildcard include/config/ARCH_USES_PG_ARCH_2) \
    $(wildcard include/config/ARCH_USES_PG_ARCH_3) \
    $(wildcard include/config/MIGRATION) \
    $(wildcard include/config/HUGETLB_PAGE_OPTIMIZE_VMEMMAP) \
    $(wildcard include/config/DEBUG_KMAP_LOCAL_FORCE_MAP) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/local_lock.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/local_lock_internal.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/zswap.h \
    $(wildcard include/config/ZSWAP) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/memory_hotplug.h \
    $(wildcard include/config/ARCH_HAS_ADD_PAGES) \
    $(wildcard include/config/MEMORY_HOTREMOVE) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/notifier.h \
    $(wildcard include/config/TREE_SRCU) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/srcu.h \
    $(wildcard include/config/TINY_SRCU) \
    $(wildcard include/config/NEED_SRCU_NMI_SAFE) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/rcu_segcblist.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/srcutree.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/rcu_node_tree.h \
    $(wildcard include/config/RCU_FANOUT) \
    $(wildcard include/config/RCU_FANOUT_LEAF) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/topology.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/asm-generic/topology.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/io.h \
    $(wildcard include/config/HAS_IOPORT_MAP) \
    $(wildcard include/config/PCI) \
    $(wildcard include/config/STRICT_DEVMEM) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/io.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/pgtable.h \
    $(wildcard include/config/HIGHPTE) \
    $(wildcard include/config/ARCH_HAS_NONLEAF_PMD_YOUNG) \
    $(wildcard include/config/ARCH_HAS_HW_PTE_YOUNG) \
    $(wildcard include/config/GUP_GET_PXX_LOW_HIGH) \
    $(wildcard include/config/ARCH_WANT_PMD_MKWRITE) \
    $(wildcard include/config/HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD) \
    $(wildcard include/config/HAVE_ARCH_SOFT_DIRTY) \
    $(wildcard include/config/ARCH_ENABLE_THP_MIGRATION) \
    $(wildcard include/config/HAVE_ARCH_HUGE_VMAP) \
    $(wildcard include/config/X86_ESPFIX64) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/pgtable.h \
    $(wildcard include/config/DEBUG_PAGEALLOC) \
    $(wildcard include/config/ARCH_SUPPORTS_PMD_PFNMAP) \
    $(wildcard include/config/PAGE_TABLE_CHECK) \
    $(wildcard include/config/ARM64_CONTPTE) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/proc-fns.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/mte.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/tlbflush.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/mmu_notifier.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/mmap_lock.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/sched/mm.h \
    $(wildcard include/config/MMU_LAZY_TLB_REFCOUNT) \
    $(wildcard include/config/ARCH_HAS_MEMBARRIER_CALLBACKS) \
    $(wildcard include/config/ARCH_HAS_SYNC_CORE_BEFORE_USERMODE) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/gfp.h \
    $(wildcard include/config/CONTIG_ALLOC) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/sync_core.h \
    $(wildcard include/config/ARCH_HAS_PREPARE_SYNC_CORE_CMD) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/sched/coredump.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/interval_tree.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/fixmap.h \
    $(wildcard include/config/ACPI_APEI_GHES) \
    $(wildcard include/config/ARM_SDE_INTERFACE) \
    $(wildcard include/config/RELOCATABLE) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/asm-generic/fixmap.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/por.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/page_table_check.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/asm-generic/pgtable_uffd.h \
  /home/venus/lemonadep-6.18/build/out/arch/arm64/include/generated/asm/early_ioremap.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/asm-generic/early_ioremap.h \
    $(wildcard include/config/GENERIC_EARLY_IOREMAP) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/asm-generic/io.h \
    $(wildcard include/config/GENERIC_IOMAP) \
    $(wildcard include/config/TRACE_MMIO_ACCESS) \
    $(wildcard include/config/HAS_IOPORT) \
    $(wildcard include/config/GENERIC_IOREMAP) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/asm-generic/pci_iomap.h \
    $(wildcard include/config/NO_GENERIC_PCI_IOPORT_MAP) \
    $(wildcard include/config/GENERIC_PCI_IOMAP) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/logic_pio.h \
    $(wildcard include/config/INDIRECT_PIO) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/fwnode.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/slab.h \
    $(wildcard include/config/FAILSLAB) \
    $(wildcard include/config/KFENCE) \
    $(wildcard include/config/SLUB_TINY) \
    $(wildcard include/config/SLUB_DEBUG) \
    $(wildcard include/config/SLAB_BUCKETS) \
    $(wildcard include/config/KVFREE_RCU_BATCHED) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/percpu-refcount.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/hash.h \
    $(wildcard include/config/HAVE_ARCH_HASH) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/kasan.h \
    $(wildcard include/config/KASAN_STACK) \
    $(wildcard include/config/KASAN_VMALLOC) \
  /home/venus/lemonadep-6.18/build/out/arch/arm64/include/generated/asm/irq_regs.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/asm-generic/irq_regs.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/irqdesc.h \
    $(wildcard include/config/GENERIC_IRQ_STAT_SNAPSHOT) \
    $(wildcard include/config/PM_SLEEP) \
    $(wildcard include/config/GENERIC_IRQ_DEBUGFS) \
    $(wildcard include/config/SPARSE_IRQ) \
    $(wildcard include/config/IRQ_DOMAIN) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/irq_work.h \
    $(wildcard include/config/IRQ_WORK) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/irq_work_types.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/rcuwait.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/sched/signal.h \
    $(wildcard include/config/SCHED_AUTOGROUP) \
    $(wildcard include/config/BSD_PROCESS_ACCT) \
    $(wildcard include/config/TASKSTATS) \
    $(wildcard include/config/STACK_GROWSUP) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/rculist.h \
    $(wildcard include/config/PROVE_RCU_LIST) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/signal.h \
    $(wildcard include/config/DYNAMIC_SIGFRAME) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/sched/jobctl.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/sched/task.h \
    $(wildcard include/config/GKI_DYNAMIC_TASK_STRUCT_SIZE) \
    $(wildcard include/config/GKI_TASK_STRUCT_VENDOR_SIZE_MAX) \
    $(wildcard include/config/HAVE_EXIT_THREAD) \
    $(wildcard include/config/ARCH_WANTS_DYNAMIC_TASK_STRUCT) \
    $(wildcard include/config/HAVE_ARCH_THREAD_STRUCT_WHITELIST) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/uaccess.h \
    $(wildcard include/config/ARCH_HAS_SUBPAGE_FAULTS) \
    $(wildcard include/config/HARDENED_USERCOPY) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/fault-inject-usercopy.h \
    $(wildcard include/config/FAULT_INJECTION_USERCOPY) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/nospec.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/ucopysize.h \
    $(wildcard include/config/HARDENED_USERCOPY_DEFAULT_ON) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/uaccess.h \
    $(wildcard include/config/CC_HAS_ASM_GOTO_OUTPUT) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/kernel-pgtable.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/asm-extable.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/extable.h \
    $(wildcard include/config/BPF_JIT) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/asm-generic/access_ok.h \
    $(wildcard include/config/ALTERNATE_USER_ADDRESS_SPACE) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/cred.h \
    $(wildcard include/config/MULTIUSER) \
    $(wildcard include/config/USER_NS) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/capability.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/uapi/linux/capability.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/uidgid.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/highuid.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/key.h \
    $(wildcard include/config/KEY_NOTIFICATIONS) \
    $(wildcard include/config/NET) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/sysctl.h \
    $(wildcard include/config/SYSCTL) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/uapi/linux/sysctl.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/assoc_array.h \
    $(wildcard include/config/ASSOCIATIVE_ARRAY) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/sched/user.h \
    $(wildcard include/config/EPOLL) \
    $(wildcard include/config/VFIO_PCI_ZDEV_KVM) \
    $(wildcard include/config/IOMMUFD) \
    $(wildcard include/config/WATCH_QUEUE) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/ratelimit.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/pid.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/posix-timers.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/alarmtimer.h \
    $(wildcard include/config/RTC_CLASS) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/hrtimer.h \
    $(wildcard include/config/HIGH_RES_TIMERS) \
    $(wildcard include/config/TIME_LOW_RES) \
    $(wildcard include/config/TIMERFD) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/hrtimer_defs.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/timerqueue.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/rcuref.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/irq_work.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/kobject.h \
    $(wildcard include/config/UEVENT_HELPER) \
    $(wildcard include/config/DEBUG_KOBJECT_RELEASE) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/sysfs.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/kernfs.h \
    $(wildcard include/config/KERNFS) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/idr.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/radix-tree.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/xarray.h \
    $(wildcard include/config/XARRAY_MULTI) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/kobject_ns.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/stat.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/stat.h \
  /home/venus/lemonadep-6.18/build/out/arch/arm64/include/generated/uapi/asm/stat.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/uapi/asm-generic/stat.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/compat.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/asm-generic/compat.h \
    $(wildcard include/config/COMPAT_FOR_U64_ALIGNMENT) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/sched/task_stack.h \
    $(wildcard include/config/DEBUG_STACK_USAGE) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/uapi/linux/magic.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/uapi/linux/stat.h \
  /home/venus/lemonadep-6.18/build/out/arch/arm64/include/generated/asm/hw_irq.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/asm-generic/hw_irq.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/regulator/consumer.h \
    $(wildcard include/config/REGULATOR) \
    $(wildcard include/config/OF) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/suspend.h \
    $(wildcard include/config/VT) \
    $(wildcard include/config/VT_CONSOLE_SLEEP) \
    $(wildcard include/config/SUSPEND) \
    $(wildcard include/config/HIBERNATION) \
    $(wildcard include/config/HIBERNATION_SNAPSHOT_DEV) \
    $(wildcard include/config/PM_SLEEP_DEBUG) \
    $(wildcard include/config/PM_AUTOSLEEP) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/swap.h \
    $(wildcard include/config/DEVICE_PRIVATE) \
    $(wildcard include/config/THP_SWAP) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/memcontrol.h \
    $(wildcard include/config/MEMCG_NMI_SAFETY_REQUIRES_ATOMIC) \
    $(wildcard include/config/CGROUP_WRITEBACK) \
    $(wildcard include/config/SHRINKER_DEBUG) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/cgroup.h \
    $(wildcard include/config/DEBUG_CGROUP_REF) \
    $(wildcard include/config/CGROUP_CPUACCT) \
    $(wildcard include/config/SOCK_CGROUP_DATA) \
    $(wildcard include/config/CGROUP_DATA) \
    $(wildcard include/config/CGROUP_BPF) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/uapi/linux/cgroupstats.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/uapi/linux/taskstats.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/fs.h \
    $(wildcard include/config/FANOTIFY_ACCESS_PERMISSIONS) \
    $(wildcard include/config/READ_ONLY_THP_FOR_FS) \
    $(wildcard include/config/FS_POSIX_ACL) \
    $(wildcard include/config/IMA) \
    $(wildcard include/config/FILE_LOCKING) \
    $(wildcard include/config/FSNOTIFY) \
    $(wildcard include/config/UNICODE) \
    $(wildcard include/config/FS_ENCRYPTION) \
    $(wildcard include/config/FS_VERITY) \
    $(wildcard include/config/QUOTA) \
    $(wildcard include/config/FS_DAX) \
    $(wildcard include/config/BLOCK) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/vfsdebug.h \
    $(wildcard include/config/DEBUG_VFS) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/wait_bit.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/kdev_t.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/uapi/linux/kdev_t.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/dcache.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/rculist_bl.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/list_bl.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/bit_spinlock.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/lockref.h \
    $(wildcard include/config/ARCH_USE_CMPXCHG_LOCKREF) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/stringhash.h \
    $(wildcard include/config/DCACHE_WORD_ACCESS) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/path.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/list_lru.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/shrinker.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/semaphore.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/fcntl.h \
    $(wildcard include/config/ARCH_32BIT_OFF_T) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/uapi/linux/fcntl.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/uapi/asm/fcntl.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/uapi/asm-generic/fcntl.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/uapi/linux/openat2.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/migrate_mode.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/percpu-rwsem.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/rcu_sync.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/delayed_call.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/errseq.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/ioprio.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/sched/rt.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/iocontext.h \
    $(wildcard include/config/BLK_ICQ) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/uapi/linux/ioprio.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/fs_types.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/mount.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/mnt_idmapping.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/rw_hint.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/file_ref.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/unicode.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/uapi/linux/fs.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/quota.h \
    $(wildcard include/config/QUOTA_NETLINK_INTERFACE) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/uapi/linux/dqblk_xfs.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/dqblk_v1.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/dqblk_v2.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/dqblk_qtree.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/projid.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/uapi/linux/quota.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/seq_file.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/string_helpers.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/ctype.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/string_choices.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/ns_common.h \
    $(wildcard include/config/IPC_NS) \
    $(wildcard include/config/NET_NS) \
    $(wildcard include/config/PID_NS) \
    $(wildcard include/config/TIME_NS) \
    $(wildcard include/config/UTS_NS) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/nsproxy.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/user_namespace.h \
    $(wildcard include/config/INOTIFY_USER) \
    $(wildcard include/config/FANOTIFY) \
    $(wildcard include/config/BINFMT_MISC) \
    $(wildcard include/config/PERSISTENT_KEYRINGS) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/rculist_nulls.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/kernel_stat.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/cgroup-defs.h \
    $(wildcard include/config/CGROUP_NET_CLASSID) \
    $(wildcard include/config/CGROUP_NET_PRIO) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/u64_stats_sync.h \
  /home/venus/lemonadep-6.18/build/out/arch/arm64/include/generated/asm/local64.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/asm-generic/local64.h \
  /home/venus/lemonadep-6.18/build/out/arch/arm64/include/generated/asm/local.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/asm-generic/local.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/bpf-cgroup-defs.h \
    $(wildcard include/config/BPF_LSM) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/psi_types.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/cgroup_subsys.h \
    $(wildcard include/config/CGROUP_DEVICE) \
    $(wildcard include/config/CGROUP_FREEZER) \
    $(wildcard include/config/CGROUP_PERF) \
    $(wildcard include/config/CGROUP_HUGETLB) \
    $(wildcard include/config/CGROUP_PIDS) \
    $(wildcard include/config/CGROUP_RDMA) \
    $(wildcard include/config/CGROUP_MISC) \
    $(wildcard include/config/CGROUP_DMEM) \
    $(wildcard include/config/CGROUP_DEBUG) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/cgroup_namespace.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/cgroup_refcnt.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/vm_event_item.h \
    $(wildcard include/config/MEMORY_BALLOON) \
    $(wildcard include/config/BALLOON_COMPACTION) \
    $(wildcard include/config/DEBUG_TLBFLUSH) \
    $(wildcard include/config/X86) \
    $(wildcard include/config/PER_VMA_LOCK_STATS) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/page_counter.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/vmpressure.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/eventfd.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/uapi/linux/eventfd.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/mm.h \
    $(wildcard include/config/HAVE_ARCH_MMAP_RND_BITS) \
    $(wildcard include/config/HAVE_ARCH_MMAP_RND_COMPAT_BITS) \
    $(wildcard include/config/MEM_SOFT_DIRTY) \
    $(wildcard include/config/ARCH_USES_HIGH_VMA_FLAGS) \
    $(wildcard include/config/ARCH_HAS_PKEYS) \
    $(wildcard include/config/ARCH_PKEY_BITS) \
    $(wildcard include/config/X86_USER_SHADOW_STACK) \
    $(wildcard include/config/PPC64) \
    $(wildcard include/config/PARISC) \
    $(wildcard include/config/SPARC64) \
    $(wildcard include/config/HAVE_ARCH_USERFAULTFD_MINOR) \
    $(wildcard include/config/PPC32) \
    $(wildcard include/config/FIND_NORMAL_PAGE) \
    $(wildcard include/config/SHMEM) \
    $(wildcard include/config/HAVE_GIGANTIC_FOLIOS) \
    $(wildcard include/config/ARCH_HAS_PTE_SPECIAL) \
    $(wildcard include/config/ARCH_SUPPORTS_PUD_PFNMAP) \
    $(wildcard include/config/ASYNC_KERNEL_PGTABLE_FREE) \
    $(wildcard include/config/SPLIT_PTE_PTLOCKS) \
    $(wildcard include/config/DEBUG_VM_RB) \
    $(wildcard include/config/PAGE_POISONING) \
    $(wildcard include/config/INIT_ON_ALLOC_DEFAULT_ON) \
    $(wildcard include/config/INIT_ON_FREE_DEFAULT_ON) \
    $(wildcard include/config/ARCH_WANT_OPTIMIZE_DAX_VMEMMAP) \
    $(wildcard include/config/HUGETLBFS) \
    $(wildcard include/config/MAPPING_DIRTY_HELPERS) \
    $(wildcard include/config/MSEAL_SYSTEM_MAPPINGS) \
    $(wildcard include/config/PAGE_POOL) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/pgalloc_tag.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/page_ext.h \
    $(wildcard include/config/PAGE_PINNER) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/stacktrace.h \
    $(wildcard include/config/ARCH_STACKWALK) \
    $(wildcard include/config/STACKTRACE) \
    $(wildcard include/config/HAVE_RELIABLE_STACKTRACE) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/range.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/page_ref.h \
    $(wildcard include/config/DEBUG_PAGE_REF) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/pgsize_migration_inline.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/page_pinner.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/memremap.h \
    $(wildcard include/config/PCI_P2PDMA) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/ioport.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/cacheinfo.h \
    $(wildcard include/config/ACPI_PPTT) \
    $(wildcard include/config/ARCH_HAS_CPU_CACHE_ALIASING) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/cpuhplock.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/huge_mm.h \
    $(wildcard include/config/PGTABLE_HAS_HUGE_LEAVES) \
    $(wildcard include/config/PERSISTENT_HUGE_ZERO_FOLIO) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/vmstat.h \
    $(wildcard include/config/VM_EVENT_COUNTERS) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/writeback.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/flex_proportions.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/backing-dev-defs.h \
    $(wildcard include/config/DEBUG_FS) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/blk_types.h \
    $(wildcard include/config/FAIL_MAKE_REQUEST) \
    $(wildcard include/config/BLK_CGROUP_IOCOST) \
    $(wildcard include/config/BLK_INLINE_ENCRYPTION) \
    $(wildcard include/config/DM_DEFAULT_KEY) \
    $(wildcard include/config/BLK_DEV_INTEGRITY) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/bvec.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/highmem.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/cacheflush.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/cacheflush.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/kgdb.h \
    $(wildcard include/config/HAVE_ARCH_KGDB) \
    $(wildcard include/config/KGDB) \
    $(wildcard include/config/KGDB_HONOUR_BLOCKLIST) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/kprobes.h \
    $(wildcard include/config/KRETPROBE_ON_RETHOOK) \
    $(wildcard include/config/OPTPROBES) \
    $(wildcard include/config/KPROBES_ON_FTRACE) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/ftrace.h \
    $(wildcard include/config/HAVE_FUNCTION_GRAPH_FREGS) \
    $(wildcard include/config/FUNCTION_TRACER) \
    $(wildcard include/config/HAVE_DYNAMIC_FTRACE_WITH_ARGS) \
    $(wildcard include/config/HAVE_FTRACE_REGS_HAVING_PT_REGS) \
    $(wildcard include/config/HAVE_REGS_AND_STACK_ACCESS_API) \
    $(wildcard include/config/DYNAMIC_FTRACE_WITH_REGS) \
    $(wildcard include/config/DYNAMIC_FTRACE_WITH_ARGS) \
    $(wildcard include/config/DYNAMIC_FTRACE_WITH_DIRECT_CALLS) \
    $(wildcard include/config/STACK_TRACER) \
    $(wildcard include/config/DYNAMIC_FTRACE_WITH_CALL_OPS) \
    $(wildcard include/config/FRAME_POINTER) \
    $(wildcard include/config/FUNCTION_GRAPH_RETVAL) \
    $(wildcard include/config/FTRACE_SYSCALLS) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/trace_recursion.h \
    $(wildcard include/config/FTRACE_RECORD_RECURSION) \
    $(wildcard include/config/FTRACE_VALIDATE_RCU_IS_WATCHING) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/trace_clock.h \
  /home/venus/lemonadep-6.18/build/out/arch/arm64/include/generated/asm/trace_clock.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/asm-generic/trace_clock.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/kallsyms.h \
    $(wildcard include/config/KALLSYMS_ALL) \
    $(wildcard include/config/KALLSYMS) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/buildid.h \
    $(wildcard include/config/STACKTRACE_BUILD_ID) \
    $(wildcard include/config/VMCORE_INFO) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/module.h \
    $(wildcard include/config/MODULES_TREE_LOOKUP) \
    $(wildcard include/config/ARCH_USES_CFI_TRAPS) \
    $(wildcard include/config/BPF_EVENTS) \
    $(wildcard include/config/EVENT_TRACING) \
    $(wildcard include/config/MODULE_UNLOAD) \
    $(wildcard include/config/CONSTRUCTORS) \
    $(wildcard include/config/FUNCTION_ERROR_INJECTION) \
    $(wildcard include/config/MITIGATION_RETPOLINE) \
    $(wildcard include/config/MODULE_SIG) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/kmod.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/umh.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/elf.h \
    $(wildcard include/config/ARCH_HAVE_EXTRA_ELF_NOTES) \
    $(wildcard include/config/ARCH_USE_GNU_PROPERTY) \
    $(wildcard include/config/ARCH_HAVE_ELF_PROT) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/elf.h \
    $(wildcard include/config/COMPAT_VDSO) \
  /home/venus/lemonadep-6.18/build/out/arch/arm64/include/generated/asm/user.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/asm-generic/user.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/uapi/linux/elf.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/uapi/linux/elf-em.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/moduleparam.h \
    $(wildcard include/config/ALPHA) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/rbtree_latch.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/error-injection.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/asm-generic/error-injection.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/dynamic_debug.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/module.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/asm-generic/module.h \
    $(wildcard include/config/HAVE_MOD_ARCH_SPECIFIC) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/ptrace.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/pid_namespace.h \
    $(wildcard include/config/MEMFD_CREATE) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/uapi/linux/ptrace.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/seccomp.h \
    $(wildcard include/config/HAVE_ARCH_SECCOMP_FILTER) \
    $(wildcard include/config/SECCOMP_FILTER) \
    $(wildcard include/config/CHECKPOINT_RESTORE) \
    $(wildcard include/config/SECCOMP_CACHE_DEBUG) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/uapi/linux/seccomp.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/seccomp.h \
  /home/venus/lemonadep-6.18/build/out/arch/arm64/include/generated/asm/unistd_compat_32.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/asm-generic/seccomp.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/uapi/linux/unistd.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/unistd.h \
  /home/venus/lemonadep-6.18/build/out/arch/arm64/include/generated/uapi/asm/unistd_64.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/ftrace.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/compat.h \
    $(wildcard include/config/ARCH_HAS_SYSCALL_WRAPPER) \
    $(wildcard include/config/X86_X32_ABI) \
    $(wildcard include/config/COMPAT_OLD_SIGACTION) \
    $(wildcard include/config/ODD_RT_SIGACTION) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/sem.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/uapi/linux/sem.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/ipc.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/rhashtable-types.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/uapi/linux/ipc.h \
  /home/venus/lemonadep-6.18/build/out/arch/arm64/include/generated/uapi/asm/ipcbuf.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/uapi/asm-generic/ipcbuf.h \
  /home/venus/lemonadep-6.18/build/out/arch/arm64/include/generated/uapi/asm/sembuf.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/uapi/asm-generic/sembuf.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/socket.h \
  /home/venus/lemonadep-6.18/build/out/arch/arm64/include/generated/uapi/asm/socket.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/uapi/asm-generic/socket.h \
  /home/venus/lemonadep-6.18/build/out/arch/arm64/include/generated/uapi/asm/sockios.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/uapi/asm-generic/sockios.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/uapi/linux/sockios.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/uio.h \
    $(wildcard include/config/ARCH_HAS_COPY_MC) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/uapi/linux/uio.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/uapi/linux/socket.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/uapi/linux/if.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/uapi/linux/libc-compat.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/uapi/linux/hdlc/ioctl.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/uapi/linux/aio_abi.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/syscall_wrapper.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/objpool.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/rethook.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/kprobes.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/asm-generic/kprobes.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/kgdb.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/asm-generic/cacheflush.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/kmsan.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/dma-direction.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/highmem-internal.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/device.h \
    $(wildcard include/config/GENERIC_MSI_IRQ) \
    $(wildcard include/config/ENERGY_MODEL) \
    $(wildcard include/config/PINCTRL) \
    $(wildcard include/config/ARCH_HAS_DMA_OPS) \
    $(wildcard include/config/DMA_DECLARE_COHERENT) \
    $(wildcard include/config/DMA_CMA) \
    $(wildcard include/config/SWIOTLB) \
    $(wildcard include/config/SWIOTLB_DYNAMIC) \
    $(wildcard include/config/ARCH_HAS_SYNC_DMA_FOR_DEVICE) \
    $(wildcard include/config/ARCH_HAS_SYNC_DMA_FOR_CPU) \
    $(wildcard include/config/ARCH_HAS_SYNC_DMA_FOR_CPU_ALL) \
    $(wildcard include/config/DMA_OPS_BYPASS) \
    $(wildcard include/config/DMA_NEED_SYNC) \
    $(wildcard include/config/IOMMU_DMA) \
    $(wildcard include/config/DEVTMPFS) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/dev_printk.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/energy_model.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/sched/cpufreq.h \
    $(wildcard include/config/CPU_FREQ) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/sched/topology.h \
    $(wildcard include/config/SCHED_CLUSTER) \
    $(wildcard include/config/SCHED_MC) \
    $(wildcard include/config/CPU_FREQ_GOV_SCHEDUTIL) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/sched/idle.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/sched/sd_flags.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/klist.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/pm.h \
    $(wildcard include/config/CXL_SUSPEND) \
    $(wildcard include/config/PM_CLK) \
    $(wildcard include/config/PM_GENERIC_DOMAINS) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/device/bus.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/device/class.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/device/devres.h \
    $(wildcard include/config/HAS_IOMEM) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/device/driver.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/arch/arm64/include/asm/device.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/pm_wakeup.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/pagevec.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/bio.h \
    $(wildcard include/config/BLK_DEV_ZONED) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/mempool.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/node.h \
    $(wildcard include/config/HMEM_REPORTING) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/pagemap.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/hugetlb_inline.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/uapi/linux/mempolicy.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/freezer.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/uapi/regulator/regulator.h \
  synaptics_tcm_core.h \
  /home/venus/lemonadep-6.18/build/out/include/generated/uapi/linux/version.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/input.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/uapi/linux/input.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/uapi/linux/input-event-codes.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/mod_devicetable.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/uapi/linux/mei.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/uapi/linux/mei_uuid.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/delay.h \
  /home/venus/lemonadep-6.18/build/out/arch/arm64/include/generated/asm/delay.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/asm-generic/delay.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/platform_device.h \
    $(wildcard include/config/HIBERNATE_CALLBACKS) \
    $(wildcard include/config/SUPERH) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/pinctrl/consumer.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/linux/pinctrl/pinctrl-state.h \
  include/linux/input/synaptics_tcm.h \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/drm/drm_panel.h \
    $(wildcard include/config/DRM_PANEL) \
    $(wildcard include/config/BACKLIGHT_CLASS_DEVICE) \
  /home/venus/lemonadep-6.18/work/lemonadep-6.18-kernel/include/uapi/linux/sched/types.h \

synaptics_tcm_core.o: $(deps_synaptics_tcm_core.o)

$(deps_synaptics_tcm_core.o):

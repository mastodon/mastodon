module ThreadSafe
  module Util
    FIXNUM_BIT_SIZE = (0.size * 8) - 2
    MAX_INT         = (2 ** FIXNUM_BIT_SIZE) - 1
    CPU_COUNT       = 16 # is there a way to determine this?

    autoload :AtomicReference, 'thread_safe/util/atomic_reference'
    autoload :Adder,           'thread_safe/util/adder'
    autoload :CheapLockable,   'thread_safe/util/cheap_lockable'
    autoload :PowerOfTwoTuple, 'thread_safe/util/power_of_two_tuple'
    autoload :Striped64,       'thread_safe/util/striped64'
    autoload :Volatile,        'thread_safe/util/volatile'
    autoload :VolatileTuple,   'thread_safe/util/volatile_tuple'
    autoload :XorShiftRandom,  'thread_safe/util/xor_shift_random'
  end
end

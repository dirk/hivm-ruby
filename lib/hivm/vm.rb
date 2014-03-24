module Hivm
  class VM < FFI::Struct
    layout :root,        :pointer,
           :top,         :pointer,
           :stack,       :pointer,
           :stack_depth, :uint,

           :exception, :pointer,
           :debug_entries, :pointer,
           :debug_entries_capacity, :ulong_long,
           :debug_entries_size, :ulong_long,

           :ip,          :ulong_long,
           :program,     :pointer,
           :program_capacity, :ulong_long,
           :program_size, :ulong_long
    
    def initialize
      vm = Hivm.hvm_new_vm()
      super(vm)
    end
    def bootstrap_primitives
      Hivm.hvm_bootstrap_primitives(self.to_ptr)
    end
    def run
      Hivm.hvm_vm_run(self.to_ptr)
    end
    def load_chunk chunk
      Hivm.hvm_vm_load_chunk(self.to_ptr, chunk.to_ptr)
    end
  end
end

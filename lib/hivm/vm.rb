module Hivm
  class VM < FFI::Struct
    layout :root,        :pointer,
           :top,         :pointer,
           :stack,       :pointer,
           :stack_depth, :uint,
           :ip,          :ulong_long
    
    def initialize
      vm = Hivm.hvm_new_vm()
      super(vm)
    end
  end
end

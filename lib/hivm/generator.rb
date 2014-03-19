module Hivm
  class Generator < FFI::Struct
    layout :block, :pointer
    
    def initialize(vm)
      @vm = vm
      gen = Hivm.hvm_new_gen()
      super(gen)
    end
    
    def block
      @block ||= Block.new(self, self[:block])
    end
    
    def to_chunk
      Chunk.new(self)
    end
    
    def method_missing symbol, *args
      if block.methods.include? symbol
        block.send symbol, *args
      end
    end
  end

  class Block < FFI::Struct
    layout :items, :pointer
    def initialize(gen, block = nil)
      @gen = gen
      block = Hivm.hvm_new_item_block() if block.nil?
      super(block)
    end

    def set_symbol reg, string
      Hivm.hvm_gen_set_symbol(self, reg, string)
    end
    def callsymbolic sym, ret
      Hivm.hvm_gen_callsymbolic(self.to_ptr, sym, ret)
    end
    def die
      Hivm.hvm_gen_die(self.to_ptr)
    end
  end

  
end

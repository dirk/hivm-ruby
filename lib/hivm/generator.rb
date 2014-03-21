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
      block.send symbol, *args
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
    def set_string reg, string
      Hivm.hvm_gen_set_string(self, reg, string)
    end
    def set_integer reg, int
      Hivm.hvm_gen_set_integer(self.to_ptr, reg, int)
    end
    def call dest, ret
      Hivm.hvm_gen_call(self.to_ptr, dest, ret)
    end
    def callsymbolic sym, ret
      Hivm.hvm_gen_callsymbolic(self.to_ptr, sym, ret)
    end
    def callprimitive sym, ret
      Hivm.hvm_gen_callprimitive(self.to_ptr, sym, ret)
    end
    def return reg
      Hivm.hvm_gen_return(self.to_ptr, reg)
    end
    def goto dest
      Hivm.hvm_gen_goto(self.to_ptr, dest)
    end
    def jump diff
      Hivm.hvm_gen_jump(self.to_ptr, diff)
    end
    def die
      Hivm.hvm_gen_die(self.to_ptr)
    end
    def noop
      Hivm.hvm_gen_noop(self.to_ptr)
    end

    def label name
      Hivm.hvm_gen_label(self.to_ptr, name)
    end
    def goto_label name
      Hivm.hvm_gen_goto_label(self.to_ptr, name)
    end
    def sub name
      Hivm.hvm_gen_sub(self.to_ptr, name)
    end
    def call_sub name, ret
      Hivm.hvm_gen_call_sub self.to_ptr, name, ret
    end

    def getlocal val_reg, sym_reg
      Hivm.hvm_gen_getlocal(self.to_ptr, val_reg, sym_reg)
    end
    def setlocal sym_reg, val_reg
      Hivm.hvm_gen_setlocal(self.to_ptr, sym_reg, val_reg)
    end

    def getglobal val_reg, sym_reg
      Hivm.hvm_gen_getglobal(self.to_ptr, val_reg, sym_reg)
    end
    def setglobal sym_reg, val_reg
      Hivm.hvm_gen_setglobal(self.to_ptr, sym_reg, val_reg)
    end

    def structnew reg
      Hivm.hvm_gen_structnew(self.to_ptr, reg)
    end
    def structget reg, struct, key
      Hivm.hvm_gen_structget(self.to_ptr, reg, struct, key)
    end
    def structset struct, key, val
      Hivm.hvm_gen_structset(self.to_ptr, struct, key, val)
    end

    def litinteger reg, int
      Hivm.hvm_gen_litinteger(self.to_ptr, reg, int)
    end

    def move dest, src
      Hivm.hvm_gen_move(self.to_ptr, dest, src)
    end

    def push_block push
      Hivm.hvm_gen_push_block self.to_ptr, push.to_ptr
    end

  end# Generator
end# Hivm

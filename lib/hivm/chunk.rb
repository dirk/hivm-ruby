module Hivm
  class Chunk < FFI::Struct
    layout :relocs, :pointer
    def initialize(gen)
      chunk = Hivm.hvm_gen_chunk(gen.to_ptr)
      super(chunk)
    end
    def disassemble
      Hivm.hvm_chunk_disassemble(self.to_ptr)
    end
  end
end
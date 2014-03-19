require 'ffi'

require 'hivm/version'
require 'hivm/vm'
require 'hivm/generator'
require 'hivm/chunk'

module Hivm
  extend FFI::Library
  begin
    ffi_lib HIVM_LIB
  rescue NameError
    ffi_lib 'libhivm.so'
  end
  
  
  attach_function :hvm_new_gen, [], :pointer
  attach_function :hvm_new_item_block, [], :pointer
  # Generator methods
  attach_function :hvm_gen_set_symbol, [:pointer, :uchar, :string], :void
  attach_function :hvm_gen_chunk, [:pointer], :pointer
  attach_function :hvm_gen_callsymbolic, [:pointer, :uchar, :uchar], :void
  attach_function :hvm_gen_die, [:pointer], :void
  
  # Chunk methods
  attach_function :hvm_chunk_disassemble, [:pointer], :void
  
  attach_function :hvm_new_vm, [], :pointer
  
  attach_function :hvm_vm_reg_gen, [:uchar], :uchar
  
  def self.general_register i
    hvm_vm_reg_gen i
  end
  
end

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
  attach_function :hvm_gen_set_file, [:pointer, :string], :void
  attach_function :hvm_new_item_block, [], :pointer
  # Generator methods
  attach_function :hvm_gen_set_string, [:pointer, :uchar, :string], :void
  attach_function :hvm_gen_set_symbol, [:pointer, :uchar, :string], :void
  attach_function :hvm_gen_set_integer, [:pointer, :uchar, :ulong_long], :void
  
  attach_function :hvm_gen_chunk, [:pointer], :pointer
  
  attach_function :hvm_gen_noop, [:pointer], :void
  attach_function :hvm_gen_die,  [:pointer], :void
  attach_function :hvm_gen_jump, [:pointer, :int], :void
  attach_function :hvm_gen_goto, [:pointer, :ulong_long], :void
  attach_function :hvm_gen_call, [:pointer, :ulong_long, :uchar], :void
  attach_function :hvm_gen_callsymbolic,  [:pointer, :uchar, :uchar], :void
  attach_function :hvm_gen_callprimitive, [:pointer, :uchar, :uchar], :void
  attach_function :hvm_gen_return, [:pointer, :uchar], :void
  attach_function :hvm_gen_move, [:pointer, :uchar, :uchar], :void

  attach_function :hvm_gen_getlocal,  [:pointer, :uchar, :uchar], :void
  attach_function :hvm_gen_setlocal,  [:pointer, :uchar, :uchar], :void
  attach_function :hvm_gen_getglobal, [:pointer, :uchar, :uchar], :void
  attach_function :hvm_gen_setglobal, [:pointer, :uchar, :uchar], :void
  
  attach_function :hvm_gen_litinteger, [:pointer, :uchar, :ulong_long], :void
  
  attach_function :hvm_gen_label, [:pointer, :string], :void
  attach_function :hvm_gen_goto_label, [:pointer, :string], :void
  attach_function :hvm_gen_sub, [:pointer, :string], :void
  attach_function :hvm_gen_call_sub, [:pointer, :string, :uchar], :void
  
  attach_function :hvm_gen_structnew, [:pointer, :uchar], :void
  attach_function :hvm_gen_structget, [:pointer, :uchar, :uchar, :uchar], :void
  attach_function :hvm_gen_structset, [:pointer, :uchar, :uchar, :uchar], :void

  attach_function :hvm_gen_arraynew, [:pointer, :uchar, :uchar], :void
  attach_function :hvm_gen_arrayset, [:pointer, :uchar, :uchar, :uchar], :void
  attach_function :hvm_gen_arrayget, [:pointer, :uchar, :uchar, :uchar], :void

  attach_function :hvm_gen_push_block, [:pointer, :pointer], :void

  attach_function :hvm_gen_add, [:pointer, :uchar, :uchar, :uchar], :void
  attach_function :hvm_gen_eq, [:pointer, :uchar, :uchar, :uchar], :void
  attach_function :hvm_gen_lt, [:pointer, :uchar, :uchar, :uchar], :void
  attach_function :hvm_gen_gt, [:pointer, :uchar, :uchar, :uchar], :void
  attach_function :hvm_gen_if_label, [:pointer, :uchar, :string], :void

  # Chunk methods
  attach_function :hvm_chunk_disassemble, [:pointer], :void
  
  attach_function :hvm_new_vm, [], :pointer
  attach_function :hvm_vm_run, [:pointer], :void
  attach_function :hvm_vm_load_chunk, [:pointer, :pointer], :void
  attach_function :hvm_bootstrap_primitives, [:pointer], :void
  
  attach_function :hvm_vm_reg_gen, [:uchar], :uchar
  attach_function :hvm_vm_reg_arg, [:uchar], :uchar
  attach_function :hvm_vm_reg_param, [:uchar], :uchar
  attach_function :hvm_vm_reg_null, [], :uchar

  attach_function :hvm_print_data, [:pointer, :ulong_long], :void
  
  attach_function :hvm_gen_set_debug_line, [:pointer, :ulong_long], :void
  attach_function :hvm_gen_set_debug_entry, [:pointer, :ulong_long, :string], :void
  attach_function :hvm_gen_set_debug_flags, [:pointer, :uchar], :void
  
  attach_variable :DEBUG_FLAG_HIDE_BACKTRACE, :HVM_DEBUG_FLAG_HIDE_BACKTRACE, :uchar
  
  def self.null_register; hvm_vm_reg_null; end
  def self.general_register i
    hvm_vm_reg_gen i
  end
  def self.arg_register i
    hvm_vm_reg_arg i
  end
  def self.param_register i
    hvm_vm_reg_param i
  end
end

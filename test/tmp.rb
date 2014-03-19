HIVM_LIB = File.join(File.dirname(__FILE__), '..', '..', 'hivm', 'libhivm.so')

require 'rubygems'
require 'bundler'
Bundler.require

vm = Hivm::VM.new
gen = Hivm::Generator.new vm

gen.set_symbol Hivm.general_register(1), "_test"
gen.callsymbolic Hivm.general_register(1), Hivm.general_register(2)
gen.die

chunk = gen.to_chunk()
chunk.disassemble

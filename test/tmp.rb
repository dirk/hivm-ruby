HIVM_LIB = File.join(File.dirname(__FILE__), '..', '..', 'hivm', 'libhivm.so')

require 'rubygems'
require 'bundler'
Bundler.require

vm = Hivm::VM.new
vm.bootstrap_primitives
gen = Hivm::Generator.new vm

# gen.set_symbol Hivm.general_register(1), "_test"
# gen.callsymbolic Hivm.general_register(1), Hivm.general_register(2)

gen.set_string Hivm.arg_register(0), "Hello world!\n"
gen.set_symbol Hivm.general_register(0), "print"
gen.callprimitive Hivm.general_register(0), Hivm.null_register
gen.die

chunk = gen.to_chunk()
chunk.disassemble


vm.load_chunk(chunk)
vm.run

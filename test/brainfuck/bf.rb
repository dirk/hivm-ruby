HIVM_LIB = File.join(File.dirname(__FILE__), '..', '..', '..', 'hivm', 'libhivm.so')

require 'rubygems'
# Development load-paths
$:.unshift File.join(File.dirname(__FILE__), "..", '..', "..", "hivm-ruby", "lib")
$:.unshift File.join(File.dirname(__FILE__), '..', '..', 'lib')
require 'hijinks'


class Parser
  attr_reader :iseq
  def self.parse i
    new.parse! i
  end
  def parse! input
    @bracket_stack = []
    @iseq = []
    input.each_char do |char|
      next unless '<>[]+-.,'.include? char
      case char
      when '+'
        @iseq << [:incr]
      when '-'
        @iseq << [:decr]
      when '>'
        @iseq << [:ptr_incr]
      when '<'
        @iseq << [:ptr_decr]
      when '.'
        @iseq << [:out]
      when ','
        @iseq << [:in]
      when '['
        # Push the index onto the bracket stack
        idx = @iseq.length
        @bracket_stack << idx
        @iseq << [:lb, idx]
      when ']'
        idx = @bracket_stack.pop
        @iseq << [:rb, idx]
      end
    end
    return self
  end
end

class Compiler
  def compile! iseq, gen
    b = Hivm::Block.new gen
    @cells    = Hivm.general_register 10
    @cell_ptr = Hivm.general_register 11
    self.bootstrap b
    b.litinteger @cell_ptr, 0
    # Compile all the instructions
    iseq.each do |i|
      instr = i.first
      args  = i.slice 1, i.length
      self.send instr, *([b] + args)
    end
    b.die
    gen.push_block b
  end
  def bootstrap b
    # Allocate our 30,000 byte cells
    z    = Hivm.general_register 0
    int  = Hivm.general_register 2
    max  = Hivm.general_register 3
    zero = Hivm.general_register 4
    b.litinteger max, 30000
    b.litinteger int, 0
    b.litinteger zero, 0
    # Create the array
    b.arraynew @cells, max
    # Loop to set all to zero
    b.label "cell_loop_start"
    b.eq z, int, max # z = int == max
    b.if_label z, "cell_loop_end"
    # Set the cell at int to zero
    b.arrayset @cells, int, zero
    # Increment and return to the head
    b.litinteger z, 1
    b.add int, int, z
    b.goto_label "cell_loop_start"
    b.label "cell_loop_end"

    b.goto_label "end"
    val = Hivm.general_register 1
    # Needed subroutines
    # Increment
    b.sub "incr"
    b.litinteger int, 255
    b.move val, Hivm.param_register(0)
    b.eq z, val, int # z = val == 255
    b.if_label z, "incr_overflow"
    b.litinteger z, 1
    b.add val, val, z
    b.return val
    b.label "incr_overflow"
    b.litinteger val, 0
    b.return val

    # Decrement
    b.sub "decr"
    b.litinteger int, 0
    b.move val, Hivm.param_register(0)
    b.eq z, val, int # z = val == 0
    b.if_label z, "decr_underflow"
    b.litinteger z, -1
    b.add val, val, z
    b.return val
    b.label "decr_underflow"
    b.litinteger val, 255
    b.return val

    b.label "end"
  end

  def lb b, dest
    left  = "label_#{dest.to_s}_left"
    right = "label_#{dest.to_s}_right"

    z    = Hivm.general_register 0
    zero = Hivm.general_register 1
    val  = Hivm.general_register 2
    b.litinteger zero, 0
    b.arrayget val, @cells, @cell_ptr
    b.eq z, val, zero # z = val == 0
    b.if_label z, right
    b.label left
  end
  def rb b, dest
    left  = "label_#{dest.to_s}_left"
    right = "label_#{dest.to_s}_right"
    # If greater than zero
    z    = Hivm.general_register 0
    zero = Hivm.general_register 1
    val  = Hivm.general_register 2
    b.litinteger zero, 0
    b.arrayget val, @cells, @cell_ptr
    b.gt z, val, zero # z = val > zero
    b.if_label z, left
    b.label right
  end
  
  def ptr_incr b
    z = Hivm.general_register 0
    b.litinteger z, 1
    b.add @cell_ptr, @cell_ptr, z
  end
  def ptr_decr b
    z = Hivm.general_register 0
    b.litinteger z, -1
    b.add @cell_ptr, @cell_ptr, z
  end

  def incr b
    val = Hivm.general_register 0
    b.arrayget Hivm.arg_register(0), @cells, @cell_ptr
    # Call the increment subroutine
    b.call_sub "incr", val
    b.arrayset @cells, @cell_ptr, val
  end
  def decr b
    val = Hivm.general_register 0
    b.arrayget Hivm.arg_register(0), @cells, @cell_ptr
    # Call the increment subroutine
    b.call_sub "decr", val
    b.arrayset @cells, @cell_ptr, val
  end
  
  def out b
    z = Hivm.general_register 0
    b.arrayget Hivm.arg_register(0), @cells, @cell_ptr
    b.set_symbol z, "print_char"
    b.callprimitive z, Hivm.null_register
  end
end

hello_world = "
+++++ +++               Set Cell #0 to 8
[
    >++++               Add 4 to Cell #1; this will always set Cell #1 to 4
    [                   as the cell will be cleared by the loop
        >++             Add 4*2 to Cell #2
        >+++            Add 4*3 to Cell #3
        >+++            Add 4*3 to Cell #4
        >+              Add 4 to Cell #5
        <<<<-           Decrement the loop counter in Cell #1
    ]                   Loop till Cell #1 is zero
    >+                  Add 1 to Cell #2
    >+                  Add 1 to Cell #3
    >-                  Subtract 1 from Cell #4
    >>+                 Add 1 to Cell #6
    [<]                 Move back to the first zero cell you find; this will
                        be Cell #1 which was cleared by the previous loop
    <-                  Decrement the loop Counter in Cell #0
]                       Loop till Cell #0 is zero
 
The result of this is:
Cell No :   0   1   2   3   4   5   6
Contents:   0   0  72 104  88  32   8
Pointer :   ^
 
>>.                     Cell #2 has value 72 which is 'H'
>---.                   Subtract 3 from Cell #3 to get 101 which is 'e'
+++++ ++..+++.          Likewise for 'llo' from Cell #3
>>.                     Cell #5 is 32 for the space
<-.                     Subtract 1 from Cell #4 for 87 to give a 'W'
<.                      Cell #3 was set to 'o' from the end of 'Hello'
+++.----- -.----- ---.  Cell #3 for 'rl' and 'd'
>>+.                    Add 1 to Cell #5 gives us an exclamation point
>++.                    And finally a newline from Cell #6
"



vm = Hivm::VM.new
vm.bootstrap_primitives
gen = Hivm::Generator.new vm

# Parse the program and generate the code
parse   = Parser.parse hello_world
program = Compiler.new.compile! parse.iseq, gen

chunk = gen.to_chunk
chunk.disassemble
vm.load_chunk chunk
vm.run

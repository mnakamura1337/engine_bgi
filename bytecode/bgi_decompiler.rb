#!/usr/bin/env ruby

require_relative 'bgi_compiled_script'
require_relative 'bgi_bytecode'

class BGIDecompiler

  class CheckNote
    attr_reader :cond_id
    def initialize(cond_id)
      @cond_id = cond_id
    end

    def inspect
      "CheckNote(#{@cond_id.inspect})"
    end
  end

  class Mul
    attr_reader :a1, :a2
    def initialize(a1, a2)
      @a1 = a1
      @a2 = a2
    end

    def inspect
      "*(#{@a1.inspect}, #{@a2.inspect})"
    end
  end

  class Address
    attr_reader :a
    def initialize(a)
      @a = a
    end

    def inspect
      sprintf("addr=0x%x", @a)
    end
  end

  def initialize(filename)
    @sub_by_addr = {}
    begin
      @bs = BgiCompiledScript.from_file(filename)
      @bs._read

      # Create sub addr => name mapping
      @bs.subs.each { |sub|
        @sub_by_addr[sub.addr] = sub.name
      }

      @b = @bs.body
    rescue Kaitai::Struct::Stream::UnexpectedDataError => e
      # It's not a BgiCompiledScript, try raw bytecode
      @bs = nil
      @b = BgiBytecode.from_file(filename)
      @b._read
    end
  end

  def each
    @args = []

    @b.bytecode.entries.each { |i|
      if i.op_debug_info
        unless @args.empty?
          print '??? '
          output
        end
        o = i.op_debug_info
        puts if @need_nl
        printf "0x%06x:<%s:%4d>", i._debug['opcode'][:start] + 0x1c, o.file_name, o.line_num
        @need_nl = true
      elsif i.op_int
        #printf "(%d) ", i.op_int.val
        @args << i.op_int.val
      elsif i.op_addr
        @args << Address.new(i.op_addr.val)
      elsif i.opcode == 0x22
        @args << Mul.new(@args.pop, @args.pop)
      elsif i.opcode == 2
        @args << 'arg2'
      elsif i.opcode == 0xe7
        @args << CheckNote.new(@args.pop)
      elsif i.opcode == 0x1a
        print 'call '
        sub_addr = @args.pop
        sub_name = @sub_by_addr[sub_addr.a]
        print sub_name ? sub_name : sub_addr.inspect
        print ' '
        output
      elsif i.op_str
        #print i.op_str.str.inspect
        #print ' '
        @args << i.op_str.str.encode('UTF-8')
      elsif BgiBytecode::OPCODES[i.opcode]
        op_sym = BgiBytecode::OPCODES[i.opcode]
        op_name = op_sym.to_s.gsub(/^opcodes_/, '')
        print "#{op_name} "
        output
      else
        printf "@%04x ", i.opcode
        output
      end
    }

    output
  end

  def output
    puts @args.inspect
    @need_nl = false
    @args = []
  end
end


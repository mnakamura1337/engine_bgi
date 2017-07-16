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
      if !@bs.respond_to?(:_debug)
        raise ".ksy templates must be compiled with --debug (using :start offset info)"
      end
      @bs._read

      # Create sub addr => name mapping
      @bs.subs.each { |sub|
        @sub_by_addr[sub.addr] = sub.name
      }

      @b = @bs.body
    rescue Kaitai::Struct::Stream::UnexpectedDataError => e
      print e
      # It's not a BgiCompiledScript, try raw bytecode
      @bs = nil
      @b = BgiBytecode.from_file(filename)
      @b._read
    end
  end

  def each(&block)
    @block = block
    @args = []

    @b.bytecode.entries.each { |i|
      if i.op_debug_info
        output('???') unless @args.empty?

        o = i.op_debug_info
        @cur_addr = i._debug['opcode'][:start] + 0x1c
        @cur_filename = o.file_name
        @cur_line_num = o.line_num
      elsif i.op_int
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
        sub_addr = @args.pop
        sub_name = @sub_by_addr[sub_addr.a]
        output([:call, sub_name ? sub_name : sub_addr.inspect])
      elsif i.op_str
        @args << i.op_str.str.encode('UTF-8')
      elsif BgiBytecode::OPCODES[i.opcode]
        op_sym = BgiBytecode::OPCODES[i.opcode]
        op_name = op_sym.to_s.gsub(/^opcodes_/, '')
        output(op_name)
      else
        output(i.opcode)
      end
    }

    output('leftover') unless @args.empty?
  end

  def output(op)
    @block.call(@cur_addr, @cur_filename, @cur_line_num, op, @args)
    @cur_addr = nil
    @cur_filename = nil
    @cur_line_num = nil
    @args = []
  end
end


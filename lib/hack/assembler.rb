require 'tempfile'
require 'pathname'
require 'fileutils'

module Hack
  class Assembler
    def self.assemble(input_filename)
      File.open(input_filename) do |input|
        with_tempfile(input_filename) do |output|
          self.new(input, output).assemble
        end
      end
    end

    def self.with_tempfile(input_filename)
      input_pathname = Pathname.new(input_filename)
      basename = input_pathname.basename('.asm')
      output_filename = input_pathname.dirname.join("My#{basename}.hack")

      Tempfile.open('hack_assembler', '/tmp') do |output|
        yield output
        FileUtils.mv(output.path, output_filename)
        ObjectSpace.undefine_finalizer(output)
      end
    end

    attr_reader :input, :output, :parser, :symbol_table

    def initialize(input, output)
      @input = input
      @output = output
      @parser = Parser.new(input)
      @symbol_table = SymbolTable.new
    end

    def assemble
      first_pass
      parser.rewind
      second_pass
    end

    def first_pass
      instruction_number = 0

      while parser.more_commands?
        parser.advance
        case parser.command_type
        when :a
          instruction_number += 1
        when :c
          instruction_number += 1
        when :l
          symbol_table[parser.symbol] = instruction_number
        else
          raise "Unknown command type: #{parser.command_type}"
        end
      end
    end

    def second_pass
      while parser.more_commands?
        parser.advance
        case parser.command_type
        when :a
          a_instruction
        when :c
          c_instruction
        when :l
          # no-op
        else
          raise "Unknown command type: #{parser.command_type}"
        end
      end
    end

    def a_instruction
      output.puts(symbol_to_address(parser.symbol))
    end

    def c_instruction
      output.puts(
        "111" +
        CodeGenerator.comp(parser.comp) +
        CodeGenerator.dest(parser.dest) +
        CodeGenerator.jump(parser.jump)
      )
    end

    def symbol_to_address(symbol)
      format_address(Integer(symbol))
    rescue ArgumentError
      symbol_table.allocate_variable(symbol) unless symbol_table.key?(symbol)
      format_address(symbol_table[symbol])
    end

    def format_address(integer)
      "0" + integer.to_s(2).rjust(15, '0')
    end
  end
end

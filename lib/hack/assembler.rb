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

    attr_reader :input, :output, :parser

    def initialize(input, output)
      @input = input
      @output = output
      @parser = Parser.new(input)
    end

    def assemble
      while parser.more_commands?
        parser.advance
        case parser.command_type
        when :a
          a_instruction
        when :c
          c_instruction
        when :l
          l_instruction
        else
          raise "Unknown command type: #{parser.command_type}"
        end
      end
    end

    def a_instruction
      output.puts("0" + Integer(parser.symbol).to_s(2).rjust(15, '0'))
    end

    def c_instruction
      output.puts(
        "111" +
        CodeGenerator.comp(parser.comp) +
        CodeGenerator.dest(parser.dest) +
        CodeGenerator.jump(parser.jump)
      )
    end

    def l_instruction
      raise NotImplementedError
    end
  end
end

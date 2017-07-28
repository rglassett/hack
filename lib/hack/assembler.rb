module Hack
  class Assembler
    def self.assemble(input_filename)
      output_filename =
        File.dirname(input_filename) +
        File::SEPARATOR +
        'My' +
        File.basename(input_filename, '.asm') +
        '.hack'

      File.open(input_filename) do |input|
        File.open(output_filename, 'w') do |output|
          self.new(input, output).assemble
        end
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

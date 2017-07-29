module Hack
  class Assembler
    attr_reader :input, :output, :parser, :symbol_table

    def initialize(input, output)
      @input = input
      @output = output
      @parser = Parser.new(input)
      @symbol_table = SymbolTable.new
    end

    def assemble
      first_pass
      second_pass
    end

    def first_pass
      instruction_number = 0

      parser.each_instruction do |instruction|
        case instruction
        when AInstruction
          instruction_number += 1
        when CInstruction
          instruction_number += 1
        when LInstruction
          symbol_table[instruction.symbol] = instruction_number
        else
          raise "Unknown instruction type: #{instruction.class.name}"
        end
      end
    end

    def second_pass
      parser.each_instruction do |instruction|
        case instruction
        when AInstruction, CInstruction
          output.puts(CodeGenerator.to_hack(instruction, symbol_table))
        when LInstruction
          # no-op
        else
          raise "Unknown instruction type: #{instruction.class.name}"
        end
      end
    end
  end
end

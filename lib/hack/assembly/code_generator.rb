module Hack
  module Assembly
    class CodeGenerator
      COMP_MNEMONICS = {
        '0' =>   '0101010',
        '1' =>   '0111111',
        '-1' =>  '0111010',
        'D' =>   '0001100',
        'A' =>   '0110000',
        'M' =>   '1110000',
        '!D' =>  '0001101',
        '!A' =>  '0110001',
        '!M' =>  '1110001',
        '-D' =>  '0001111',
        '-A' =>  '0110011',
        '-M' =>  '1110011',
        'D+1' => '0011111',
        'A+1' => '0110111',
        'M+1' => '1110111',
        'D-1' => '0001110',
        'A-1' => '0110010',
        'M-1' => '1110010',
        'D+A' => '0000010',
        'D+M' => '1000010',
        'D-A' => '0010011',
        'D-M' => '1010011',
        'A-D' => '0000111',
        'M-D' => '1000111',
        'D&A' => '0000000',
        'D&M' => '1000000',
        'D|A' => '0010101',
        'D|M' => '1010101'
      }

      def self.to_hack(instruction, symbol_table)
        case instruction
        when AInstruction
          a_instruction(instruction, symbol_table)
        when CInstruction
          c_instruction(instruction, symbol_table)
        else
          raise "Unhandled instruction: #{instruction.inspect}"
        end
      end

      def self.a_instruction(instruction, symbol_table)
        "0" + address(instruction.symbol, symbol_table).to_s(2).rjust(15, '0')
      end

      def self.c_instruction(instruction, _symbol_table)
        '111' +
          comp(instruction.comp) +
          dest(instruction.dest) +
          jump(instruction.jump)
      end

      def self.dest(mnemonic)
        dest = '000'
        dest[0] = '1' if mnemonic =~ /A/
        dest[1] = '1' if mnemonic =~ /D/
        dest[2] = '1' if mnemonic =~ /M/
        dest
      end

      def self.comp(mnemonic)
        COMP_MNEMONICS.fetch(mnemonic) do
          raise ArgumentError.new("Invalid comp mnemonic: #{mnemonic}")
        end
      end

      def self.jump(mnemonic)
        jump = '000'
        jump[0] = '1' if mnemonic =~ /J(LT|LE|NE|MP)/
        jump[1] = '1' if mnemonic =~ /J(EQ|GE|LE|MP)/
        jump[2] = '1' if mnemonic =~ /J(GT|GE|NE|MP)/
        jump
      end

      private

      def self.address(symbol, symbol_table)
        Integer(symbol)
      rescue ArgumentError
        symbol_table[symbol]
      end
    end
  end
end

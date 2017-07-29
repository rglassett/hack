module Hack
  class SymbolTable
    PRIMITIVES = Set.new(['A', 'D', 'M'])

    PRESETS = {
      'SP'     => 0,
      'LCL'    => 1,
      'ARG'    => 2,
      'THIS'   => 3,
      'THAT'   => 4,
      'R0'     => 0,
      'R1'     => 1,
      'R2'     => 2,
      'R3'     => 3,
      'R4'     => 4,
      'R5'     => 5,
      'R6'     => 6,
      'R7'     => 7,
      'R8'     => 8,
      'R9'     => 9,
      'R10'    => 10,
      'R11'    => 11,
      'R12'    => 12,
      'R13'    => 13,
      'R14'    => 14,
      'R15'    => 15,
      'SCREEN' => 16384,
      'KBD'    => 24576,
    }

    attr_reader :next_address, :table

    def initialize
      @table = PRESETS.dup
      @next_address = 16
    end

    def [](symbol)
      allocate_variable!(symbol) unless key?(symbol)
      @table[symbol]
    end

    def []=(symbol, address)
      validate_symbol!(symbol)
      @table[symbol] = address
    end

    def key?(symbol)
      @table.key?(symbol)
    end

    private

    def allocate_variable!(symbol)
      validate_address!(next_address)
      self[symbol] = next_address
      @next_address += 1
    end

    def validate_address!(address)
      if address >= PRESETS['SCREEN']
        raise "Symbol table overflow: no memory left to allocate"
      end
    end

    def validate_symbol!(symbol)
      if key?(symbol)
        raise "Variable or label already allocated: #{symbol}"
      elsif PRIMITIVES.include?(symbol)
        raise "Symbol conflicts with primitive name: #{symbol}"
      end
    end
  end
end

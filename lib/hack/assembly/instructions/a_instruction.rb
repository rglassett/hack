module Hack
  module Assembly
    class AInstruction < Instruction
      MATCHER = /\A@#{SYMBOL}\z/

      data_reader :symbol
    end
  end
end

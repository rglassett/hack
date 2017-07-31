module Hack
  module Assembly
    class LInstruction < Instruction
      MATCHER = /\A\(#{SYMBOL}\)\z/

      data_reader :symbol
    end
  end
end

module Hack
  class LInstruction < Instruction
    MATCHER = /\A\(#{SYMBOL}\)\z/

    data_reader :symbol
  end
end

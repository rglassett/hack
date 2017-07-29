module Hack
  class AInstruction < Instruction
    MATCHER = /\A@#{SYMBOL}\z/

    data_reader :symbol
  end
end

module Hack
  class CInstruction < Instruction
    OPERAND = /[ADM01]/
    OPERATOR = /[\!\+\-\&\|]/

    DEST = /((?<dest>[ADM]{1,3})=){0,1}/
    JUMP = /(;(?<jump>J(GT|EQ|GE|LT|NE|LE|MP))){0,1}/
    COMP = /(?<comp>(#{OPERAND}){0,1}(#{OPERATOR}{0,1})(#{OPERAND}){1})/

    MATCHER = /\A#{DEST}#{COMP}#{JUMP}\z/

    data_reader :comp, :dest, :jump
  end
end

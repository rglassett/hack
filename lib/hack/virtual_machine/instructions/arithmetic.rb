module Hack
  module VirtualMachine
    class Arithmetic < Instruction
      MATCHER = /(?<command>add|sub|neg|eq|gt|lt|and|or|not)/

      data_reader :command
    end
  end
end

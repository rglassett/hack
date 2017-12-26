module Hack
  module VirtualMachine
    module Memory
      class FixedSegment
        attr_reader :range

        def initialize(range)
          @range = range
        end

        def read_from(index)
          validate!(index)

          <<~ASM
          @R#{base + Integer(index)}
          D=M
          ASM
        end

        def write_to(index)
          validate!(index)

          <<~ASM
          @R#{base + Integer(index)}
          M=D
          ASM
        end

        def base
          range.first
        end

        def validate!(relative_index)
          absolute_index = range.first + Integer(relative_index)
          raise IndexError.new unless range.cover?(absolute_index)
        end
      end
    end
  end
end

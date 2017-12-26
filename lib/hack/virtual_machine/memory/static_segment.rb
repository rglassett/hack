module Hack
  module VirtualMachine
    module Memory
      class StaticSegment
        attr_reader :range, :progname

        def initialize(range, progname)
          @range = range
          @progname = progname
        end

        def base
          range.first
        end

        def read_from(index)
          <<~ASM
            @Prg.#{progname}.#{index}
            D=M
          ASM
        end

        def write_to(index)
          <<~ASM
            @Prg.#{progname}.#{index}
            M=D
          ASM
        end
      end
    end
  end
end

module Hack
  module VirtualMachine
    module Memory
      class HeapSegment
        attr_reader :base

        def initialize(base)
          @base = base
        end

        def read_from(index)
          <<-ASM.strip_heredoc
            @#{base}
            D=M
            @#{index}
            A=A+D
            D=M
          ASM
        end

        def write_to(index)
          <<-ASM.strip_heredoc
            @R13
            M=D
            @#{base}
            D=M
            @#{index}
            D=A+D
            @R14
            M=D
            @R13
            D=M
            @R14
            A=M
            M=D
          ASM
        end
      end
    end
  end
end

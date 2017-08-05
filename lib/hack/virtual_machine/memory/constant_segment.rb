module Hack
  module VirtualMachine
    module Memory
      class ConstantSegment
        def read_from(index)
          <<-ASM.strip_heredoc
            @#{index}
            D=A
          ASM
        end

        def write_to(index)
          ''
        end
      end
    end
  end
end

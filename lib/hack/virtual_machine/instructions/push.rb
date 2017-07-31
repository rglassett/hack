module Hack
  module VirtualMachine
    class Push < Instruction
      MATCHER = /push\s*#{MEMORY_ADDRESS}/

      data_reader :segment, :index
    end
  end
end

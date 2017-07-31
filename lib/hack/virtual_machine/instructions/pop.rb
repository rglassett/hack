module Hack
  module VirtualMachine
    class Pop < Instruction
      MATCHER = /pop\s*#{MEMORY_ADDRESS}/

      data_reader :segment, :index
    end
  end
end

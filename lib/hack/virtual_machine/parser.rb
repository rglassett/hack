module Hack
  module VirtualMachine
    class Parser
      attr_reader :io_device, :instruction

      def initialize(io_device)
        @io_device = io_device
      end

      def each_instruction
        return enum_for(:each_instruction) unless block_given?

        until io_device.eof?
          advance
          yield instruction
        end

        io_device.rewind
      end

      def advance
        raw_instruction = Instruction.sanitize(io_device.readline)

        while (raw_instruction.nil? || raw_instruction.empty?) && !io_device.eof?
          raw_instruction = Instruction.sanitize(io_device.readline)
        end

        @instruction = Instruction.sanitize(raw_instruction)
        # @instruction = Instruction.parse(raw_instruction)
      end
    end
  end
end

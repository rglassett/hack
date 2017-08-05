module Hack
  module VirtualMachine
    class Ram
      attr_reader :segments

      def initialize(progname)
        @segments = Hash.new do |hash, key|
          raise KeyError.new("Unknown memory segment #{key}") unless hash[key]
        end

        @segments.merge!(
          'constant' => Memory::ConstantSegment.new,
          'local'    => Memory::HeapSegment.new('LCL'),
          'argument' => Memory::HeapSegment.new('ARG'),
          'this'     => Memory::HeapSegment.new('THIS'),
          'that'     => Memory::HeapSegment.new('THAT'),
          'pointer'  => Memory::FixedSegment.new(3..4),
          'temp'     => Memory::FixedSegment.new(5..12),
          'static'   => Memory::StaticSegment.new(16..255, progname),
        )
      end

      def read_from(segment, index)
        segments[segment].read_from(index)
      end

      def write_to(segment, index)
        segments[segment].write_to(index)
      end
    end
  end
end

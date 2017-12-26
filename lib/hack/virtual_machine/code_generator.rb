module Hack
  module VirtualMachine
    class CodeGenerator
      attr_reader :label_count, :memory

      def initialize(progname, label_count=0)
        @label_count = label_count
        @memory = Hack::VirtualMachine::Ram.new(progname)
      end

      def generate(instruction)
        instruction_type = instruction.class.name.split('::').last.downcase
        public_send("write_#{instruction_type}", instruction)
      end

      def finalize
        <<~ASM
          (VM.End)
          @VM.End
          0;JMP
        ASM
      end

      def write_arithmetic(instruction)
        public_send("write_#{instruction.command}")
      end

      def write_add
        binary_operation('M=D+M')
      end

      def write_sub
        binary_operation('M=M-D')
      end

      def write_and
        binary_operation('M=D&M')
      end

      def write_or
        binary_operation('M=D|M')
      end

      def write_neg
        unary_operation('M=-M')
      end

      def write_not
        unary_operation('M=!M')
      end

      def write_eq
        comparison_operation('JEQ')
      end

      def write_gt
        comparison_operation('JGT')
      end

      def write_lt
        comparison_operation('JLT')
      end

      def write_push(instruction)
        memory.read_from(instruction.segment, instruction.index) + push_from_d
      end

      def write_pop(instruction)
        pop_to_d + memory.write_to(instruction.segment, instruction.index)
      end

      def binary_operation(operation)
        <<~ASM
          @SP
          A=M-1
          D=M
          M=0
          A=A-1
          #{operation}
          @SP
          M=M-1
        ASM
      end

      def unary_operation(operation)
        <<~ASM
          @SP
          A=M-1
          #{operation}
        ASM
      end

      def comparison_operation(jump_mnemonic)
        @label_count += 1

        <<~ASM
          @SP
          A=M-1
          D=M
          M=0
          A=A-1
          D=M-D
          @SP
          M=M-1
          @VM.CompTrue.#{label_count}
          D;#{jump_mnemonic}

          D=0
          @VM.CompAssign.#{label_count}
          0;JMP

          (VM.CompTrue.#{label_count})
          D=-1
          @VM.CompAssign.#{label_count}
          0;JMP

          (VM.CompAssign.#{label_count})
          @SP
          A=M-1
          M=D
        ASM
      end

      def push_from_d
        <<~ASM
          @SP
          A=M
          M=D
          @SP
          M=M+1
        ASM
      end

      def pop_to_d
        <<~ASM
          @SP
          A=M-1
          D=M
          M=0
          @SP
          M=M-1
        ASM
      end
    end
  end
end

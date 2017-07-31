module Hack
  module VirtualMachine
    class CodeGenerator
      def generate(raw_instruction)
        instruction = Instruction.parse(raw_instruction)

        "// #{raw_instruction}\n" + case instruction
        when Arithmetic
          write_arithmetic(instruction)
        when Push, Pop
          write_push_pop(instruction)
        end
      end

      def write_arithmetic(instruction)
        case instruction.command
        when 'add'
          write_add(instruction)
        end
      end

      def address(segment, index)
        if segment == 'constant'
          strip_heredoc(<<-ASM)
            @#{index}
          ASM
        elsif segment == 'temp'
          strip_heredoc(<<-ASM)
            @R#{5 + Integer(index)} // hack
          ASM
        end
      end

      def write_add(instruction)
        add_logic = strip_heredoc(<<-ASM)
          @R5
          D=M
          @R6
          M=D+M
        ASM

        generate('pop temp 0') +
          generate('pop temp 1') +
          add_logic +
          generate('push temp 1')
      end

      def write_push_pop(instruction)
        case instruction
        when Push
          write_push(instruction)
        when Pop
          write_pop(instruction)
        end
      end

      def write_push(instruction)
        if instruction.segment == 'constant'
          write_push_constant(instruction)
        else
          write_push_value(instruction)
        end
      end

      def write_push_value(instruction)
        address(instruction.segment, instruction.index) +
          "D=M\n" +
          write_push_from_d
      end

      def write_push_constant(instruction)
        address(instruction.segment, instruction.index) +
          "D=A\n" +
          write_push_from_d
      end

      def write_push_from_d
        strip_heredoc(<<-ASM)
          @SP
          A=M
          M=D
          @SP
          M=M+1
        ASM
      end

      def write_pop(instruction)
        write_to_current_address = strip_heredoc(<<-ASM)
          // save current address in temp 2 (R7)
          D=A
          @R7
          M=D

          // address the top element in the stack (SP - 1)
          @SP
          A=M-1
          // save the element to D
          D=M
          // remove the element from the stack
          M=0
          // decrement the stack pointer
          @SP
          M=M-1

          // address the pop destination
          @R7
          A=M
          // write the popped element
          M=D
          // clear R7
          @R7
          M=0
        ASM

        address(instruction.segment, instruction.index) +
          write_to_current_address
      end

      def strip_heredoc(heredoc)
        leading_indents = heredoc.scan(/^[ \t]*(?=\S)/)
        indent_level = leading_indents.any? ? leading_indents.min.size : 0
        heredoc.gsub(/^[ \t]{#{indent_level}}/, '')
      end
    end
  end
end

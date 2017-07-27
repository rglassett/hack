module Hack
  class Assembler
    def self.assemble(input_filename)
      output_filename = File.dirname(input_filename) + File::SEPARATOR + 'My' + File.basename(input_filename, '.asm') + '.hack'
      File.open(input_filename) do |input|
        parser = Parser.new(input)

        File.open(output_filename, 'w') do |output|
          while parser.more_commands?
            parser.advance
            case parser.command_type
            when :a
              output.puts("0" + Integer(parser.symbol).to_s(2).rjust(15, '0'))
            when :c
              output.puts(
                "111" +
                CodeGenerator.comp(parser.comp) +
                CodeGenerator.dest(parser.dest) +
                CodeGenerator.jump(parser.jump)
              )
            when :l
              raise NotImplementedError
            end
          end
        end
      end
    end
  end
end

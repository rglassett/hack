module Hack
  class Parser
    COMMENT = /\/\/.*/

    OPERAND = /[ADM01]/
    OPERATOR = /[\!\+\-\&\|]/

    DEST = /(?<dest>[ADM]{1,3})=/
    JUMP = /;(?<jump>J(GT|EQ|GE|LT|NE|LE|MP))/
    COMP = /(#{OPERAND}){0,1}(#{OPERATOR}{0,1})(#{OPERAND}){1}/

    IDENTIFIER = /[A-Za-z]\w+/
    INTEGER = /\d+/
    SYMBOL = /(#{IDENTIFIER}|#{INTEGER})/

    COMMAND_TYPES = [
      [:a, /@(?<symbol>#{SYMBOL})/],
      [:c, /(#{DEST}){0,1}(?<comp>#{COMP})(#{JUMP}){0,1}/],
      [:l, /\((?<symbol>#{SYMBOL})\)/],
    ]

    attr_reader :io_device, :command, :command_type, :command_data

    def initialize(io_device)
      @io_device = io_device
    end

    def more_commands?
      !io_device.eof?
    end

    def advance
      @command = sanitize_command(io_device.readline)

      while command.nil? || command.empty? && more_commands?
        @command = sanitize_command(io_device.readline)
      end

      set_command_type!
    end

    def sanitize_command(line)
      line.strip.gsub(COMMENT, '')
    end

    def set_command_type!
      COMMAND_TYPES.each do |type, matcher|
        match_data = command.match(matcher)
        if match_data
          @command_type = type
          @command_data = match_data
          return
        end
      end

      raise "Unknown command type for command: #{command}"
    end

    def symbol
      fetch(:symbol)
    end

    def dest
      fetch(:dest)
    end

    def comp
      fetch(:comp)
    end

    def jump
      fetch(:jump)
    end

    private

    def fetch(name)
      command_data[name]
    rescue IndexError
      nil
    end
  end
end

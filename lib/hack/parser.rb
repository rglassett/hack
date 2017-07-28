module Hack
  class Parser
    COMMENT = /\/\/.*/

    OPERAND = /[ADM01]/
    OPERATOR = /[\!\+\-\&\|]/

    DEST = /((?<dest>[ADM]{1,3})=){0,1}/
    JUMP = /(;(?<jump>J(GT|EQ|GE|LT|NE|LE|MP))){0,1}/
    COMP = /(?<comp>(#{OPERAND}){0,1}(#{OPERATOR}{0,1})(#{OPERAND}){1})/

    IDENTIFIER = /[A-Za-z\.\$\:][\w\.\$\:]+/
    INTEGER = /\d+/
    SYMBOL = /(?<symbol>#{IDENTIFIER}|#{INTEGER})/

    COMMAND_TYPES = [
      [:a, /\A@#{SYMBOL}\z/],
      [:c, /\A#{DEST}#{COMP}#{JUMP}\z/],
      [:l, /\A\(#{SYMBOL}\)\z/],
    ]

    attr_reader :io_device, :command, :command_type, :command_data

    def initialize(io_device)
      @io_device = io_device
    end

    def rewind
      io_device.rewind
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
      line.gsub(COMMENT, '').strip
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

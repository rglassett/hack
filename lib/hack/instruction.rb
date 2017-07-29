module Hack
  class Instruction
    COMMENT = /\/\/.*/
    IDENTIFIER = /[A-Za-z\.\$\:][\w\.\$\:]+/
    INTEGER = /\d+/
    SYMBOL = /(?<symbol>#{IDENTIFIER}|#{INTEGER})/

    INSTRUCTION_TYPES = [
      'Hack::AInstruction',
      'Hack::CInstruction',
      'Hack::LInstruction',
    ]

    attr_reader :data, :raw

    def self.data_reader(*attributes)
      attributes.each do |attribute|
        define_method(attribute) { fetch(attribute) }
      end
    end

    def self.match(string)
      self::MATCHER.match(string)
    end

    def self.parse(string)
      INSTRUCTION_TYPES.each do |instruction_type|
        instruction_klass = const_get(instruction_type)
        return instruction_klass.new(string) if instruction_klass.match(string)
      end

      raise "Unknown instruction type for command: #{string}"
    end

    def self.sanitize(string)
      string.gsub(COMMENT, '').strip
    end

    def initialize(string)
      @data = self.class.match(string)
      @raw = string
    end

    def fetch(mnemonic)
      data[mnemonic]
    rescue IndexError
      nil
    end
  end
end

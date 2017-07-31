require 'rspec'
require 'tempfile'
require_relative '../../../../lib/hack/assembly'

describe Hack::Assembly::Assembler do
  context 'given Hack assembly code with no variables or labels' do
    it 'correctly generates the Add program' do
      compare('Add')
    end

    it 'correctly generates the MaxL program' do
      compare('MaxL')
    end

    it 'correctly generates the RectL program' do
      compare('RectL')
    end

    it 'correctly generates the PongL program' do
      compare('PongL')
    end
  end

  context 'given Hack assembly code with variables and labels' do
    it 'correctly generates the Max program' do
      compare('Max')
    end

    it 'correctly generates the Rect program' do
      compare('Rect')
    end

    it 'correctly generates the Pong program' do
      compare('Pong')
    end
  end

  def compare(program)
    File.open("spec/fixtures/#{program}.asm") do |input|
      Tempfile.open('assembler_spec', '/tmp') do |output|
        Hack::Assembly::Assembler.new(input, output).assemble
        [input, output].each(&:rewind)

        File.open("spec/fixtures/#{program}.hack") do |compare_file|
          expect(output.readlines).to eq(compare_file.readlines)
        end
      end
    end
  end
end

require 'spec_helper'

describe Hashie::Extensions::Parsers::YamlErbParser do
  describe '.perform' do
    context 'a file' do
      let(:config) do
        <<-EOF
---
foo: verbatim
bar: <%= "erb" %>
baz: "<%= __FILE__ %>"
        EOF
      end
      let(:path) { 'template.yml' }

      subject { described_class.new(path).perform }

      before do
        expect(File).to receive(:read).with(path).and_return(config)
      end

      it { is_expected.to be_a(Hash) }

      it 'parses YAML after interpolating ERB' do
        expect(subject['foo']).to eq 'verbatim'
        expect(subject['bar']).to eq 'erb'
        expect(subject['baz']).to eq path
      end
    end

    context 'Pathname' do
      let(:tempfile) do
        file = Tempfile.new(['foo', '.yml'])
        file.write("---\nfoo: hello\n")
        file.rewind
        file
      end

      subject { described_class.new(Pathname tempfile.path) }

      it '"#perform" can be done in case of path is a Pathname object.' do
        expect(subject.perform).to eq 'foo' => 'hello'
      end
    end
  end
end

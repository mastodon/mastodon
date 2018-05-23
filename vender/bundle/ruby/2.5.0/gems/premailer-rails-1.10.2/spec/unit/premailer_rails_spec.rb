require 'spec_helper'

describe Premailer::Rails do
  describe '#config' do
    subject { Premailer::Rails.config }
    context 'when set' do
      around do |example|
        begin
          default_config = described_class.config
          described_class.config = { foo: :bar }
          example.run
        ensure
          described_class.config = default_config
        end
      end
      it { is_expected.to eq(foo: :bar) }
    end
  end
end

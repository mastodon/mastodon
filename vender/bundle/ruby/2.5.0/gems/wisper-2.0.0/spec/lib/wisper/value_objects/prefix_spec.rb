describe Wisper::ValueObjects::Prefix do
  
  it 'is a string' do
    expect(subject).to be_kind_of String
  end

  describe '.new' do
    context 'without arguments' do
      subject { described_class.new }
      it { is_expected.to eq '' }
    end

    context 'nil' do
      subject { described_class.new nil }
      it { is_expected.to eq '' }
    end

    context 'true' do
      subject { described_class.new true }
      it { is_expected.to eq 'on_' }
    end

    context '"foo"' do
      subject { described_class.new 'foo' }
      it { is_expected.to eq 'foo_' }
    end
  end

  describe '.default=' do
    after { described_class.default = nil }

    context 'nil' do
      it "doesn't change default prefix" do
        expect { described_class.default = nil }
          .not_to change { described_class.new true }.from('on_')
      end
    end

    context '"foo"' do
      it 'changes default prefix' do
        expect { described_class.default = 'foo' }
          .to change { described_class.new true }.from('on_').to('foo_')
      end
    end
  end
end

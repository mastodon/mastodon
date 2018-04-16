require 'spec_helper'

describe Chewy::Search::Parameters::Storage do
  subject { described_class.new }

  describe '.param_name' do
    specify { expect(described_class.param_name).to eq(:storage) }

    context do
      before { stub_class('Namespace::CustomParamName', Class.new(described_class)) }
      specify { expect(Namespace::CustomParamName.param_name).to eq(:custom_param_name) }
    end
  end

  describe '.param_name=' do
    before { stub_class('Namespace::Whatever', Class.new(described_class)) }
    specify do
      expect { Namespace::Whatever.param_name = :custom }
        .to change { Namespace::Whatever.param_name }.from(:whatever).to(:custom)
    end
  end

  describe '#initialize' do
    specify { expect(subject.value).to be_nil }
    specify { expect(described_class.new(a: 1).value).to eq(a: 1) }
  end

  describe '#==' do
    specify { expect(subject).to eq(described_class.new) }
    specify { expect(described_class.new(:foo)).to eq(described_class.new(:foo)) }
    specify { expect(described_class.new(:foo)).not_to eq(described_class.new(:bar)) }

    context do
      let(:other_value) { Class.new(described_class) }
      specify { expect(other_value.new(:foo)).not_to eq(described_class.new(:foo)) }
      specify { expect(other_value.new(:foo)).to eq(other_value.new(:foo)) }
    end
  end

  describe '#replace!' do
    specify { expect { subject.replace!(42) }.to change { subject.value }.from(nil).to(42) }
    specify { expect { subject.replace!('42') }.to change { subject.value }.from(nil).to('42') }
  end

  describe '#update!' do
    specify { expect { subject.update!(true) }.to change { subject.value }.from(nil).to(true) }
    specify { expect { subject.update!(:symbol) }.to change { subject.value }.from(nil).to(:symbol) }
  end

  describe '#merge!' do
    let(:other) { described_class.new(['something']) }
    specify { expect { subject.merge!(other) }.to change { subject.value }.from(nil).to(['something']) }
  end

  describe '#render' do
    specify { expect(subject.render).to be_nil }
    specify { expect(described_class.new(false).render).to be_nil }
    specify { expect(described_class.new('42').render).to eq(storage: '42') }
  end
end

require 'spec_helper'

describe Chewy::Search::Parameters::Load do
  subject { described_class.new(only: :foo) }

  describe '#initialize' do
    specify { expect(described_class.new.value).to eq({}) }
    specify { expect(described_class.new(nil).value).to eq({}) }
    specify { expect(described_class.new(scope: {'type' => :foo}).value).to eq(scope: {type: :foo}) }
    specify { expect(subject.value).to eq(only: :foo) }
  end

  describe '#replace!' do
    specify do
      expect { subject.replace!(nil) }
        .to change { subject.value }
        .from(only: :foo).to({})
    end

    specify do
      expect { subject.replace!('except' => :bar) }
        .to change { subject.value }
        .from(only: :foo)
        .to(except: :bar)
    end
  end

  describe '#update!' do
    specify do
      expect { subject.update!(nil) }
        .not_to change { subject.value }
    end

    specify do
      expect { subject.update!('except' => :bar) }
        .to change { subject.value }
        .from(only: :foo)
        .to(only: :foo, except: :bar)
    end
  end

  describe '#merge!' do
    specify do
      expect { subject.merge!(described_class.new) }
        .not_to change { subject.value }
    end

    specify do
      expect { subject.merge!(described_class.new('except' => :bar)) }
        .to change { subject.value }
        .from(only: :foo)
        .to(only: :foo, except: :bar)
    end
  end

  describe '#render' do
    specify { expect(described_class.new.render).to be_nil }
    specify { expect(described_class.new(only: :foo).render).to be_nil }
  end
end

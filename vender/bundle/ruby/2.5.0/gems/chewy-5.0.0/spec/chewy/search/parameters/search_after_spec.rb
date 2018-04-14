require 'spec_helper'

describe Chewy::Search::Parameters::SearchAfter do
  subject { described_class.new([:foo, 42]) }

  describe '#initialize' do
    specify { expect(described_class.new.value).to be_nil }
    specify { expect(described_class.new(:foo).value).to eq([:foo]) }
    specify { expect(described_class.new(nil).value).to be_nil }
  end

  describe '#replace!' do
    specify { expect { subject.replace!(:baz) }.to change { subject.value }.from([:foo, 42]).to([:baz]) }
    specify { expect { subject.replace!(nil) }.to change { subject.value }.from([:foo, 42]).to(nil) }
  end

  describe '#update!' do
    specify { expect { subject.update!(:baz) }.to change { subject.value }.from([:foo, 42]).to([:baz]) }
    specify { expect { subject.update!(nil) }.not_to change { subject.value }.from([:foo, 42]) }
  end

  describe '#merge!' do
    specify { expect { subject.merge!(described_class.new(:baz)) }.to change { subject.value }.from([:foo, 42]).to([:baz]) }
    specify { expect { subject.merge!(described_class.new) }.not_to change { subject.value }.from([:foo, 42]) }
  end

  describe '#render' do
    specify { expect(described_class.new.render).to be_nil }
    specify { expect(described_class.new(:baz).render).to eq(search_after: [:baz]) }
    specify { expect(subject.render).to eq(search_after: [:foo, 42]) }
  end
end

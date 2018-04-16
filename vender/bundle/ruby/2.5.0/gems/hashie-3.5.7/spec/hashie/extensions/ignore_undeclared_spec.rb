require 'spec_helper'

describe Hashie::Extensions::IgnoreUndeclared do
  context 'included in Trash' do
    class ForgivingTrash < Hashie::Trash
      include Hashie::Extensions::IgnoreUndeclared
      property :city
      property :state, from: :provence
      property :str_state, from: 'str_provence'
    end

    subject { ForgivingTrash }

    it 'silently ignores undeclared properties on initialization' do
      expect { subject.new(city: 'Toronto', provence: 'ON', country: 'Canada') }.to_not raise_error
    end

    it 'works with translated properties (with symbol keys)' do
      expect(subject.new(provence: 'Ontario').state).to eq('Ontario')
    end

    it 'works with translated properties (with string keys)' do
      expect(subject.new('str_provence' => 'Ontario').str_state).to eq('Ontario')
    end

    it 'requires properties to be declared on assignment' do
      hash = subject.new(city: 'Toronto')
      expect { hash.country = 'Canada' }.to raise_error(NoMethodError)
    end
  end

  context 'combined with DeepMerge' do
    class ForgivingTrashWithMerge < Hashie::Trash
      include Hashie::Extensions::DeepMerge
      include Hashie::Extensions::IgnoreUndeclared
      property :some_key
    end

    it 'deep merges' do
      class ForgivingTrashWithMergeAndProperty < ForgivingTrashWithMerge
        property :some_other_key
      end
      hash = ForgivingTrashWithMergeAndProperty.new(some_ignored_key: 17, some_key: 12)
      expect(hash.deep_merge(some_other_key: 55, some_ignored_key: 18)).to eq(some_key: 12, some_other_key: 55)
    end
  end
end

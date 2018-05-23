require 'spec_helper'

shared_examples :hash_storage do |param_name|
  subject { described_class.new(field: {foo: 'bar'}) }

  describe '#initialize' do
    specify { expect(described_class.new.value).to eq({}) }
    specify { expect(described_class.new(nil).value).to eq({}) }
    specify { expect(subject.value).to eq('field' => {foo: 'bar'}) }
  end

  describe '#replace!' do
    specify do
      expect { subject.replace!(nil) }
        .to change { subject.value }
        .from('field' => {foo: 'bar'}).to({})
    end

    specify do
      expect { subject.replace!(other: {moo: 'baz'}) }
        .to change { subject.value }
        .from('field' => {foo: 'bar'})
        .to('other' => {moo: 'baz'})
    end
  end

  describe '#update!' do
    specify do
      expect { subject.update!(nil) }
        .not_to change { subject.value }
    end

    specify do
      expect { subject.update!(other: {moo: 'baz'}) }
        .to change { subject.value }
        .from('field' => {foo: 'bar'})
        .to('field' => {foo: 'bar'}, 'other' => {moo: 'baz'})
    end
  end

  describe '#merge!' do
    specify do
      expect { subject.merge!(described_class.new) }
        .not_to change { subject.value }
    end

    specify do
      expect { subject.merge!(described_class.new(other: {moo: 'baz'})) }
        .to change { subject.value }
        .from('field' => {foo: 'bar'})
        .to('field' => {foo: 'bar'}, 'other' => {moo: 'baz'})
    end
  end

  describe '#render' do
    specify { expect(described_class.new.render).to be_nil }
    specify { expect(described_class.new(field: {foo: 'bar'}).render).to eq(param_name => {'field' => {foo: 'bar'}}) }
  end
end

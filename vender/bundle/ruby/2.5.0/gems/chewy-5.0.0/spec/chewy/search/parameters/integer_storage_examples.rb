require 'spec_helper'

shared_examples :integer_storage do |param_name|
  subject { described_class.new(10) }

  describe '#initialize' do
    specify { expect(described_class.new.value).to be_nil }
    specify { expect(described_class.new('42').value).to eq(42) }
    specify { expect(described_class.new(33.3).value).to eq(33) }
    specify { expect(described_class.new(nil).value).to be_nil }
  end

  describe '#replace!' do
    specify { expect { subject.replace!(42) }.to change { subject.value }.from(10).to(42) }
    specify { expect { subject.replace!(nil) }.to change { subject.value }.from(10).to(nil) }
  end

  describe '#update!' do
    specify { expect { subject.update!('42') }.to change { subject.value }.from(10).to(42) }
    specify { expect { subject.update!(nil) }.not_to change { subject.value }.from(10) }
  end

  describe '#merge!' do
    specify { expect { subject.merge!(described_class.new('33')) }.to change { subject.value }.from(10).to(33) }
    specify { expect { subject.merge!(described_class.new) }.not_to change { subject.value }.from(10) }
  end

  describe '#render' do
    specify { expect(described_class.new.render).to be_nil }
    specify { expect(described_class.new('42').render).to eq(param_name => 42) }
  end
end

require 'spec_helper'

shared_examples :bool_storage do |param_name|
  subject { described_class.new(true) }

  describe '#initialize' do
    specify { expect(subject.value).to eq(true) }
    specify { expect(described_class.new.value).to eq(false) }
    specify { expect(described_class.new(42).value).to eq(true) }
    specify { expect(described_class.new(nil).value).to eq(false) }
  end

  describe '#replace!' do
    specify { expect { subject.replace!(false) }.to change { subject.value }.from(true).to(false) }
    specify { expect { subject.replace!(nil) }.to change { subject.value }.from(true).to(false) }
  end

  describe '#update!' do
    specify { expect { subject.update!(nil) }.not_to change { subject.value }.from(true) }
    specify { expect { subject.update!(false) }.not_to change { subject.value }.from(true) }
    specify { expect { subject.update!(true) }.not_to change { subject.value }.from(true) }

    context do
      subject { described_class.new }

      specify { expect { subject.update!(nil) }.not_to change { subject.value }.from(false) }
      specify { expect { subject.update!(false) }.not_to change { subject.value }.from(false) }
      specify { expect { subject.update!(true) }.to change { subject.value }.from(false).to(true) }
    end
  end

  describe '#merge!' do
    specify { expect { subject.merge!(described_class.new) }.not_to change { subject.value }.from(true) }
    specify { expect { subject.merge!(described_class.new(true)) }.not_to change { subject.value }.from(true) }

    context do
      subject { described_class.new }

      specify { expect { subject.merge!(described_class.new) }.not_to change { subject.value }.from(false) }
      specify { expect { subject.merge!(described_class.new(true)) }.to change { subject.value }.from(false).to(true) }
    end
  end

  describe '#render' do
    specify { expect(described_class.new.render).to be_nil }

    if param_name.is_a?(Symbol)
      specify { expect(subject.render).to eq(param_name => true) }
    else
      specify { expect(subject.render).to eq(param_name) }
    end
  end
end

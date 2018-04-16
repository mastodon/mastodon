require 'spec_helper'

describe Chewy::Search::Parameters::RequestCache do
  subject { described_class.new(true) }

  describe '#initialize' do
    specify { expect(subject.value).to eq(true) }
    specify { expect(described_class.new.value).to eq(nil) }
    specify { expect(described_class.new(42).value).to eq(true) }
    specify { expect(described_class.new(false).value).to eq(false) }
  end

  describe '#replace!' do
    specify { expect { subject.replace!(false) }.to change { subject.value }.from(true).to(false) }
    specify { expect { subject.replace!(nil) }.to change { subject.value }.from(true).to(nil) }
  end

  describe '#update!' do
    specify { expect { subject.update!(nil) }.not_to change { subject.value }.from(true) }
    specify { expect { subject.update!(false) }.to change { subject.value }.from(true).to(false) }
    specify { expect { subject.update!(true) }.not_to change { subject.value }.from(true) }

    context do
      subject { described_class.new(false) }

      specify { expect { subject.update!(nil) }.not_to change { subject.value }.from(false) }
      specify { expect { subject.update!(false) }.not_to change { subject.value }.from(false) }
      specify { expect { subject.update!(true) }.to change { subject.value }.from(false).to(true) }
    end

    context do
      subject { described_class.new }

      specify { expect { subject.update!(nil) }.not_to change { subject.value }.from(nil) }
      specify { expect { subject.update!(false) }.to change { subject.value }.from(nil).to(false) }
      specify { expect { subject.update!(true) }.to change { subject.value }.from(nil).to(true) }
    end
  end

  describe '#merge!' do
    specify { expect { subject.merge!(described_class.new) }.not_to change { subject.value }.from(true) }
    specify { expect { subject.merge!(described_class.new(false)) }.to change { subject.value }.from(true).to(false) }
    specify { expect { subject.merge!(described_class.new(true)) }.not_to change { subject.value }.from(true) }

    context do
      subject { described_class.new(false) }

      specify { expect { subject.merge!(described_class.new) }.not_to change { subject.value }.from(false) }
      specify { expect { subject.merge!(described_class.new(false)) }.not_to change { subject.value }.from(false) }
      specify { expect { subject.merge!(described_class.new(true)) }.to change { subject.value }.from(false).to(true) }
    end

    context do
      subject { described_class.new }

      specify { expect { subject.merge!(described_class.new) }.not_to change { subject.value }.from(nil) }
      specify { expect { subject.merge!(described_class.new(false)) }.to change { subject.value }.from(nil).to(false) }
      specify { expect { subject.merge!(described_class.new(true)) }.to change { subject.value }.from(nil).to(true) }
    end
  end

  describe '#render' do
    specify { expect(described_class.new.render).to be_nil }
    specify { expect(described_class.new(false).render).to eq(request_cache: false) }
    specify { expect(subject.render).to eq(request_cache: true) }
  end
end

require 'spec_helper'

describe Chewy::Runtime do
  describe '.version' do
    specify { expect(described_class.version).to be_a(described_class::Version) }
    specify { expect(described_class.version).to be >= '2.4' }
    specify { expect(described_class.version).to be < '6.0' }
  end
end

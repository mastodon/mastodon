require 'spec_helper'

describe Chewy::Index::Aliases do
  before { Chewy.massacre }

  before { stub_index :dummies }

  describe '.indexes' do
    specify { expect(DummiesIndex.indexes).to eq([]) }

    context do
      before { DummiesIndex.create! }
      specify { expect(DummiesIndex.indexes).to eq([]) }
    end

    context do
      before { DummiesIndex.create! }
      before { Chewy.client.indices.put_alias index: 'dummies', name: 'dummies_2013' }
      specify { expect(DummiesIndex.indexes).to eq([]) }
    end

    context do
      before { DummiesIndex.create! '2013' }
      before { DummiesIndex.create! '2014' }
      specify { expect(DummiesIndex.indexes).to match_array(%w[dummies_2013 dummies_2014]) }
    end
  end

  describe '.aliases' do
    specify { expect(DummiesIndex.aliases).to eq([]) }

    context do
      before { DummiesIndex.create! }
      specify { expect(DummiesIndex.aliases).to eq([]) }
    end

    context do
      before { DummiesIndex.create! }
      before { Chewy.client.indices.put_alias index: 'dummies', name: 'dummies_2013' }
      before { Chewy.client.indices.put_alias index: 'dummies', name: 'dummies_2014' }
      specify { expect(DummiesIndex.aliases).to match_array(%w[dummies_2013 dummies_2014]) }
    end

    context do
      before { DummiesIndex.create! '2013' }
      specify { expect(DummiesIndex.aliases).to eq([]) }
    end
  end
end

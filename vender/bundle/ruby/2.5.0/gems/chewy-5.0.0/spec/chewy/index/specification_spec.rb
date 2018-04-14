require 'spec_helper'

describe Chewy::Index::Specification do
  before { Chewy.massacre }

  let(:index1) do
    stub_index(:places) do
      define_type(:city) do
        field :founded_on, type: 'date'
      end
    end
  end

  let(:index2) do
    stub_index(:places) do
      settings analyzer: {}
      define_type(:city) do
        field :founded_on, type: 'date'
      end
    end
  end

  let(:index3) do
    stub_index(:places) do
      define_type(:city) do
        field :founded_on, type: 'date'
        field :population, type: 'integer'
      end
    end
  end

  let(:index4) do
    stub_index(:places) do
      define_type(:city) do
        field :population, type: 'integer'
        field :founded_on, type: 'date'
      end
    end
  end

  let(:index5) do
    stub_index('namespace/cities') do
      define_type(:city) do
        field :population, type: 'integer'
      end
    end
  end

  let(:specification1) { described_class.new(index1) }
  let(:specification2) { described_class.new(index2) }
  let(:specification3) { described_class.new(index3) }
  let(:specification4) { described_class.new(index4) }
  let(:specification5) { described_class.new(index5) }

  describe '#lock!' do
    specify do
      expect { specification1.lock! }.to change { Chewy::Stash::Specification.all.hits }.from([]).to([{
        '_index' => 'chewy_specifications',
        '_type' => 'specification',
        '_id' => 'places',
        '_score' => 1.0,
        '_source' => {'specification' => Base64.encode64({
          'settings' => {'index' => {'number_of_shards' => 1, 'number_of_replicas' => 0}},
          'mappings' => {'city' => {'properties' => {'founded_on' => {'type' => 'date'}}}}
        }.to_json)}
      }])
    end

    context do
      before { specification1.lock! }

      specify do
        expect { specification5.lock! }.to change { Chewy::Stash::Specification.all.hits }.to([{
          '_index' => 'chewy_specifications',
          '_type' => 'specification',
          '_id' => 'places',
          '_score' => 1.0,
          '_source' => {'specification' => Base64.encode64({
            'settings' => {'index' => {'number_of_shards' => 1, 'number_of_replicas' => 0}},
            'mappings' => {'city' => {'properties' => {'founded_on' => {'type' => 'date'}}}}
          }.to_json)}
        }, {
          '_index' => 'chewy_specifications',
          '_type' => 'specification',
          '_id' => 'namespace/cities',
          '_score' => 1.0,
          '_source' => {'specification' => Base64.encode64({
            'settings' => {'index' => {'number_of_shards' => 1, 'number_of_replicas' => 0}},
            'mappings' => {'city' => {'properties' => {'population' => {'type' => 'integer'}}}}
          }.to_json)}
        }])
      end
    end
  end

  describe '#locked' do
    specify do
      expect { specification1.lock! }.to change { specification1.locked }.from({}).to(
        'settings' => {'index' => {'number_of_shards' => 1, 'number_of_replicas' => 0}},
        'mappings' => {'city' => {'properties' => {'founded_on' => {'type' => 'date'}}}}
      )
    end

    specify do
      expect { specification5.lock! }.to change { specification5.locked }.from({}).to(
        'settings' => {'index' => {'number_of_shards' => 1, 'number_of_replicas' => 0}},
        'mappings' => {'city' => {'properties' => {'population' => {'type' => 'integer'}}}}
      )
    end

    context do
      before { specification1.lock! }

      specify do
        expect { specification2.lock! }.to change { specification2.locked }.from(
          'settings' => {'index' => {'number_of_shards' => 1, 'number_of_replicas' => 0}},
          'mappings' => {'city' => {'properties' => {'founded_on' => {'type' => 'date'}}}}
        ).to(
          'settings' => {'analyzer' => {}, 'index' => {'number_of_shards' => 1, 'number_of_replicas' => 0}},
          'mappings' => {'city' => {'properties' => {'founded_on' => {'type' => 'date'}}}}
        )
      end

      specify do
        expect { specification3.lock! }.to change { specification3.locked }.from(
          'settings' => {'index' => {'number_of_shards' => 1, 'number_of_replicas' => 0}},
          'mappings' => {'city' => {'properties' => {'founded_on' => {'type' => 'date'}}}}
        ).to(
          'settings' => {'index' => {'number_of_shards' => 1, 'number_of_replicas' => 0}},
          'mappings' => {'city' => {'properties' => {'founded_on' => {'type' => 'date'}, 'population' => {'type' => 'integer'}}}}
        )
      end
    end
  end

  describe '#current' do
    specify do
      expect(specification2.current).to eq(
        'mappings' => {'city' => {'properties' => {'founded_on' => {'type' => 'date'}}}},
        'settings' => {'analyzer' => {}, 'index' => {'number_of_shards' => 1, 'number_of_replicas' => 0}}
      )
    end
  end

  describe '#changed?' do
    specify { expect(specification1.changed?).to eq(true) }
    specify { expect { specification1.lock! }.to change { specification1.changed? }.to(false) }

    context do
      before { specification1.lock! }
      specify { expect { specification2.lock! }.to change { specification2.changed? }.from(true).to(false) }
    end

    context do
      before { specification1.lock! }
      specify { expect { specification3.lock! }.to change { specification3.changed? }.from(true).to(false) }
    end

    context do
      before { specification1.lock! }
      specify { expect { specification5.lock! }.to change { specification5.changed? }.from(true) }
    end

    context do
      before { specification3.lock! }
      specify { expect { specification4.lock! }.not_to change { specification4.changed? }.from(false) }
    end
  end
end

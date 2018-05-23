require 'spec_helper'

describe Chewy::Type::Actions, :orm do
  before { Chewy.massacre }

  before do
    stub_model(:city)
    stub_index(:cities) do
      define_type City do
        field :name
        field :updated_at, type: 'date'
      end
    end
  end

  let!(:cities) { Array.new(3) { |i| City.create!(name: "Name#{i + 1}") } }
  before { CitiesIndex::City.import }

  describe '.reset' do
    specify do
      expect { CitiesIndex::City.reset }.to update_index(CitiesIndex::City)
    end
  end

  describe '.sync' do
    before do
      cities.first.destroy
      sleep(1) if ActiveSupport::VERSION::STRING < '4.1.0'
      cities.last.update(name: 'Name5')
    end
    let!(:additional_city) { City.create!(name: 'Name4') }

    specify do
      expect(CitiesIndex::City.sync).to match(
        count: 3,
        missing: contain_exactly(cities.first.id.to_s, additional_city.id.to_s),
        outdated: [cities.last.id.to_s]
      )
    end
    specify do
      expect { CitiesIndex::City.sync }.to update_index(CitiesIndex::City)
        .and_reindex(additional_city, cities.last)
        .and_delete(cities.first).only
    end
  end

  describe '.journal' do
    specify { expect(CitiesIndex::City.journal).to be_a(Chewy::Journal) }
  end
end

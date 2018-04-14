require 'spec_helper'

if defined?(::Resque)
  require 'resque_spec'

  describe Chewy::Strategy::Resque, :orm do
    around { |example| Chewy.strategy(:bypass) { example.run } }
    before { ResqueSpec.reset! }
    before do
      stub_model(:city) do
        update_index('cities#city') { self }
      end

      stub_index(:cities) do
        define_type City
      end
    end

    let(:city) { City.create!(name: 'hello') }
    let(:other_city) { City.create!(name: 'world') }

    specify do
      expect { [city, other_city].map(&:save!) }
        .not_to update_index(CitiesIndex::City, strategy: :resque)
    end

    specify do
      with_resque do
        expect { [city, other_city].map(&:save!) }
          .to update_index(CitiesIndex::City, strategy: :resque)
          .and_reindex(city, other_city).only
      end
    end

    specify do
      expect(CitiesIndex::City).to receive(:import!).with([city.id, other_city.id], suffix: '201601')
      Chewy::Strategy::Resque::Worker.perform('CitiesIndex::City', [city.id, other_city.id], suffix: '201601')
    end

    specify do
      allow(Chewy).to receive(:disable_refresh_async).and_return(true)
      expect(CitiesIndex::City).to receive(:import!).with([city.id, other_city.id], suffix: '201601', refresh: false)
      Chewy::Strategy::Resque::Worker.perform('CitiesIndex::City', [city.id, other_city.id], suffix: '201601')
    end
  end
end

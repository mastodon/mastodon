require 'spec_helper'

describe Chewy::Strategy::Atomic, :orm do
  around { |example| Chewy.strategy(:bypass) { example.run } }

  before do
    stub_model(:country) do
      update_index('countries#country') { self }
    end

    stub_index(:countries) do
      define_type Country
    end
  end

  let(:country) { Country.create!(name: 'hello', country_code: 'HL') }
  let(:other_country) { Country.create!(name: 'world', country_code: 'WD') }

  specify do
    expect { [country, other_country].map(&:save!) }
      .to update_index(CountriesIndex::Country, strategy: :atomic)
      .and_reindex(country, other_country).only
  end

  specify do
    expect { [country, other_country].map(&:destroy) }
      .to update_index(CountriesIndex::Country, strategy: :atomic)
      .and_delete(country, other_country).only
  end

  context do
    before do
      stub_index(:countries) do
        define_type Country do
          root id: -> { country_code } do
          end
        end
      end
    end

    specify do
      expect { [country, other_country].map(&:save!) }
        .to update_index(CountriesIndex::Country, strategy: :atomic)
        .and_reindex('HL', 'WD').only
    end

    specify do
      expect { [country, other_country].map(&:destroy) }
        .to update_index(CountriesIndex::Country, strategy: :atomic)
        .and_delete('HL', 'WD').only
    end

    specify do
      expect do
        country.save!
        other_country.destroy
      end
        .to update_index(CountriesIndex::Country, strategy: :atomic)
        .and_reindex('HL').and_delete('WD').only
    end
  end
end

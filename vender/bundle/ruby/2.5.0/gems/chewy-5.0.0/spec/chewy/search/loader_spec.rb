require 'spec_helper'

describe Chewy::Search::Loader do
  before { Chewy.massacre }

  before do
    stub_model(:city)
    stub_model(:country)

    stub_index(:cities) do
      define_type City do
        field :name
        field :rating, type: 'integer'
      end
    end

    stub_index(:countries) do
      define_type Country do
        field :name
        field :rating, type: 'integer'
      end
    end
  end

  before do
    CitiesIndex.import!(cities: cities)
    CountriesIndex.import!(countries: countries)
  end

  let(:cities) { Array.new(2) { |i| City.create!(rating: i, name: "city #{i}") } }
  let(:countries) { Array.new(2) { |i| Country.create!(rating: i + 2, name: "country #{i}") } }

  let(:options) { {} }
  subject { described_class.new(indexes: [CitiesIndex, CountriesIndex], **options) }

  describe '#derive_type' do
    specify { expect(subject.derive_type('cities', 'city')).to eq(CitiesIndex::City) }
    specify { expect(subject.derive_type('cities_suffix', 'city')).to eq(CitiesIndex::City) }

    specify { expect { subject.derive_type('cities', 'place') }.to raise_error(Chewy::UnderivableType) }
    specify { expect { subject.derive_type('whatever', 'city') }.to raise_error(Chewy::UnderivableType) }
    specify { expect { subject.derive_type('citiessuffix', 'city') }.to raise_error(Chewy::UnderivableType) }

    context do
      before { CitiesIndex.index_name :boro_goves }

      specify { expect(subject.derive_type('boro_goves', 'city')).to eq(CitiesIndex::City) }
      specify { expect(subject.derive_type('boro_goves_suffix', 'city')).to eq(CitiesIndex::City) }
    end
  end

  describe '#load' do
    let(:hits) { Chewy::Search::Request.new(CitiesIndex, CountriesIndex).order(:rating).hits }

    specify { expect(subject.load(hits)).to eq([*cities, *countries]) }

    context do
      let(:options) { {only: 'city'} }
      specify { expect(subject.load(hits)).to eq([*cities, nil, nil]) }
    end

    context do
      let(:options) { {except: 'city'} }
      specify { expect(subject.load(hits)).to eq([nil, nil, *countries]) }
    end

    context do
      let(:options) { {except: %w[city country]} }
      specify { expect(subject.load(hits)).to eq([nil, nil, nil, nil]) }
    end

    context 'scopes', :active_record do
      context do
        let(:options) { {scope: -> { where('rating > 2') }} }
        specify { expect(subject.load(hits)).to eq([nil, nil, nil, countries.last]) }
      end

      context do
        let(:options) { {country: {scope: -> { where('rating > 2') }}} }
        specify { expect(subject.load(hits)).to eq([*cities, nil, countries.last]) }
      end
    end

    context 'scopes', :mongoid do
      context do
        let(:options) { {scope: -> { where(:rating.gt => 2) }} }
        specify { expect(subject.load(hits)).to eq([nil, nil, nil, countries.last]) }
      end

      context do
        let(:options) { {country: {scope: -> { where(:rating.gt => 2) }}} }
        specify { expect(subject.load(hits)).to eq([*cities, nil, countries.last]) }
      end
    end

    context 'objects' do
      before do
        stub_index(:cities) do
          define_type :city do
            field :name
            field :rating, type: 'integer'
          end
        end

        stub_index(:countries) do
          define_type :country do
            field :name
            field :rating, type: 'integer'
          end
        end
      end

      specify { expect(subject.load(hits).map(&:class).uniq).to eq([CitiesIndex::City, CountriesIndex::Country]) }
      specify { expect(subject.load(hits).map(&:rating)).to eq([*cities, *countries].map(&:rating)) }
    end
  end
end

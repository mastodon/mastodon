require 'spec_helper'

describe Chewy::Index do
  before do
    stub_index(:dummies) do
      define_type :dummy
    end
  end

  describe '.import', :orm do
    before do
      stub_model(:city)
      stub_model(:country)

      stub_index(:places) do
        define_type City
        define_type Country
      end
    end

    let!(:cities) { Array.new(2) { |i| City.create! id: i + 1 } }
    let!(:countries) { Array.new(2) { |i| Country.create! id: i + 1 } }

    specify do
      expect { PlacesIndex.import }.to update_index(PlacesIndex::City).and_reindex(cities)
      expect { PlacesIndex.import }.to update_index(PlacesIndex::Country).and_reindex(countries)
    end

    specify do
      expect { PlacesIndex.import city: cities.first }.to update_index(PlacesIndex::City).and_reindex(cities.first).only
      expect { PlacesIndex.import city: cities.first }.to update_index(PlacesIndex::Country).and_reindex(countries)
    end

    specify do
      expect { PlacesIndex.import city: cities.first, country: countries.last }.to update_index(PlacesIndex::City).and_reindex(cities.first).only
      expect { PlacesIndex.import city: cities.first, country: countries.last }.to update_index(PlacesIndex::Country).and_reindex(countries.last).only
    end

    specify do
      expect(PlacesIndex.client).to receive(:bulk).with(hash_including(refresh: false)).twice
      PlacesIndex.import city: cities.first, refresh: false
    end
  end

  describe '.client' do
    specify { expect(stub_index(:dummies1).client).to eq(stub_index(:dummies2).client) }

    context do
      before do
        stub_index(:dummies1)
        stub_index(:dummies2, Dummies1Index)
      end

      specify { expect(Dummies1Index.client).to eq(Dummies2Index.client) }
    end
  end

  describe '.index_name' do
    specify { expect { Class.new(Chewy::Index).index_name }.to raise_error Chewy::UndefinedIndex }
    specify { expect(Class.new(Chewy::Index) { index_name :myindex }.index_name).to eq('myindex') }
    specify { expect(stub_const('DeveloperIndex', Class.new(Chewy::Index)).index_name).to eq('developer') }
    specify { expect(stub_const('DevelopersIndex', Class.new(Chewy::Index)).index_name).to eq('developers') }

    specify { expect(stub_const('DevelopersIndex', Class.new(Chewy::Index)).index_name(suffix: '')).to eq('developers') }
    specify { expect(stub_const('DevelopersIndex', Class.new(Chewy::Index)).index_name(suffix: '2013')).to eq('developers_2013') }
    specify { expect(stub_const('DevelopersIndex', Class.new(Chewy::Index)).index_name(prefix: '')).to eq('developers') }
    specify { expect(stub_const('DevelopersIndex', Class.new(Chewy::Index)).index_name(prefix: 'test')).to eq('test_developers') }

    context do
      before { allow(Chewy).to receive_messages(configuration: {prefix: 'testing'}) }
      specify { expect(DummiesIndex.index_name).to eq('testing_dummies') }
      specify { expect(stub_index(:dummies) { index_name :users }.index_name).to eq('testing_users') }
      specify { expect(stub_index(:dummies) { index_name :users }.index_name(prefix: '')).to eq('users') }
    end
  end

  describe '.derivable_name' do
    specify { expect(Class.new(Chewy::Index).derivable_name).to be_nil }
    specify { expect(stub_index(:places).derivable_name).to eq('places') }
    specify { expect(stub_index('namespace/places').derivable_name).to eq('namespace/places') }
  end

  describe '.prefix' do
    before { allow(Chewy).to receive_messages(configuration: {prefix: 'testing'}) }
    specify { expect(Class.new(Chewy::Index).prefix).to eq('testing') }
  end

  describe '.define_type' do
    specify { expect(DummiesIndex.type_hash['dummy']).to eq(DummiesIndex::Dummy) }

    context do
      before { stub_index(:dummies) { define_type :dummy, name: :borogoves } }
      specify { expect(DummiesIndex.type_hash['borogoves']).to eq(DummiesIndex::Borogoves) }
    end

    context do
      before { stub_class(:city) }
      before { stub_index(:dummies) { define_type City, name: :country } }
      specify { expect(DummiesIndex.type_hash['country']).to eq(DummiesIndex::Country) }
    end

    context do
      before { stub_class('City') }
      before { stub_class('City::District', City) }

      specify do
        expect do
          Kernel.eval <<-DUMMY_CITY_INDEX
            class DummyCityIndex < Chewy::Index
              define_type City
              define_type City::District
            end
          DUMMY_CITY_INDEX
        end.not_to raise_error
      end

      specify do
        expect do
          Kernel.eval <<-DUMMY_CITY_INDEX
            class DummyCityIndex2 < Chewy::Index
              define_type City
              define_type City::Nothing
            end
          DUMMY_CITY_INDEX
        end.to raise_error(NameError)
      end
    end

    context 'type methods should be deprecated and can\'t redefine existing ones' do
      before do
        stub_index(:places) do
          def self.city; end
          define_type :city
          define_type :country
        end
      end

      specify { expect(PlacesIndex.city).to be_nil }
      specify { expect(PlacesIndex::Country).to be < Chewy::Type }
    end
  end

  describe '.type_hash' do
    specify { expect(DummiesIndex.type_hash['dummy']).to eq(DummiesIndex::Dummy) }
    specify { expect(DummiesIndex.type_hash).to have_key 'dummy' }
    specify { expect(DummiesIndex.type_hash['dummy']).to be < Chewy::Type }
    specify { expect(DummiesIndex.type_hash['dummy'].type_name).to eq('dummy') }
  end

  describe '.type' do
    specify { expect(DummiesIndex.type('dummy')).to eq(DummiesIndex::Dummy) }
    specify { expect { DummiesIndex.type('not-the-dummy') }.to raise_error(Chewy::UndefinedType) }
  end

  specify { expect(DummiesIndex.type_names).to eq(DummiesIndex.type_hash.keys) }

  describe '.types' do
    specify { expect(DummiesIndex.types).to eq(DummiesIndex.type_hash.values) }
    specify { expect(DummiesIndex.types(:dummy)).to be_a Chewy::Search::Request }
    specify { expect(DummiesIndex.types(:user)).to be_a Chewy::Search::Request }
  end

  describe '.settings' do
    before do
      allow(Chewy).to receive_messages(config: Chewy::Config.send(:new))

      Chewy.analyzer :name, filter: %w[lowercase icu_folding names_nysiis]
      Chewy.analyzer :phone, tokenizer: 'ngram', char_filter: ['phone']
      Chewy.tokenizer :ngram, type: 'nGram', min_gram: 3, max_gram: 3
      Chewy.char_filter :phone, type: 'pattern_replace', pattern: '[^\d]', replacement: ''
      Chewy.filter :names_nysiis, type: 'phonetic', encoder: 'nysiis', replace: false
    end

    let(:documents) { stub_index(:documents) { settings analysis: {analyzer: [:name, :phone, {sorted: {option: :baz}}]} } }

    specify { expect { documents.settings_hash }.to_not change(documents._settings, :inspect) }
    specify do
      expect(documents.settings_hash).to eq(settings: {analysis: {
        analyzer: {name: {filter: %w[lowercase icu_folding names_nysiis]},
                   phone: {tokenizer: 'ngram', char_filter: ['phone']},
                   sorted: {option: :baz}},
        tokenizer: {ngram: {type: 'nGram', min_gram: 3, max_gram: 3}},
        char_filter: {phone: {type: 'pattern_replace', pattern: '[^\d]', replacement: ''}},
        filter: {names_nysiis: {type: 'phonetic', encoder: 'nysiis', replace: false}}
      }})
    end
  end

  describe '.scopes' do
    before do
      stub_index(:places) do
        def self.by_rating; end

        def self.colors(*colors)
          filter(terms: {colors: colors.flatten(1).map(&:to_s)})
        end

        define_type :city do
          def self.by_id; end
          field :colors
        end
      end
    end

    specify { expect(described_class.scopes).to eq([]) }
    specify { expect(PlacesIndex.scopes).to match_array(%i[by_rating colors]) }

    context do
      before do
        Chewy.massacre
        PlacesIndex::City.import!(
          double(colors: ['red']),
          double(colors: %w[red green]),
          double(colors: %w[green yellow])
        )
      end

      specify do
        # This `blank?`` call is for the messed scopes bug reproduction. See #573
        PlacesIndex::City.blank?
        expect(PlacesIndex.colors(:green).map(&:colors))
          .to contain_exactly(%w[red green], %w[green yellow])
      end

      specify do
        # This `blank?` call is for the messed scopes bug reproduction. See #573
        PlacesIndex::City.blank?
        expect(PlacesIndex::City.colors(:green).map(&:colors))
          .to contain_exactly(%w[red green], %w[green yellow])
      end
    end
  end

  describe '.settings_hash' do
    before { allow(Chewy).to receive_messages(config: Chewy::Config.send(:new)) }

    specify { expect(stub_index(:documents).settings_hash).to eq({}) }
    specify { expect(stub_index(:documents) { settings number_of_shards: 1 }.settings_hash).to eq(settings: {number_of_shards: 1}) }
  end

  describe '.mappings_hash' do
    specify { expect(stub_index(:documents).mappings_hash).to eq({}) }
    specify { expect(stub_index(:documents) { define_type :document }.mappings_hash).to eq({}) }
    specify do
      expect(stub_index(:documents) do
               define_type :document do
                 field :date, type: 'date'
               end
             end.mappings_hash).to eq(mappings: {document: {properties: {date: {type: 'date'}}}})
    end
    specify do
      expect(stub_index(:documents) do
               define_type :document do
                 field :name
               end
               define_type :document2 do
                 field :name
               end
             end.mappings_hash[:mappings].keys).to match_array(%i[document document2])
    end
  end

  describe '.specification_hash' do
    before { allow(Chewy).to receive_messages(config: Chewy::Config.send(:new)) }

    specify { expect(stub_index(:documents).specification_hash).to eq({}) }
    specify { expect(stub_index(:documents) { settings number_of_shards: 1 }.specification_hash.keys).to eq([:settings]) }
    specify do
      expect(stub_index(:documents) do
               define_type :document do
                 field :name
               end
             end.specification_hash.keys).to eq([:mappings])
    end
    specify do
      expect(stub_index(:documents) do
               settings number_of_shards: 1
               define_type :document do
                 field :name
               end
             end.specification_hash.keys).to match_array(%i[mappings settings])
    end
  end

  describe '.specification' do
    subject { stub_index(:documents) }
    specify { expect(subject.specification).to be_a(Chewy::Index::Specification) }
    specify { expect(subject.specification).to equal(subject.specification) }
  end

  describe '.default_prefix' do
    before { allow(Chewy).to receive_messages(configuration: {prefix: 'testing'}) }

    context do
      before { expect(ActiveSupport::Deprecation).to receive(:warn).once }
      specify { expect(DummiesIndex.default_prefix).to eq('testing') }
    end

    context do
      before do
        DummiesIndex.class_eval do
          def self.default_prefix
            'borogoves'
          end
        end
      end

      before { expect(ActiveSupport::Deprecation).to receive(:warn).once }
      specify { expect(DummiesIndex.index_name).to eq('borogoves_dummies') }
    end
  end

  context 'index call inside index', :orm do
    before do
      stub_index(:cities) do
        define_type :city do
          field :country_name, value: (lambda do |city|
            CountriesIndex::Country.filter(term: {_id: city.country_id}).first.name
          end)
        end
      end

      stub_index(:countries) do
        define_type :country do
          field :name
        end
      end

      CountriesIndex::Country.import!(double(id: 1, name: 'Country'))
    end

    specify do
      expect { CitiesIndex::City.import!(double(country_id: 1)) }
        .to update_index(CitiesIndex::City).and_reindex(country_name: 'Country')
    end
  end
end

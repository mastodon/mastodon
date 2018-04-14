require 'spec_helper'

describe Chewy::Query::Loading, :orm do
  before { Chewy.massacre }

  before do
    stub_model(:city)
    stub_model(:country)
  end

  context 'multiple types' do
    let(:cities) { Array.new(6) { |i| City.create!(rating: i) } }
    let(:countries) { Array.new(6) { |i| Country.create!(rating: i) } }

    before do
      stub_index(:places) do
        define_type City do
          field :rating, type: 'integer', value: ->(o) { o.rating }
        end

        define_type Country do
          field :rating, type: 'integer', value: ->(o) { o.rating }
        end
      end
    end

    let(:subject) { Chewy::Query.new(PlacesIndex) }

    before { PlacesIndex.import!(cities: cities, countries: countries) }

    describe '#load' do
      specify { expect(subject.order(:rating).limit(6).load.total_count).to eq(12) }
      specify { expect(subject.order(:rating).limit(6).load).to match_array(cities.first(3) + countries.first(3)) }

      context 'mongoid', :mongoid do
        specify do
          expect(subject.order(:rating).limit(6).load(city: {scope: -> { where(:rating.lt => 2) }}))
            .to match_array(cities.first(2) + countries.first(3) + [nil])
        end
        specify do
          expect(subject.limit(6).load(city: {scope: -> { where(:rating.lt => 2) }}).order(:rating))
            .to match_array(cities.first(2) + countries.first(3) + [nil])
        end
        specify do
          expect(subject.order(:rating).limit(6).load(scope: -> { where(:rating.lt => 2) }))
            .to match_array(cities.first(2) + countries.first(2) + [nil] * 2)
        end
        specify do
          expect(subject.order(:rating).limit(6).load(city: {scope: City.where(:rating.lt => 2)}))
            .to match_array(cities.first(2) + countries.first(3) + [nil])
        end
      end

      context 'active record', :active_record do
        specify do
          expect(subject.order(:rating).limit(6).load(city: {scope: -> { where('rating < 2') }}))
            .to match_array(cities.first(2) + countries.first(3) + [nil])
        end
        specify do
          expect(subject.limit(6).load(city: {scope: -> { where('rating < 2') }}).order(:rating))
            .to match_array(cities.first(2) + countries.first(3) + [nil])
        end
        specify do
          expect(subject.order(:rating).limit(6).load(scope: -> { where('rating < 2') }))
            .to match_array(cities.first(2) + countries.first(2) + [nil] * 2)
        end
        specify do
          expect(subject.order(:rating).limit(6).load(city: {scope: City.where('rating < 2')}))
            .to match_array(cities.first(2) + countries.first(3) + [nil])
        end
      end
    end

    describe '#preload' do
      context 'mongoid', :mongoid do
        specify do
          expect(subject.order(:rating).limit(6).preload(scope: -> { where(:rating.lt => 2) })
          .map(&:_object)).to match_array(cities.first(2) + countries.first(2) + [nil] * 2)
        end
        specify do
          expect(subject.limit(6).preload(scope: -> { where(:rating.lt => 2) }).order(:rating)
          .map(&:_object)).to match_array(cities.first(2) + countries.first(2) + [nil] * 2)
        end

        specify do
          expect(subject.order(:rating).limit(6).preload(only: :city, scope: -> { where(:rating.lt => 2) })
          .map(&:_object)).to match_array(cities.first(2) + [nil] * 4)
        end
        specify do
          expect(subject.order(:rating).limit(6).preload(except: [:city], scope: -> { where(:rating.lt => 2) })
          .map(&:_object)).to match_array(countries.first(2) + [nil] * 4)
        end
        specify do
          expect(subject.order(:rating).limit(6).preload(only: [:city], except: :city, scope: -> { where(:rating.lt => 2) })
          .map(&:_object)).to match_array([nil] * 6)
        end
      end

      context 'active record', :active_record do
        specify do
          expect(subject.order(:rating).limit(6).preload(scope: -> { where('rating < 2') })
          .map(&:_object)).to match_array(cities.first(2) + countries.first(2) + [nil] * 2)
        end
        specify do
          expect(subject.limit(6).preload(scope: -> { where('rating < 2') }).order(:rating)
          .map(&:_object)).to match_array(cities.first(2) + countries.first(2) + [nil] * 2)
        end

        specify do
          expect(subject.order(:rating).limit(6).preload(only: :city, scope: -> { where('rating < 2') })
          .map(&:_object)).to match_array(cities.first(2) + [nil] * 4)
        end
        specify do
          expect(subject.order(:rating).limit(6).preload(except: [:city], scope: -> { where('rating < 2') })
          .map(&:_object)).to match_array(countries.first(2) + [nil] * 4)
        end
        specify do
          expect(subject.order(:rating).limit(6).preload(only: [:city], except: :city, scope: -> { where('rating < 2') })
          .map(&:_object)).to match_array([nil] * 6)
        end
      end
    end
  end
end

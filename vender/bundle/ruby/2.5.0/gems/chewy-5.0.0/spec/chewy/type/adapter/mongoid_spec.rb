require 'spec_helper'

describe Chewy::Type::Adapter::Mongoid, :mongoid do
  before do
    stub_model(:city)
    stub_model(:country)
    if adapter == :mongoid && Mongoid::VERSION.start_with?('6')
      City.belongs_to :country, optional: true
    else
      City.belongs_to :country
    end
    Country.has_many :cities
  end

  describe '#name' do
    specify { expect(described_class.new(City).name).to eq('City') }
    specify { expect(described_class.new(City.order(:id.asc)).name).to eq('City') }
    specify { expect(described_class.new(City, name: 'town').name).to eq('Town') }

    context do
      before { stub_model('namespace/city') }

      specify { expect(described_class.new(Namespace::City).name).to eq('City') }
      specify { expect(described_class.new(Namespace::City.order(:id.asc)).name).to eq('City') }
    end
  end

  describe '#default_scope' do
    specify { expect(described_class.new(City).default_scope).to eq(City.all) }
    specify { expect(described_class.new(City.order(:id.asc)).default_scope).to eq(City.all) }
    specify { expect(described_class.new(City.limit(10)).default_scope).to eq(City.all) }
    specify { expect(described_class.new(City.offset(10)).default_scope).to eq(City.all) }
    specify { expect(described_class.new(City.where(rating: 10)).default_scope).to eq(City.where(rating: 10)) }
  end

  describe '#type_name' do
    specify { expect(described_class.new(City).type_name).to eq('city') }
    specify { expect(described_class.new(City.order(:id.asc)).type_name).to eq('city') }
    specify { expect(described_class.new(City, name: 'town').type_name).to eq('town') }

    context do
      before { stub_model('namespace/city') }

      specify { expect(described_class.new(Namespace::City).type_name).to eq('city') }
      specify { expect(described_class.new(Namespace::City.order(:id.asc)).type_name).to eq('city') }
    end
  end

  describe '#identify' do
    subject { described_class.new(City) }
    let!(:cities) { Array.new(3) { City.create! } }

    specify { expect(subject.identify(City.all)).to match_array(cities.map(&:id).map(&:to_s)) }
    specify { expect(subject.identify(cities)).to eq(cities.map(&:id).map(&:to_s)) }
    specify { expect(subject.identify(cities.first)).to eq([cities.first.id.to_s]) }
    specify { expect(subject.identify(cities.first(2).map(&:id))).to eq(cities.first(2).map(&:id).map(&:to_s)) }

    context 'non-bson ids' do
      let!(:cities) { Array.new(3) { |i| City.create! id: i + 1 } }

      specify { expect(subject.identify(City.all)).to match_array(cities.map(&:id)) }
      specify { expect(subject.identify(cities)).to eq(cities.map(&:id)) }
      specify { expect(subject.identify(cities.first)).to eq([cities.first.id]) }
      specify { expect(subject.identify(cities.first(2).map(&:id))).to eq(cities.first(2).map(&:id)) }
    end
  end

  describe '#import' do
    def import(*args)
      result = []
      subject.import(*args) { |data| result.push data }
      result
    end

    context do
      let!(:cities) { Array.new(3) { City.create! }.sort_by(&:id) }
      let!(:deleted) { Array.new(4) { City.create!.tap(&:destroy) }.sort_by(&:id) }
      subject { described_class.new(City) }

      specify { expect(import).to match([{index: match_array(cities)}]) }
      specify { expect(import(nil)).to eq([]) }

      specify { expect(import(City.order(:id.asc))).to eq([{index: cities}]) }
      specify do
        expect(import(City.order(:id.asc), batch_size: 2))
          .to eq([{index: cities.first(2)}, {index: cities.last(1)}])
      end

      specify { expect(import(cities)).to eq([{index: cities}]) }
      specify do
        expect(import(cities, batch_size: 2))
          .to eq([{index: cities.first(2)}, {index: cities.last(1)}])
      end
      specify do
        expect(import(cities, deleted))
          .to eq([{index: cities}, {delete: deleted}])
      end
      specify do
        expect(import(cities, deleted, batch_size: 2)).to eq([
          {index: cities.first(2)},
          {index: cities.last(1)},
          {delete: deleted.first(2)},
          {delete: deleted.last(2)}
        ])
      end

      specify { expect(import(cities.map(&:id))).to eq([{index: cities}]) }
      specify { expect(import(deleted.map(&:id))).to eq([{delete: deleted.map(&:id)}]) }
      specify do
        expect(import(cities.map(&:id), batch_size: 2))
          .to eq([{index: cities.first(2)}, {index: cities.last(1)}])
      end
      specify do
        expect(import(cities.map(&:id), deleted.map(&:id)))
          .to eq([{index: cities}, {delete: deleted.map(&:id)}])
      end
      specify do
        expect(import(cities.map(&:id), deleted.map(&:id), batch_size: 2)).to eq([
          {index: cities.first(2)},
          {index: cities.last(1)},
          {delete: deleted.first(2).map(&:id)},
          {delete: deleted.last(2).map(&:id)}
        ])
      end

      specify { expect(import(cities.first, nil)).to eq([{index: [cities.first]}]) }
      specify { expect(import(cities.first.id, nil)).to eq([{index: [cities.first]}]) }
    end

    context 'additional delete conditions' do
      let!(:cities) { Array.new(4) { |i| City.create! rating: i } }
      before { cities.last(2).map(&:destroy) }
      subject { described_class.new(City) }

      before do
        City.class_eval do
          def delete_already?
            rating.in?([1, 3])
          end
        end
      end
      subject { described_class.new(City, delete_if: -> { delete_already? }) }

      specify do
        expect(import(City.all)).to eq([
          {index: [cities[0]], delete: [cities[1]]}
        ])
      end
      specify do
        expect(import(cities)).to eq([
          {index: [cities[0]], delete: [cities[1]]},
          {delete: cities.last(2)}
        ])
      end
      specify do
        expect(import(cities.map(&:id))).to eq([
          {index: [cities[0]], delete: [cities[1]]},
          {delete: cities.last(2).map(&:id)}
        ])
      end
    end

    context 'default scope' do
      let!(:cities) { Array.new(4) { |i| City.create!(id: i, rating: i / 3) }.sort_by(&:id) }
      let!(:deleted) { Array.new(3) { |i| City.create!(id: 4 + i).tap(&:destroy) }.sort_by(&:id) }
      subject { described_class.new(City.where(rating: 0)) }

      specify { expect(import).to eq([{index: cities.first(3)}]) }

      specify do
        expect(import(City.where(:rating.lt => 2).order(:id.asc)))
          .to eq([{index: cities.first(3)}])
      end
      specify do
        expect(import(City.where(:rating.lt => 2).order(:id.asc), batch_size: 2))
          .to eq([{index: cities.first(2)}, {index: [cities[2]]}])
      end
      specify do
        expect(import(City.where(:rating.lt => 1).order(:id.asc)))
          .to eq([{index: cities.first(3)}])
      end
      specify { expect(import(City.where(:rating.gt => 1).order(:id.asc))).to eq([]) }

      specify do
        expect(import(cities.first(2)))
          .to eq([{index: cities.first(2)}])
      end
      specify do
        expect(import(cities))
          .to eq([{index: cities.first(3)}, {delete: cities.last(1)}])
      end
      specify do
        expect(import(cities, batch_size: 2))
          .to eq([{index: cities.first(2)}, {index: [cities[2]]}, {delete: cities.last(1)}])
      end
      specify do
        expect(import(cities, deleted))
          .to eq([{index: cities.first(3)}, {delete: cities.last(1) + deleted}])
      end
      specify do
        expect(import(cities, deleted, batch_size: 3)).to eq([
          {index: cities.first(3)},
          {delete: cities.last(1) + deleted.first(2)},
          {delete: deleted.last(1)}
        ])
      end

      specify do
        expect(import(cities.first(2).map(&:id)))
          .to eq([{index: cities.first(2)}])
      end
      specify do
        expect(import(cities.map(&:id)))
          .to eq([{index: cities.first(3)}, {delete: [cities.last.id]}])
      end
      specify do
        expect(import(cities.map(&:id), batch_size: 2))
          .to eq([{index: cities.first(2)}, {index: [cities[2]]}, {delete: [cities.last.id]}])
      end
      specify do
        expect(import(cities.map(&:id), deleted.map(&:id)))
          .to eq([{index: cities.first(3)}, {delete: [cities.last.id] + deleted.map(&:id)}])
      end
      specify do
        expect(import(cities.map(&:id), deleted.map(&:id), batch_size: 3)).to eq([
          {index: cities.first(3)},
          {delete: [cities.last.id] + deleted.first(2).map(&:id)},
          {delete: deleted.last(1).map(&:id)}
        ])
      end
    end

    context 'error handling' do
      let!(:cities) { Array.new(6) { City.create! } }
      let!(:deleted) { Array.new(4) { City.create!.tap(&:destroy) } }
      let(:ids) { (cities + deleted).map(&:id) }
      subject { described_class.new(City) }

      let(:data_comparer) do
        lambda do |id, data|
          objects = data[:index] || data[:delete]
          !objects.map { |o| o.respond_to?(:id) ? o.id : o }.include?(id)
        end
      end

      context 'implicit scope' do
        specify { expect(subject.import { |_data| true }).to eq(true) }
        specify { expect(subject.import { |_data| false }).to eq(false) }
        specify { expect(subject.import(batch_size: 2, &data_comparer.curry[cities[0].id])).to eq(false) }
        specify { expect(subject.import(batch_size: 2, &data_comparer.curry[cities[2].id])).to eq(false) }
        specify { expect(subject.import(batch_size: 2, &data_comparer.curry[cities[4].id])).to eq(false) }
        specify { expect(subject.import(batch_size: 2, &data_comparer.curry[deleted[0].id])).to eq(true) }
        specify { expect(subject.import(batch_size: 2, &data_comparer.curry[deleted[2].id])).to eq(true) }
      end

      context 'explicit scope' do
        let(:scope) { City.where(:id.in => ids) }

        specify { expect(subject.import(scope) { |_data| true }).to eq(true) }
        specify { expect(subject.import(scope) { |_data| false }).to eq(false) }
        specify { expect(subject.import(scope, batch_size: 2, &data_comparer.curry[cities[0].id])).to eq(false) }
        specify { expect(subject.import(scope, batch_size: 2, &data_comparer.curry[cities[2].id])).to eq(false) }
        specify { expect(subject.import(scope, batch_size: 2, &data_comparer.curry[cities[4].id])).to eq(false) }
        specify { expect(subject.import(scope, batch_size: 2, &data_comparer.curry[deleted[0].id])).to eq(true) }
        specify { expect(subject.import(scope, batch_size: 2, &data_comparer.curry[deleted[2].id])).to eq(true) }
      end

      context 'objects' do
        specify { expect(subject.import(cities + deleted) { |_data| true }).to eq(true) }
        specify { expect(subject.import(cities + deleted) { |_data| false }).to eq(false) }
        specify { expect(subject.import(cities + deleted, batch_size: 2, &data_comparer.curry[cities[0].id])).to eq(false) }
        specify { expect(subject.import(cities + deleted, batch_size: 2, &data_comparer.curry[cities[2].id])).to eq(false) }
        specify { expect(subject.import(cities + deleted, batch_size: 2, &data_comparer.curry[cities[4].id])).to eq(false) }
        specify { expect(subject.import(cities + deleted, batch_size: 2, &data_comparer.curry[deleted[0].id])).to eq(false) }
        specify { expect(subject.import(cities + deleted, batch_size: 2, &data_comparer.curry[deleted[2].id])).to eq(false) }
      end

      context 'ids' do
        specify { expect(subject.import(ids) { |_data| true }).to eq(true) }
        specify { expect(subject.import(ids) { |_data| false }).to eq(false) }
        specify { expect(subject.import(ids, batch_size: 2, &data_comparer.curry[cities[0].id])).to eq(false) }
        specify { expect(subject.import(ids, batch_size: 2, &data_comparer.curry[cities[2].id])).to eq(false) }
        specify { expect(subject.import(ids, batch_size: 2, &data_comparer.curry[cities[4].id])).to eq(false) }
        specify { expect(subject.import(ids, batch_size: 2, &data_comparer.curry[deleted[0].id])).to eq(false) }
        specify { expect(subject.import(ids, batch_size: 2, &data_comparer.curry[deleted[2].id])).to eq(false) }
      end
    end
  end

  describe '#import_fields' do
    subject { described_class.new(Country) }
    let!(:countries) { Array.new(4) { |i| Country.create!(rating: i) { |c| c.id = i + 1 } } }
    let!(:cities) { Array.new(6) { |i| City.create!(rating: i + 3, country_id: (i + 4) / 2) { |c| c.id = i + 3 } } }

    specify { expect(subject.import_fields).to match([contain_exactly(1, 2, 3, 4)]) }
    specify { expect(subject.import_fields(fields: [:rating])).to match([contain_exactly([1, 0], [2, 1], [3, 2], [4, 3])]) }

    context 'scopes' do
      context do
        subject { described_class.new(Country.includes(:cities)) }

        specify { expect(subject.import_fields).to match([contain_exactly(1, 2, 3, 4)]) }
        specify { expect(subject.import_fields(fields: [:rating])).to match([contain_exactly([1, 0], [2, 1], [3, 2], [4, 3])]) }
      end

      context 'ignores default scope if another scope is passed' do
        subject { described_class.new(Country.where(:rating.gt => 2)) }

        specify { expect(subject.import_fields(Country.where(:rating.lt => 2))).to match([contain_exactly(1, 2)]) }
        specify { expect(subject.import_fields(Country.where(:rating.lt => 2), fields: [:rating])).to match([contain_exactly([1, 0], [2, 1])]) }
      end
    end

    context 'objects/ids' do
      specify { expect(subject.import_fields(1, 2)).to match([contain_exactly(1, 2)]) }
      specify { expect(subject.import_fields(1, 2, fields: [:rating])).to match([contain_exactly([1, 0], [2, 1])]) }

      specify { expect(subject.import_fields(countries.first(2))).to match([contain_exactly(1, 2)]) }
      specify { expect(subject.import_fields(countries.first(2), fields: [:rating])).to match([contain_exactly([1, 0], [2, 1])]) }
    end

    context 'batch_size' do
      specify { expect(subject.import_fields(batch_size: 2)).to match([contain_exactly(1, 2), contain_exactly(3, 4)]) }
      specify { expect(subject.import_fields(batch_size: 2, fields: [:rating])).to match([contain_exactly([1, 0], [2, 1]), contain_exactly([3, 2], [4, 3])]) }

      specify { expect(subject.import_fields(Country.where(:rating.lt => 2), batch_size: 2)).to match([contain_exactly(1, 2)]) }
      specify { expect(subject.import_fields(Country.where(:rating.lt => 2), batch_size: 2, fields: [:rating])).to match([contain_exactly([1, 0], [2, 1])]) }

      specify { expect(subject.import_fields(1, 2, 3, batch_size: 2)).to match([contain_exactly(1, 2), [3]]) }
      specify { expect(subject.import_fields(1, 2, 3, batch_size: 2, fields: [:rating])).to match([contain_exactly([1, 0], [2, 1]), [[3, 2]]]) }

      specify { expect(subject.import_fields(countries.first(3), batch_size: 2)).to match([contain_exactly(1, 2), [3]]) }
      specify { expect(subject.import_fields(countries.first(3), batch_size: 2, fields: [:rating])).to match([contain_exactly([1, 0], [2, 1]), [[3, 2]]]) }
    end
  end

  describe '#load' do
    context do
      let!(:cities) { Array.new(3) { |i| City.create!(id: i, rating: i / 2) }.sort_by(&:id) }
      let!(:deleted) { Array.new(2) { |i| City.create!(id: 3 + i).tap(&:destroy) }.sort_by(&:id) }
      let(:city_ids) { cities.map(&:id) }
      let(:deleted_ids) { deleted.map(&:id) }

      let(:type) { double(type_name: 'user') }

      subject { described_class.new(City) }

      specify { expect(subject.load(city_ids, _type: type)).to eq(cities) }
      specify { expect(subject.load(city_ids.reverse, _type: type)).to eq(cities.reverse) }
      specify { expect(subject.load(deleted_ids, _type: type)).to eq([nil, nil]) }
      specify { expect(subject.load(city_ids + deleted_ids, _type: type)).to eq([*cities, nil, nil]) }
      specify do
        expect(subject.load(city_ids, _type: type, scope: -> { where(rating: 0) }))
          .to eq(cities.first(2) + [nil])
      end
      specify do
        expect(subject.load(city_ids,
          _type: type, scope: -> { where(rating: 0) }, user: {scope: -> { where(rating: 1) }}))
          .to eq([nil, nil] + cities.last(1))
      end
      specify do
        expect(subject.load(city_ids, _type: type, scope: City.where(rating: 1)))
          .to eq([nil, nil] + cities.last(1))
      end
      specify do
        expect(subject.load(city_ids,
          _type: type, scope: City.where(rating: 1), user: {scope: -> { where(rating: 0) }}))
          .to eq(cities.first(2) + [nil])
      end
    end
  end
end

require 'spec_helper'

describe Chewy::Type::Import::BulkBuilder do
  before { Chewy.massacre }

  subject { described_class.new(type, index: index, delete: delete, fields: fields) }
  let(:type) { PlacesIndex::City }
  let(:index) { [] }
  let(:delete) { [] }
  let(:fields) { [] }

  describe '#bulk_body' do
    context 'simple bulk', :orm do
      before do
        stub_model(:city)
        stub_index(:places) do
          define_type City do
            field :name, :rating
          end
        end
      end
      let(:cities) { Array.new(3) { |i| City.create!(id: i + 1, name: "City#{i + 17}", rating: 42) } }

      specify { expect(subject.bulk_body).to eq([]) }

      context do
        let(:index) { cities }
        specify do
          expect(subject.bulk_body).to eq([
            {index: {_id: 1, data: {'name' => 'City17', 'rating' => 42}}},
            {index: {_id: 2, data: {'name' => 'City18', 'rating' => 42}}},
            {index: {_id: 3, data: {'name' => 'City19', 'rating' => 42}}}
          ])
        end
      end

      context do
        let(:delete) { cities }
        specify do
          expect(subject.bulk_body).to eq([
            {delete: {_id: 1}}, {delete: {_id: 2}}, {delete: {_id: 3}}
          ])
        end
      end

      context do
        let(:index) { cities.first(2) }
        let(:delete) { [cities.last] }
        specify do
          expect(subject.bulk_body).to eq([
            {index: {_id: 1, data: {'name' => 'City17', 'rating' => 42}}},
            {index: {_id: 2, data: {'name' => 'City18', 'rating' => 42}}},
            {delete: {_id: 3}}
          ])
        end

        context ':fields' do
          let(:fields) { %w[name] }
          specify do
            expect(subject.bulk_body).to eq([
              {update: {_id: 1, data: {doc: {'name' => 'City17'}}}},
              {update: {_id: 2, data: {doc: {'name' => 'City18'}}}},
              {delete: {_id: 3}}
            ])
          end
        end
      end
    end

    context 'parent-child relationship', :orm do
      before do
        stub_model(:country)
        stub_model(:city)
        adapter == :sequel ? City.many_to_one(:country) : City.belongs_to(:country)
      end

      before do
        stub_index(:places) do
          define_type Country do
            field :name
          end

          define_type City do
            root parent: 'country', parent_id: -> { country_id } do
              field :name
              field :rating
            end
          end
        end
      end

      before { PlacesIndex::Country.import(country) }
      let(:country) { Country.create!(id: 1, name: 'country') }
      let(:another_country) { Country.create!(id: 2, name: 'another country') }
      let(:city) { City.create!(id: 4, country_id: country.id, name: 'city', rating: 42) }

      context 'indexing' do
        let(:index) { [city] }

        specify do
          expect(subject.bulk_body).to eq([
            {index: {_id: city.id, parent: country.id, data: {'name' => 'city', 'rating' => 42}}}
          ])
        end

        context do
          let(:fields) { %w[name] }

          specify do
            expect(subject.bulk_body).to eq([
              {update: {_id: city.id, parent: country.id, data: {doc: {'name' => 'city'}}}}
            ])
          end
        end
      end

      context 'updating parent' do
        before do
          PlacesIndex::City.import(city)
          city.update_attributes(country_id: another_country.id)
        end
        let(:index) { [city] }

        specify do
          expect(subject.bulk_body).to eq([
            {delete: {_id: city.id, parent: country.id.to_s}},
            {index: {_id: city.id, parent: another_country.id, data: {'name' => 'city', 'rating' => 42}}}
          ])
        end

        context do
          let(:fields) { %w[name] }

          specify do
            expect(subject.bulk_body).to eq([
              {delete: {_id: city.id, parent: country.id.to_s}},
              {index: {_id: city.id, parent: another_country.id, data: {'name' => 'city', 'rating' => 42}}}
            ])
          end
        end
      end

      context 'destroying' do
        before { PlacesIndex::City.import(city) }
        let(:delete) { [city] }

        specify do
          expect(subject.bulk_body).to eq([
            {delete: {_id: city.id, parent: country.id.to_s}}
          ])
        end
      end
    end

    context 'custom id', :orm do
      before do
        stub_model(:city)
      end

      before do
        stub_index(:places) do
          define_type City do
            root id: -> { name } do
              field :rating
            end
          end
        end
      end

      let(:london) { City.create(id: 1, name: 'London', rating: 4) }

      specify do
        expect { PlacesIndex::City.import(london) }
          .to update_index(PlacesIndex::City).and_reindex(london.name)
      end

      context 'indexing' do
        let(:index) { [london] }

        specify do
          expect(subject.bulk_body).to eq([
            {index: {_id: london.name, data: {'rating' => 4}}}
          ])
        end
      end

      context 'destroying' do
        let(:delete) { [london] }

        specify do
          expect(subject.bulk_body).to eq([
            {delete: {_id: london.name}}
          ])
        end
      end
    end

    context 'crutches' do
      before do
        stub_index(:places) do
          define_type :city do
            crutch :names do |collection|
              collection.map { |item| [item.id, "Name#{item.id}"] }.to_h
            end

            field :name, value: ->(o, c) { c.names[o.id] }
          end
        end
      end

      let(:index) { [double(id: 42)] }

      specify do
        expect(subject.bulk_body).to eq([
          {index: {_id: 42, data: {'name' => 'Name42'}}}
        ])
      end

      context 'witchcraft' do
        before { PlacesIndex::City.witchcraft! }
        specify do
          expect(subject.bulk_body).to eq([
            {index: {_id: 42, data: {'name' => 'Name42'}}}
          ])
        end
      end
    end

    context 'empty ids' do
      before do
        stub_index(:places) do
          define_type :city do
            field :name
          end
        end
      end

      let(:index) { [{id: 1, name: 'Name0'}, double(id: '', name: 'Name1'), double(name: 'Name2')] }
      let(:delete) { [double(id: '', name: 'Name3'), {name: 'Name4'}, '', 2] }

      specify do
        expect(subject.bulk_body).to eq([
          {index: {_id: 1, data: {'name' => 'Name0'}}},
          {index: {data: {'name' => 'Name1'}}},
          {index: {data: {'name' => 'Name2'}}},
          {delete: {_id: {'name' => 'Name4'}}},
          {delete: {_id: 2}}
        ])
      end

      context do
        let(:fields) { %w[name] }

        specify do
          expect(subject.bulk_body).to eq([
            {update: {_id: 1, data: {doc: {'name' => 'Name0'}}}},
            {delete: {_id: {'name' => 'Name4'}}},
            {delete: {_id: 2}}
          ])
        end
      end
    end
  end

  describe '#index_objects_by_id' do
    before do
      stub_index(:places) do
        define_type :city do
          field :name
        end
      end
    end

    let(:index) { [double(id: 1), double(id: 2), double(id: ''), double] }
    let(:delete) { [double(id: 3)] }

    specify { expect(subject.index_objects_by_id).to eq('1' => index.first, '2' => index.second) }
  end
end

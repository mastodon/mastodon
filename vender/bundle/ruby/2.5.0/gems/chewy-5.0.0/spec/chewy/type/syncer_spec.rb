require 'spec_helper'

describe Chewy::Type::Syncer, :orm do
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

  shared_examples 'sync' do |options = {}|
    let!(:cities) { Array.new(3) { |i| City.create!(name: "Name#{i + 1}") } }
    subject { described_class.new(CitiesIndex::City, **options) }

    describe '#perform' do
      before { CitiesIndex::City.import!(cities) }
      specify { expect(subject.perform).to eq(0) }

      context do
        before do
          cities.first.destroy
          sleep(1) if ActiveSupport::VERSION::STRING < '4.1.0'
          cities.last.update(name: 'Name5')
        end
        let!(:additional_city) { City.create!(name: 'Name4') }

        specify { expect(subject.perform).to eq(3) }
        specify do
          expect { subject.perform }.to update_index(CitiesIndex::City)
            .and_reindex(additional_city, cities.last)
            .and_delete(cities.first).only
        end
      end

      context 'does not support outdated sync' do
        before do
          stub_index(:cities) do
            define_type City do
              field :name
            end
          end
        end

        specify { expect(subject.perform).to eq(0) }

        context do
          before do
            cities.first.destroy
            cities.last.update(name: 'Name5')
          end
          let!(:additional_city) { City.create!(name: 'Name4') }

          specify { expect(subject.perform).to eq(2) }
          specify do
            expect { subject.perform }.to update_index(CitiesIndex::City)
              .and_reindex(additional_city)
              .and_delete(cities.first).only
          end
        end
      end
    end

    describe '#missing_ids' do
      specify { expect(subject.missing_ids).to match_array(cities.map(&:id).map(&:to_s)) }

      context do
        before { CitiesIndex::City.import!(cities) }
        specify { expect(subject.missing_ids).to eq([]) }

        context do
          let!(:additional_city) { City.create!(name: 'Name4') }
          before { cities.first.destroy }
          specify { expect(subject.missing_ids).to contain_exactly(cities.first.id.to_s, additional_city.id.to_s) }
        end
      end
    end

    describe '#outdated_ids' do
      specify { expect(subject.outdated_ids).to eq([]) }

      context do
        before { CitiesIndex::City.import!(cities) }
        specify { expect(subject.outdated_ids).to eq([]) }

        context do
          before do
            sleep(1) if ActiveSupport::VERSION::STRING < '4.1.0'
            cities.first.update(name: 'Name4')
            cities.last.update(name: 'Name5')
          end
          specify { expect(subject.outdated_ids).to contain_exactly(cities.first.id.to_s, cities.last.id.to_s) }
        end
      end

      context 'does not support outdated sync' do
        before do
          stub_index(:cities) do
            define_type City do
              field :name
            end
          end
        end

        specify { expect(subject.outdated_ids).to eq([]) }

        context do
          before do
            cities.first.update(name: 'Name4')
            cities.last.update(name: 'Name5')
          end
          specify { expect(subject.outdated_ids).to eq([]) }
        end
      end
    end
  end

  include_examples 'sync'
  include_examples 'sync', parallel: 0
end

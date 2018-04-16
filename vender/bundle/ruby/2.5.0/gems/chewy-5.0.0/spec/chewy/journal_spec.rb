require 'spec_helper'

describe Chewy::Journal do
  context 'journaling', :orm do
    ['', 'namespace/'].each do |namespace|
      context namespace.present? ? 'with namespace' : 'without namespace' do
        before do
          stub_model(:city) do
            update_index "#{namespace}places#city", :self
          end
          stub_model(:country) do
            update_index "#{namespace}places#country", :self
          end

          stub_index("#{namespace}places") do
            define_type City do
              default_import_options journal: true
            end
            define_type Country do
              default_import_options journal: true
            end
          end

          Chewy.massacre
          Chewy.settings[:prefix] = 'some_prefix'
          Timecop.freeze(time)
        end

        after do
          Chewy.settings[:prefix] = nil
          Timecop.return
        end

        let(:time) { Time.now }
        let(:import_time) { time + 1 }
        let(:update_time) { time + 2 }
        let(:destroy_time) { time + 3 }

        def timestamp(time)
          time.to_i
        end

        specify do
          places_index = namespace.present? ? Namespace::PlacesIndex : PlacesIndex
          Chewy.strategy(:urgent) do
            cities = Array.new(2) { |i| City.create!(id: i + 1) }
            countries = Array.new(2) { |i| Country.create!(id: i + 1) }
            Country.create!(id: 3)

            Timecop.freeze(import_time)

            places_index.import

            expect(Chewy::Stash::Journal.exists?).to eq true

            Timecop.freeze(update_time)
            cities.first.update_attributes!(name: 'Supername')

            Timecop.freeze(destroy_time)
            countries.last.destroy

            journal_entries = Chewy::Stash::Journal.order(:created_at).hits.map { |r| r['_source'] }
            expected_journal = [
              {
                'index_name' => "#{namespace}places",
                'type_name' => 'city',
                'action' => 'index',
                'references' => ['1'].map(&Base64.method(:encode64)),
                'created_at' => time.utc.as_json
              },
              {
                'index_name' => "#{namespace}places",
                'type_name' => 'city',
                'action' => 'index',
                'references' => ['2'].map(&Base64.method(:encode64)),
                'created_at' => time.utc.as_json
              },
              {
                'index_name' => "#{namespace}places",
                'type_name' => 'country',
                'action' => 'index',
                'references' => ['1'].map(&Base64.method(:encode64)),
                'created_at' => time.utc.as_json
              },
              {
                'index_name' => "#{namespace}places",
                'type_name' => 'country',
                'action' => 'index',
                'references' => ['2'].map(&Base64.method(:encode64)),
                'created_at' => time.utc.as_json
              },
              {
                'index_name' => "#{namespace}places",
                'type_name' => 'country',
                'action' => 'index',
                'references' => ['3'].map(&Base64.method(:encode64)),
                'created_at' => time.utc.as_json
              },
              {
                'index_name' => "#{namespace}places",
                'type_name' => 'city',
                'action' => 'index',
                'references' => %w[1 2].map(&Base64.method(:encode64)),
                'created_at' => import_time.utc.as_json
              },
              {
                'index_name' => "#{namespace}places",
                'type_name' => 'country',
                'action' => 'index',
                'references' => %w[1 2 3].map(&Base64.method(:encode64)),
                'created_at' => import_time.utc.as_json
              },
              {
                'index_name' => "#{namespace}places",
                'type_name' => 'city',
                'action' => 'index',
                'references' => ['1'].map(&Base64.method(:encode64)),
                'created_at' => update_time.utc.as_json
              },
              {
                'index_name' => "#{namespace}places",
                'type_name' => 'country',
                'action' => 'delete',
                'references' => ['2'].map(&Base64.method(:encode64)),
                'created_at' => destroy_time.utc.as_json
              }
            ]

            expect(Chewy::Stash::Journal.count).to eq 9
            expect(journal_entries).to eq expected_journal

            journal_entries = Chewy::Stash::Journal.entries(import_time - 1)
            expect(journal_entries.size).to eq 4

            # simulate lost data
            Chewy.client.delete(index: "#{Chewy.settings[:prefix]}_places", type: 'city', id: 1, refresh: true)
            expect(places_index::City.count).to eq 1

            described_class.new.apply(time)
            expect(places_index::City.count).to eq 2

            clean_response = described_class.new.clean(import_time)
            expect(clean_response['deleted'] || clean_response['_indices']['_all']['deleted']).to eq 7
            Chewy.client.indices.refresh
            expect(Chewy::Stash::Journal.count).to eq 2

            Timecop.return
          end
        end
      end
    end
  end

  context do
    before { Chewy.massacre }
    before do
      stub_model(:city) do
        update_index 'cities', :self
      end
      stub_model(:country) do
        update_index 'countries', :self
      end

      stub_index(:cities) do
        define_type City do
          default_import_options journal: true
        end
      end
      stub_index(:countries) do
        define_type Country do
          default_import_options journal: true
        end
      end
    end

    describe '#apply' do
      specify { expect(described_class.new(CitiesIndex).apply(2.minutes.ago)).to eq(0) }

      context 'with an index filter' do
        let(:time) { Time.now }

        before { Timecop.freeze(time) }
        after { Timecop.return }

        specify do
          Chewy.strategy(:urgent) do
            Array.new(2) { |i| City.create!(id: i + 1) }
            Array.new(2) { |i| Country.create!(id: i + 1) }

            # simulate lost data
            Chewy.client.delete(index: 'cities', type: 'city', id: 1, refresh: true)
            Chewy.client.delete(index: 'countries', type: 'country', id: 1, refresh: true)
            expect(CitiesIndex.all.to_a.length).to eq 1
            expect(CountriesIndex.all.to_a.length).to eq 1

            # Replay on specific index
            expect(described_class.new(CitiesIndex).apply(time)).to eq(2)
            expect(CitiesIndex.all.to_a.length).to eq 2
            expect(CountriesIndex.all.to_a.length).to eq 1

            # Replay on both
            Chewy.client.delete(index: 'cities', type: 'city', id: 1, refresh: true)
            expect(CitiesIndex.all.to_a.length).to eq 1
            expect(described_class.new(CitiesIndex, CountriesIndex).apply(time)).to eq(4)
            expect(CitiesIndex.all.to_a.length).to eq 2
            expect(CountriesIndex.all.to_a.length).to eq 2
          end
        end
      end

      context 'retries' do
        let(:time) { Time.now.to_i }
        before do
          Timecop.freeze
          Chewy.strategy(:urgent)
          City.create!(id: 1)
        end

        after do
          Chewy.strategy.pop
          Timecop.return
        end

        specify 'journal was cleaned after the first call' do
          expect(Chewy::Stash::Journal).to receive(:entries).exactly(2).and_call_original
          expect(described_class.new.apply(time)).to eq(1)
        end

        context 'endless journal' do
          let(:count_of_checks) { 10 } # default
          let!(:journal_entries) do
            record = Chewy::Stash::Journal.entries(time).first
            Array.new(count_of_checks) do |i|
              Chewy::Stash::Journal::Journal.new(
                record.attributes.merge(
                  'created_at' => time.to_i + i,
                  'references' => [i.to_s]
                )
              )
            end
          end

          specify '10 retries by default' do
            expect(Chewy::Stash::Journal)
              .to receive(:entries).exactly(count_of_checks) { [journal_entries.shift].compact }
            expect(described_class.new.apply(time)).to eq(10)
          end

          specify 'with :once parameter set' do
            expect(Chewy::Stash::Journal)
              .to receive(:entries).exactly(1) { [journal_entries.shift].compact }
            expect(described_class.new.apply(time, retries: 1)).to eq(1)
          end

          context 'with retries parameter set' do
            let(:retries) { 5 }

            specify do
              expect(Chewy::Stash::Journal)
                .to receive(:entries).exactly(retries) { [journal_entries.shift].compact }
              expect(described_class.new.apply(time, retries: retries)).to eq(5)
            end
          end
        end
      end
    end
  end
end

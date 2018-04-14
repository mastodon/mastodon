require 'spec_helper'

describe Chewy::Index::Actions do
  before { Chewy.massacre }

  before { stub_index :dummies }

  describe '.exists?' do
    specify { expect(DummiesIndex.exists?).to eq(false) }

    context do
      before { DummiesIndex.create }
      specify { expect(DummiesIndex.exists?).to eq(true) }
    end
  end

  describe '.create' do
    specify { expect(DummiesIndex.create['acknowledged']).to eq(true) }
    specify { expect(DummiesIndex.create('2013')['acknowledged']).to eq(true) }

    context do
      before { DummiesIndex.create }
      specify { expect(DummiesIndex.create).to eq(false) }
      specify { expect(DummiesIndex.create('2013')).to eq(false) }
    end

    context do
      before { DummiesIndex.create '2013' }
      specify { expect(Chewy.client.indices.exists(index: 'dummies')).to eq(true) }
      specify { expect(Chewy.client.indices.exists(index: 'dummies_2013')).to eq(true) }
      specify { expect(DummiesIndex.aliases).to eq([]) }
      specify { expect(DummiesIndex.indexes).to eq(['dummies_2013']) }
      specify { expect(DummiesIndex.create('2013')).to eq(false) }
      specify { expect(DummiesIndex.create('2014')['acknowledged']).to eq(true) }

      context do
        before { DummiesIndex.create '2014' }
        specify { expect(DummiesIndex.indexes).to match_array(%w[dummies_2013 dummies_2014]) }
      end
    end

    context do
      before { DummiesIndex.create '2013', alias: false }
      specify { expect(Chewy.client.indices.exists(index: 'dummies')).to eq(false) }
      specify { expect(Chewy.client.indices.exists(index: 'dummies_2013')).to eq(true) }
      specify { expect(DummiesIndex.aliases).to eq([]) }
      specify { expect(DummiesIndex.indexes).to eq([]) }
    end
  end

  describe '.create!' do
    specify { expect(DummiesIndex.create!['acknowledged']).to eq(true) }
    specify { expect(DummiesIndex.create!('2013')['acknowledged']).to eq(true) }

    context do
      before { DummiesIndex.create }
      specify do
        expect { DummiesIndex.create! }.to raise_error(Elasticsearch::Transport::Transport::Errors::BadRequest).with_message(/index_already_exists_exception.*dummies/)
      end
      specify { expect { DummiesIndex.create!('2013') }.to raise_error(Elasticsearch::Transport::Transport::Errors::BadRequest).with_message(/Invalid alias name \[dummies\]/) }
    end

    context do
      before { DummiesIndex.create! '2013' }
      specify { expect(Chewy.client.indices.exists(index: 'dummies')).to eq(true) }
      specify { expect(Chewy.client.indices.exists(index: 'dummies_2013')).to eq(true) }
      specify { expect(DummiesIndex.aliases).to eq([]) }
      specify { expect(DummiesIndex.indexes).to eq(['dummies_2013']) }
      specify do
        expect { DummiesIndex.create!('2013') }.to raise_error(Elasticsearch::Transport::Transport::Errors::BadRequest).with_message(/index_already_exists_exception.*dummies_2013/)
      end
      specify { expect(DummiesIndex.create!('2014')['acknowledged']).to eq(true) }

      context do
        before { DummiesIndex.create! '2014' }
        specify { expect(DummiesIndex.indexes).to match_array(%w[dummies_2013 dummies_2014]) }
      end
    end

    context do
      before { DummiesIndex.create! '2013', alias: false }
      specify { expect(Chewy.client.indices.exists(index: 'dummies')).to eq(false) }
      specify { expect(Chewy.client.indices.exists(index: 'dummies_2013')).to eq(true) }
      specify { expect(DummiesIndex.aliases).to eq([]) }
      specify { expect(DummiesIndex.indexes).to eq([]) }
    end
  end

  describe '.delete' do
    specify { expect(DummiesIndex.delete).to eq(false) }
    specify { expect(DummiesIndex.delete('dummies_2013')).to eq(false) }

    context do
      before { DummiesIndex.create }
      specify { expect(DummiesIndex.delete['acknowledged']).to eq(true) }

      context do
        before { DummiesIndex.delete }
        specify { expect(Chewy.client.indices.exists(index: 'dummies')).to eq(false) }
      end
    end

    context do
      before { DummiesIndex.create '2013' }
      specify { expect(DummiesIndex.delete('2013')['acknowledged']).to eq(true) }

      context do
        before { DummiesIndex.delete('2013') }
        specify { expect(Chewy.client.indices.exists(index: 'dummies')).to eq(false) }
        specify { expect(Chewy.client.indices.exists(index: 'dummies_2013')).to eq(false) }
      end

      context do
        before { DummiesIndex.create '2014' }
        specify { expect(DummiesIndex.delete['acknowledged']).to eq(true) }

        context do
          before { DummiesIndex.delete }
          specify { expect(Chewy.client.indices.exists(index: 'dummies')).to eq(false) }
          specify { expect(Chewy.client.indices.exists(index: 'dummies_2013')).to eq(false) }
          specify { expect(Chewy.client.indices.exists(index: 'dummies_2014')).to eq(false) }
        end

        context do
          before { DummiesIndex.delete('2014') }
          specify { expect(Chewy.client.indices.exists(index: 'dummies')).to eq(true) }
          specify { expect(Chewy.client.indices.exists(index: 'dummies_2013')).to eq(true) }
          specify { expect(Chewy.client.indices.exists(index: 'dummies_2014')).to eq(false) }
        end
      end
    end
  end

  describe '.delete!' do
    specify { expect { DummiesIndex.delete! }.to raise_error(Elasticsearch::Transport::Transport::Errors::NotFound) }
    specify { expect { DummiesIndex.delete!('2013') }.to raise_error(Elasticsearch::Transport::Transport::Errors::NotFound) }

    context do
      before { DummiesIndex.create }
      specify { expect(DummiesIndex.delete!['acknowledged']).to eq(true) }

      context do
        before { DummiesIndex.delete! }
        specify { expect(Chewy.client.indices.exists(index: 'dummies')).to eq(false) }
      end
    end

    context do
      before { DummiesIndex.create '2013' }
      specify { expect(DummiesIndex.delete!('2013')['acknowledged']).to eq(true) }

      context do
        before { DummiesIndex.delete!('2013') }
        specify { expect(Chewy.client.indices.exists(index: 'dummies')).to eq(false) }
        specify { expect(Chewy.client.indices.exists(index: 'dummies_2013')).to eq(false) }
      end

      context do
        before { DummiesIndex.create '2014' }
        specify { expect(DummiesIndex.delete!['acknowledged']).to eq(true) }

        context do
          before { DummiesIndex.delete! }
          specify { expect(Chewy.client.indices.exists(index: 'dummies')).to eq(false) }
          specify { expect(Chewy.client.indices.exists(index: 'dummies_2013')).to eq(false) }
          specify { expect(Chewy.client.indices.exists(index: 'dummies_2014')).to eq(false) }
        end

        context do
          before { DummiesIndex.delete!('2014') }
          specify { expect(Chewy.client.indices.exists(index: 'dummies')).to eq(true) }
          specify { expect(Chewy.client.indices.exists(index: 'dummies_2013')).to eq(true) }
          specify { expect(Chewy.client.indices.exists(index: 'dummies_2014')).to eq(false) }
        end
      end
    end
  end

  describe '.purge' do
    specify { expect(DummiesIndex.purge['acknowledged']).to eq(true) }
    specify { expect(DummiesIndex.purge('2013')['acknowledged']).to eq(true) }

    context do
      before { DummiesIndex.purge }
      specify { expect(DummiesIndex).to be_exists }
      specify { expect(DummiesIndex.aliases).to eq([]) }
      specify { expect(DummiesIndex.indexes).to eq([]) }

      context do
        before { DummiesIndex.purge }
        specify { expect(DummiesIndex).to be_exists }
        specify { expect(DummiesIndex.aliases).to eq([]) }
        specify { expect(DummiesIndex.indexes).to eq([]) }
      end

      context do
        before { DummiesIndex.purge('2013') }
        specify { expect(DummiesIndex).to be_exists }
        specify { expect(DummiesIndex.aliases).to eq([]) }
        specify { expect(DummiesIndex.indexes).to eq(['dummies_2013']) }
      end
    end

    context do
      before { DummiesIndex.purge('2013') }
      specify { expect(DummiesIndex).to be_exists }
      specify { expect(DummiesIndex.aliases).to eq([]) }
      specify { expect(DummiesIndex.indexes).to eq(['dummies_2013']) }

      context do
        before { DummiesIndex.purge }
        specify { expect(DummiesIndex).to be_exists }
        specify { expect(DummiesIndex.aliases).to eq([]) }
        specify { expect(DummiesIndex.indexes).to eq([]) }
      end

      context do
        before { DummiesIndex.purge('2014') }
        specify { expect(DummiesIndex).to be_exists }
        specify { expect(DummiesIndex.aliases).to eq([]) }
        specify { expect(DummiesIndex.indexes).to eq(['dummies_2014']) }
      end
    end
  end

  describe '.purge!' do
    specify { expect(DummiesIndex.purge!['acknowledged']).to eq(true) }
    specify { expect(DummiesIndex.purge!('2013')['acknowledged']).to eq(true) }

    context do
      before { DummiesIndex.purge! }
      specify { expect(DummiesIndex).to be_exists }
      specify { expect(DummiesIndex.aliases).to eq([]) }
      specify { expect(DummiesIndex.indexes).to eq([]) }

      context do
        before { DummiesIndex.purge! }
        specify { expect(DummiesIndex).to be_exists }
        specify { expect(DummiesIndex.aliases).to eq([]) }
        specify { expect(DummiesIndex.indexes).to eq([]) }
      end

      context do
        before { DummiesIndex.purge!('2013') }
        specify { expect(DummiesIndex).to be_exists }
        specify { expect(DummiesIndex.aliases).to eq([]) }
        specify { expect(DummiesIndex.indexes).to eq(['dummies_2013']) }
      end
    end

    context do
      before { DummiesIndex.purge!('2013') }
      specify { expect(DummiesIndex).to be_exists }
      specify { expect(DummiesIndex.aliases).to eq([]) }
      specify { expect(DummiesIndex.indexes).to eq(['dummies_2013']) }

      context do
        before { DummiesIndex.purge! }
        specify { expect(DummiesIndex).to be_exists }
        specify { expect(DummiesIndex.aliases).to eq([]) }
        specify { expect(DummiesIndex.indexes).to eq([]) }
      end

      context do
        before { DummiesIndex.purge!('2014') }
        specify { expect(DummiesIndex).to be_exists }
        specify { expect(DummiesIndex.aliases).to eq([]) }
        specify { expect(DummiesIndex.indexes).to eq(['dummies_2014']) }
      end
    end
  end

  describe '.import', :orm do
    before do
      stub_model(:city)
      stub_index(:cities) do
        define_type City
      end
    end
    let!(:dummy_cities) { Array.new(3) { |i| City.create(id: i + 1, name: "name#{i}") } }

    specify { expect(CitiesIndex.import).to eq(true) }

    context do
      before do
        stub_index(:cities) do
          define_type City do
            field :name, type: 'object'
          end
        end
      end

      specify { expect(CitiesIndex.import(city: dummy_cities)).to eq(false) }
    end
  end

  describe '.import!', :orm do
    before do
      stub_model(:city)
      stub_index(:cities) do
        define_type City
      end
    end
    let!(:dummy_cities) { Array.new(3) { |i| City.create(id: i + 1, name: "name#{i}") } }

    specify { expect(CitiesIndex.import!).to eq(true) }

    context do
      before do
        stub_index(:cities) do
          define_type City do
            field :name, type: 'object'
          end
        end
      end

      specify { expect { CitiesIndex.import!(city: dummy_cities) }.to raise_error Chewy::ImportFailed }
    end
  end

  describe '.reset!', :orm do
    before do
      stub_model(:city)
      stub_index(:cities) do
        define_type City
      end
    end

    context do
      before { City.create!(id: 1, name: 'Moscow') }

      specify { expect(CitiesIndex.reset!).to eq(true) }
      specify { expect(CitiesIndex.reset!('2013')).to eq(true) }

      context do
        before { CitiesIndex.reset! }

        specify { expect(CitiesIndex.all).to have(1).item }
        specify { expect(CitiesIndex.aliases).to eq([]) }
        specify { expect(CitiesIndex.indexes).to eq([]) }

        context do
          before { CitiesIndex.reset!('2013') }

          specify { expect(CitiesIndex.all).to have(1).item }
          specify { expect(CitiesIndex.aliases).to eq([]) }
          specify { expect(CitiesIndex.indexes).to eq(['cities_2013']) }
        end

        context do
          before { CitiesIndex.reset! }

          specify { expect(CitiesIndex.all).to have(1).item }
          specify { expect(CitiesIndex.aliases).to eq([]) }
          specify { expect(CitiesIndex.indexes).to eq([]) }
        end
      end

      context do
        before { CitiesIndex.reset!('2013') }

        specify { expect(CitiesIndex.all).to have(1).item }
        specify { expect(CitiesIndex.aliases).to eq([]) }
        specify { expect(CitiesIndex.indexes).to eq(['cities_2013']) }

        context do
          before { CitiesIndex.reset!('2014') }

          specify { expect(CitiesIndex.all).to have(1).item }
          specify { expect(CitiesIndex.aliases).to eq([]) }
          specify { expect(CitiesIndex.indexes).to eq(['cities_2014']) }
          specify { expect(Chewy.client.indices.exists(index: 'cities_2013')).to eq(false) }
        end

        context do
          before { CitiesIndex.reset! }

          specify { expect(CitiesIndex.all).to have(1).item }
          specify { expect(CitiesIndex.aliases).to eq([]) }
          specify { expect(CitiesIndex.indexes).to eq([]) }
          specify { expect(Chewy.client.indices.exists(index: 'cities_2013')).to eq(false) }
        end
      end
    end

    context 'reset_disable_refresh_interval' do
      let(:suffix) { Time.now.to_i }
      let(:name) { CitiesIndex.index_name(suffix: suffix) }
      let(:before_import_body) do
        {
          index: {refresh_interval: -1}
        }
      end
      let(:after_import_body) do
        {
          index: {refresh_interval: '1s'}
        }
      end

      before { CitiesIndex.reset!('2013') }
      before { allow(Chewy).to receive(:reset_disable_refresh_interval).and_return(reset_disable_refresh_interval) }

      context 'activated' do
        let(:reset_disable_refresh_interval) { true }
        specify do
          expect(CitiesIndex.client.indices).to receive(:put_settings).with(index: name, body: before_import_body).once
          expect(CitiesIndex.client.indices).to receive(:put_settings).with(index: name, body: after_import_body).once
          expect(CitiesIndex).to receive(:import).with(suffix: suffix, journal: false, refresh: false).and_call_original
          expect(CitiesIndex.reset!(suffix)).to eq(true)
        end

        context 'refresh_interval already defined' do
          before do
            stub_index(:cities) do
              settings index: {refresh_interval: '2s'}
              define_type City
            end
          end

          let(:after_import_body) do
            {
              index: {refresh_interval: '2s'}
            }
          end

          specify do
            expect(CitiesIndex.client.indices).to receive(:put_settings).with(index: name, body: before_import_body).once
            expect(CitiesIndex.client.indices).to receive(:put_settings).with(index: name, body: after_import_body).once
            expect(CitiesIndex).to receive(:import).with(suffix: suffix, journal: false, refresh: false).and_call_original
            expect(CitiesIndex.reset!(suffix)).to eq(true)
          end

          specify 'uses empty index settings if not defined' do
            allow(Chewy).to receive(:wait_for_status).and_return(nil)
            allow(CitiesIndex).to receive(:settings_hash).and_return({})
            expect(CitiesIndex.reset!(suffix)).to eq(true)
          end
        end
      end

      context 'not activated' do
        let(:reset_disable_refresh_interval) { false }
        specify do
          expect(CitiesIndex.client.indices).not_to receive(:put_settings)
          expect(CitiesIndex).to receive(:import).with(suffix: suffix, journal: false, refresh: true).and_call_original
          expect(CitiesIndex.reset!(suffix)).to eq(true)
        end
      end
    end

    context 'reset_no_replicas' do
      let(:suffix) { Time.now.to_i }
      let(:name) { CitiesIndex.index_name(suffix: suffix) }
      let(:before_import_body) do
        {
          index: {number_of_replicas: 0}
        }
      end
      let(:after_import_body) do
        {
          index: {number_of_replicas: 0}
        }
      end

      before { allow(Chewy).to receive(:reset_no_replicas).and_return(reset_no_replicas) }

      context 'activated' do
        let(:reset_no_replicas) { true }
        specify do
          expect(CitiesIndex.client.indices).to receive(:put_settings).with(index: name, body: before_import_body).once
          expect(CitiesIndex.client.indices).to receive(:put_settings).with(index: name, body: after_import_body).once
          expect(CitiesIndex).to receive(:import).with(suffix: suffix, journal: false, refresh: true).and_call_original
          expect(CitiesIndex.reset!(suffix)).to eq(true)
        end
      end

      context 'not activated' do
        let(:reset_no_replicas) { false }
        specify do
          expect(CitiesIndex.client.indices).not_to receive(:put_settings)
          expect(CitiesIndex).to receive(:import).with(suffix: suffix, journal: false, refresh: true).and_call_original
          expect(CitiesIndex.reset!(suffix)).to eq(true)
        end
      end
    end

    xcontext 'applying journal' do
      before do
        stub_index(:cities) do
          define_type City do
            field :name, value: (lambda do
              sleep(rating)
              name
            end)
          end
        end
      end

      let!(:cities) { Array.new(3) { |i| City.create!(id: i + 1, name: "Name#{i + 1}", rating: 1) } }

      let(:parallel_update) do
        Thread.new do
          p 'start parallel'
          sleep(1.5)
          cities.first.update(name: 'NewName1', rating: 0)
          cities.last.update(name: 'NewName3', rating: 0)
          CitiesIndex::City.import!([cities.first, cities.last], journal: true)
          p 'end parallel'
        end
      end

      specify 'with journal application' do
        cities
        p 'cities created1'
        ::ActiveRecord::Base.connection.close if defined?(::ActiveRecord::Base)
        [
          parallel_update,
          Thread.new do
            p 'start reset1'
            CitiesIndex.reset!('suffix')
            p 'end reset1'
          end
        ].map(&:join)
        ::ActiveRecord::Base.connection.reconnect! if defined?(::ActiveRecord::Base)
        p 'expect1'
        expect(CitiesIndex::City.pluck(:_id, :name)).to contain_exactly(%w[1 NewName1], %w[2 Name2], %w[3 NewName3])
        p 'end expect1'
      end

      specify 'without journal application' do
        cities
        p 'cities created2'
        ::ActiveRecord::Base.connection.close if defined?(::ActiveRecord::Base)
        [
          parallel_update,
          Thread.new do
            p 'start reset2'
            CitiesIndex.reset!('suffix', apply_journal: false)
            p 'end reset2'
          end
        ].map(&:join)
        ::ActiveRecord::Base.connection.reconnect! if defined?(::ActiveRecord::Base)
        p 'expect2'
        expect(CitiesIndex::City.pluck(:_id, :name)).to contain_exactly(%w[1 Name1], %w[2 Name2], %w[3 Name3])
        p 'end expect2'
      end
    end

    context 'journaling' do
      before { City.create!(id: 1, name: 'Moscow') }

      specify do
        CitiesIndex.reset!
        expect(Chewy::Stash::Journal.count).to eq(0)
      end

      specify do
        CitiesIndex.reset! journal: true
        expect(Chewy::Stash::Journal.count).to be > 0
      end
    end

    context 'other options' do
      specify do
        expect(CitiesIndex::City).to receive(:import).with(parallel: true, journal: false).once.and_return(true)
        expect(CitiesIndex.reset!(parallel: true)).to eq(true)
      end

      specify do
        expect(CitiesIndex::City).to receive(:import).with(suffix: 'suffix', parallel: true, journal: false, refresh: true).once.and_return(true)
        expect(CitiesIndex.reset!('suffix', parallel: true)).to eq(true)
      end
    end
  end

  describe '.journal' do
    specify { expect(DummiesIndex.journal).to be_a(Chewy::Journal) }
  end
end

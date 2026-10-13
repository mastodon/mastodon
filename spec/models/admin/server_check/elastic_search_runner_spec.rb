# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::ServerCheck::ElasticSearchRunner do
  subject(:runner) { described_class.new }

  let(:user) { Fabricate(:user) }

  it_behaves_like 'a check runner available to devops users'

  describe '#run' do
    subject(:result) { runner.run }

    context 'when chewy is not enabled' do
      before do
        allow(Chewy).to receive(:enabled?).and_return(false)
      end

      it { is_expected.to be_ok }
    end

    context 'when chewy is enabled' do
      before do
        allow(Chewy).to receive(:enabled?).and_return(true)
        allow(Chewy.client).to receive(:info)
          .and_return({ 'version' => { 'number' => '1.2.3', 'minimum_wire_compatibility_version' => '99.9' } })
        allow(Chewy.client.cluster).to receive(:health).and_return({ 'status' => 'green', 'number_of_nodes' => 1 })
        allow(Chewy.client.indices).to receive_messages(get_mapping: {
          AccountsIndex.index_name => AccountsIndex.mappings_hash.deep_stringify_keys,
          StatusesIndex.index_name => StatusesIndex.mappings_hash.deep_stringify_keys,
          PublicStatusesIndex.index_name => PublicStatusesIndex.mappings_hash.deep_stringify_keys,
          InstancesIndex.index_name => InstancesIndex.mappings_hash.deep_stringify_keys,
          TagsIndex.index_name => TagsIndex.mappings_hash.deep_stringify_keys,
        }, get_settings: {
          'chewy_specifications' => {
            'settings' => {
              'index' => {
                'number_of_replicas' => 0,
              },
            },
          },
        })
        [AccountsIndex, StatusesIndex, PublicStatusesIndex, InstancesIndex, TagsIndex].each do |index|
          allow(index).to receive(:specification).and_return(instance_double(Chewy::Index::Specification, changed?: false))
        end
      end

      context 'when everything is setup properly' do
        it { is_expected.to be_ok }
      end

      context 'with running version' do
        context 'when is missing' do
          before do
            allow(Chewy.client).to receive(:info).and_return({})
          end

          it { is_expected.to be_pending }

          it 'sets the reason to running_check' do
            expect(result.data).to include(reason: :running_check, running_version: :missing)
          end
        end

        context 'when it fails' do
          before do
            stub_elasticsearch_error
          end

          it { is_expected.to be_pending }

          it 'sets the reason to running_check' do
            expect(result.data).to include(reason: :running_check, running_version: :missing)
          end
        end
      end

      context 'when versions are not compatible' do
        before do
          allow(Chewy.client).to receive(:info)
            .and_return({ 'version' => { 'number' => '1.2.3', 'minimum_wire_compatibility_version' => '1.0' } })
        end

        it { is_expected.to be_pending }

        it 'sets the reason to version_check' do
          expect(result.data).to include(reason: :version_check, running_version: '1.2.3', required_version: '7.x')
        end
      end

      context 'when the health of the cluster is red' do
        before do
          allow(Chewy.client.cluster).to receive(:health).and_return({ 'status' => 'red', 'number_of_nodes' => 1 })
        end

        it { is_expected.to be_pending }

        it 'sets the reason to cluster_health_red' do
          expect(result.data).to include(reason: :cluster_health_red)
        end
      end

      context 'when indexes mismatch' do
        before do
          allow(Chewy.client.indices).to receive_messages(get_mapping: {
            AccountsIndex.index_name => { wrong: :value },
            StatusesIndex.index_name => { wrong: :value },
            PublicStatusesIndex.index_name => PublicStatusesIndex.mappings_hash.deep_stringify_keys,
            InstancesIndex.index_name => InstancesIndex.mappings_hash.deep_stringify_keys,
            TagsIndex.index_name => TagsIndex.mappings_hash.deep_stringify_keys,
          })
        end

        it { is_expected.to be_pending }

        it 'sets the reason to index_mismatch' do
          expect(result.data).to include(reason: :index_mismatch, mismatched_indexes: %w(accounts statuses))
        end
      end

      context 'when specifications mismatch' do
        before do
          allow(AccountsIndex.specification).to receive(:changed?).and_return(true)
        end

        it { is_expected.to be_pending }

        it 'sets the reason to analysis_index_mismatch' do
          expect(result.data).to include(reason: :analysis_index_mismatch, mismatched_specifications_indexes: %w(accounts))
        end
      end

      context 'when there is a low number of nodes for non single node configurations' do
        around do |example|
          original = ENV.fetch('ES_PRESET', nil)
          ENV['ES_PRESET'] = 'multiple_node_cluster'
          example.run
        ensure
          ENV['ES_PRESET'] = original if original.present?
        end

        it { is_expected.to be_pending }

        it 'sets the reason to preset_single_node' do
          expect(result.data).to include(reason: :preset_single_node)
        end
      end

      context 'when Chewy needs to be reset' do
        before do
          allow(Chewy.client.indices).to receive_messages(get_settings: {
            'chewy_specifications' => {
              'settings' => {
                'index' => {
                  'number_of_replicas' => 1,
                },
              },
            },
          })
        end

        it { is_expected.to be_pending }

        it 'sets the reason to reset_chewy' do
          expect(result.data).to include(reason: :reset_chewy)
        end
      end

      context 'when the health of the cluster is yellow' do
        before do
          allow(Chewy.client.cluster).to receive(:health).and_return({ 'status' => 'yellow', 'number_of_nodes' => 1 })
        end

        it { is_expected.to be_pending }

        it 'sets the reason to cluster_health_red' do
          expect(result.data).to include(reason: :cluster_health_yellow)
        end
      end

      context 'when the number of nodes does not match the preset' do
        before do
          allow(Chewy.client.cluster).to receive(:health).and_return({ 'status' => 'green', 'number_of_nodes' => 2 })
        end

        it { is_expected.to be_pending }

        it 'sets the reason to preset' do
          expect(result.data).to include(reason: :preset)
        end
      end
    end
  end

  def stub_elasticsearch_error
    client = instance_double(Elasticsearch::Client)
    allow(client).to receive(:info).and_raise(Elastic::Transport::Transport::Error)
    allow(Chewy).to receive(:client).and_return(client)
  end
end

# frozen_string_literal: true

require 'rails_helper'

describe Admin::SystemCheck::ElasticsearchCheck do
  subject(:check) { described_class.new(user) }

  let(:user) { Fabricate(:user) }

  it_behaves_like 'a check available to devops users'

  describe 'pass?' do
    context 'when chewy is enabled' do
      before do
        allow(Chewy).to receive(:enabled?).and_return(true)
        allow(Chewy.client.cluster).to receive(:health).and_return({ 'status' => 'green', 'number_of_nodes' => 1 })
        allow(Chewy.client.indices).to receive(:get_mapping).and_return({
          AccountsIndex.index_name => AccountsIndex.mappings_hash.deep_stringify_keys,
          StatusesIndex.index_name => StatusesIndex.mappings_hash.deep_stringify_keys,
          InstancesIndex.index_name => InstancesIndex.mappings_hash.deep_stringify_keys,
          TagsIndex.index_name => TagsIndex.mappings_hash.deep_stringify_keys,
        })
        allow(Chewy.client.indices).to receive(:get_settings).and_return({
          'chewy_specifications' => {
            'settings' => {
              'index' => {
                'number_of_replicas' => 0,
              },
            },
          },
        })
      end

      context 'when running version is present and high enough' do
        before do
          allow(Chewy.client).to receive(:info)
            .and_return({ 'version' => { 'number' => '999.99.9' } })
        end

        it 'returns true' do
          expect(check.pass?).to be true
        end
      end

      context 'when running version is present and too low' do
        context 'when compatible version is too low' do
          before do
            allow(Chewy.client).to receive(:info)
              .and_return({ 'version' => { 'number' => '1.2.3', 'minimum_wire_compatibility_version' => '1.0' } })
          end

          it 'returns false' do
            expect(check.pass?).to be false
          end
        end

        context 'when compatible version is high enough' do
          before do
            allow(Chewy.client).to receive(:info)
              .and_return({ 'version' => { 'number' => '1.2.3', 'minimum_wire_compatibility_version' => '99.9' } })
          end

          it 'returns true' do
            expect(check.pass?).to be true
          end
        end
      end

      context 'when running version is missing' do
        before { stub_elasticsearch_error }

        it 'returns false' do
          expect(check.pass?).to be false
        end
      end
    end

    context 'when chewy is not enabled' do
      before { allow(Chewy).to receive(:enabled?).and_return(false) }

      it 'returns true' do
        expect(check.pass?).to be true
      end
    end
  end

  describe 'message' do
    before do
      allow(Chewy).to receive(:enabled?).and_return(true)
      allow(Chewy.client.cluster).to receive(:health).and_return({ 'status' => 'green', 'number_of_nodes' => 1 })
      allow(Chewy.client.indices).to receive(:get_mapping).and_return({
        AccountsIndex.index_name => AccountsIndex.mappings_hash.deep_stringify_keys,
        StatusesIndex.index_name => StatusesIndex.mappings_hash.deep_stringify_keys,
        InstancesIndex.index_name => InstancesIndex.mappings_hash.deep_stringify_keys,
        TagsIndex.index_name => TagsIndex.mappings_hash.deep_stringify_keys,
      })
    end

    context 'when running version is present' do
      before { allow(Chewy.client).to receive(:info).and_return({ 'version' => { 'number' => '1.2.3' } }) }

      it 'sends class name symbol to message instance' do
        allow(Admin::SystemCheck::Message).to receive(:new)
          .with(:elasticsearch_version_check, anything)

        check.message

        expect(Admin::SystemCheck::Message).to have_received(:new)
          .with(:elasticsearch_version_check, 'Elasticsearch 1.2.3 is running while 7.x is required')
      end
    end

    context 'when running version is missing' do
      before { stub_elasticsearch_error }

      it 'sends class name symbol to message instance' do
        allow(Admin::SystemCheck::Message).to receive(:new)
          .with(:elasticsearch_running_check)

        check.message

        expect(Admin::SystemCheck::Message).to have_received(:new)
          .with(:elasticsearch_running_check)
      end
    end
  end

  def stub_elasticsearch_error
    client = instance_double(Elasticsearch::Transport::Client)
    allow(client).to receive(:info).and_raise(Elasticsearch::Transport::Transport::Error)
    allow(Chewy).to receive(:client).and_return(client)
  end
end

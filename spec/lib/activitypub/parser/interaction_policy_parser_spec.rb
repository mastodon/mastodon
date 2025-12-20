# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::Parser::InteractionPolicyParser do
  subject { described_class.new(json_policy, account) }

  let(:account) do
    Fabricate(:account,
              uri: 'https://foo.test',
              domain: 'foo.test',
              followers_url: 'https://foo.test/followers',
              following_url: 'https://foo.test/following')
  end

  describe '#bitmap' do
    context 'when no policy is given' do
      let(:json_policy) { nil }

      it 'returns zero' do
        expect(subject.bitmap).to be_zero
      end
    end

    context 'with special public URI' do
      let(:json_policy) do
        {
          'manualApproval' => [public_uri],
        }
      end

      shared_examples 'setting the public bit' do
        it 'sets the public bit' do
          expect(subject.bitmap).to eq 0b10
        end
      end

      context 'when public URI is given in full' do
        let(:public_uri) { 'https://www.w3.org/ns/activitystreams#Public' }

        it_behaves_like 'setting the public bit'
      end

      context 'when public URI is abbreviated using namespace' do
        let(:public_uri) { 'as:Public' }

        it_behaves_like 'setting the public bit'
      end

      context 'when public URI is abbreviated without namespace' do
        let(:public_uri) { 'Public' }

        it_behaves_like 'setting the public bit'
      end
    end

    context 'when mixing array and scalar values' do
      let(:json_policy) do
        {
          'automaticApproval' => 'https://foo.test',
          'manualApproval' => [
            'https://foo.test/followers',
            'https://foo.test/following',
          ],
        }
      end

      it 'sets the correct flags' do
        expect(subject.bitmap).to eq 0b100000000000000001100
      end
    end

    context 'when including individual actor URIs' do
      let(:json_policy) do
        {
          'automaticApproval' => ['https://example.com/actor', 'https://masto.example.com/@user'],
          'manualApproval' => ['https://masto.example.com/@other'],
        }
      end

      it 'sets the unsupported bit' do
        expect(subject.bitmap).to eq 0b10000000000000001
      end
    end

    context "when giving the affected actor's URI in addition to other supported URIs" do
      let(:json_policy) do
        {
          'manualApproval' => [
            'https://foo.test/followers',
            'https://foo.test/following',
            'https://foo.test',
          ],
        }
      end

      it 'is being ignored' do
        expect(subject.bitmap).to eq 0b1100
      end
    end
  end
end

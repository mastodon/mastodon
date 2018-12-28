# frozen_string_literal: true

require 'rails_helper'
require 'keybase_proof'

describe Keybase::Proof do
  let(:keybase_proof) do
    described_class.new('cryptoalice', 'alice', '11111111111111111111111111', 'mastodon.fake')
  end

  describe 'is_remote_valid?' do
    before do
      base_url = 'https://keybase.io/_/api/1.0/sig/proof_valid.json'
      params = "domain=mastodon.fake&kb_username=cryptoalice&username=alice&sig_hash=11111111111111111111111111"
      json_response_body = '{"status":{"code":0,"name":"OK"},"proof_valid":true}'

      stub_request(:get, "#{base_url}?#{params}").to_return(status: 200, body: json_response_body)
    end

    it 'calls out to keybase and returns proof_valid' do
      expect(keybase_proof.is_remote_valid?).to eq true
    end
  end

  describe 'is_remote_live?' do
    before do
      base_url = 'https://keybase.io/_/api/1.0/sig/proof_live.json'
      params = "domain=mastodon.fake&kb_username=cryptoalice&username=alice&sig_hash=11111111111111111111111111"
      json_response_body = '{"status":{"code":0,"name":"OK"},"proof_live":false}'

      stub_request(:get, "#{base_url}?#{params}").to_return(status: 200, body: json_response_body)
    end

    it 'calls out to keybase and returns proof_live' do
      expect(keybase_proof.is_remote_live?).to eq false
    end
  end

  describe 'keybase returns something unexpected' do
    before do
      base_url = 'https://keybase.io/_/api/1.0/sig/proof_valid.json'
      params = "domain=mastodon.fake&kb_username=cryptoalice&username=alice&sig_hash=11111111111111111111111111"
      json_response_body = '{"status":{"code":100,"desc":"wrong size hex_id","fields":{"sig_hash":"wrong size hex_id"},"name":"INPUT_ERROR"}}'

      stub_request(:get, "#{base_url}?#{params}").to_return(status: 200, body: json_response_body)
    end

    it 'is_remote_valid? is false' do
      expect(keybase_proof.is_remote_valid?).to eq false
    end
  end
end

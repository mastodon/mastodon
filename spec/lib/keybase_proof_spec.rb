# frozen_string_literal: true

require 'rails_helper'
require 'keybase_proof'

describe Keybase::Proof do
  let(:my_domain) { ExternalProofService.my_domain }
  let(:keybase_proof) do
    local_proof = AccountIdentityProof.new(
      provider: 'Keybase',
      provider_username: 'cryptoalice',
      token: '11111111111111111111111111'
    )
    described_class.new(local_proof, 'alice')
  end
  let(:query_params) do
    "domain=#{my_domain}&kb_username=cryptoalice&sig_hash=11111111111111111111111111&username=alice"
  end

  describe 'valid?' do
    let(:base_url) { 'https://keybase.io/_/api/1.0/sig/proof_valid.json' }

    context 'when valid' do
      before do
        json_response_body = '{"status":{"code":0,"name":"OK"},"proof_valid":true}'
        stub_request(:get, "#{base_url}?#{query_params}").to_return(status: 200, body: json_response_body)
      end

      it 'calls out to keybase and returns true' do
        expect(keybase_proof.valid?).to eq true
      end
    end

    context 'when invalid' do
      before do
        json_response_body = '{"status":{"code":0,"name":"OK"},"proof_valid":false}'
        stub_request(:get, "#{base_url}?#{query_params}").to_return(status: 200, body: json_response_body)
      end

      it 'calls out to keybase and returns false' do
        expect(keybase_proof.valid?).to eq false
      end
    end

    context 'with an unexpected api response' do
      before do
        json_response_body = '{"status":{"code":100,"desc":"wrong size hex_id","fields":{"sig_hash":"wrong size hex_id"},"name":"INPUT_ERROR"}}'
        stub_request(:get, "#{base_url}?#{query_params}").to_return(status: 200, body: json_response_body)
      end

      it 'swallows the error and returns false' do
        expect(keybase_proof.valid?).to eq false
      end
    end
  end

  describe 'remote_status' do
    let(:base_url) { 'https://keybase.io/_/api/1.0/sig/proof_live.json' }

    context 'with a normal response' do
      before do
        json_response_body = '{"status":{"code":0,"name":"OK"},"proof_live":false,"proof_valid":true}'
        stub_request(:get, "#{base_url}?#{query_params}").to_return(status: 200, body: json_response_body)
      end

      it 'calls out to keybase and returns the status fields as is_valid and is_live' do
        expect(keybase_proof.remote_status).to eq( {is_valid: true, is_live: false} )
      end
    end

    context 'with an unexpected keybase response' do
      before do
        json_response_body = '{"status":{"code":100,"desc":"missing non-optional field sig_hash","fields":{"sig_hash":"missing non-optional field sig_hash"},"name":"INPUT_ERROR"}}'
        stub_request(:get, "#{base_url}?#{query_params}").to_return(status: 200, body: json_response_body)
      end

      it 'raises a KeyError' do
        expect { keybase_proof.remote_status }.to raise_error KeyError
      end
    end
  end

  describe 'badge_pic_url' do
    let(:expected_url) do
      "https://keybase.io/cryptoalice/proof_badge/11111111111111111111111111?domain=#{my_domain}&username=alice"
    end

    it 'builds the url correctly' do
      expect(keybase_proof.badge_pic_url).to eq expected_url
    end
  end
end

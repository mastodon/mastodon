require 'rails_helper'

describe ProofProvider::Keybase::Verifier do
  let(:my_domain) { Rails.configuration.x.local_domain }

  let(:keybase_proof) do
    local_proof = AccountIdentityProof.new(
      provider: 'Keybase',
      provider_username: 'cryptoalice',
      token: '11111111111111111111111111'
    )

    described_class.new('alice', 'cryptoalice', '11111111111111111111111111', my_domain)
  end

  let(:query_params) do
    "domain=#{my_domain}&kb_username=cryptoalice&sig_hash=11111111111111111111111111&username=alice"
  end

  describe '#valid?' do
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

  describe '#status' do
    let(:base_url) { 'https://keybase.io/_/api/1.0/sig/proof_live.json' }

    context 'with a normal response' do
      before do
        json_response_body = '{"status":{"code":0,"name":"OK"},"proof_live":false,"proof_valid":true}'
        stub_request(:get, "#{base_url}?#{query_params}").to_return(status: 200, body: json_response_body)
      end

      it 'calls out to keybase and returns the status fields as proof_valid and proof_live' do
        expect(keybase_proof.status).to include({ 'proof_valid' => true, 'proof_live' => false })
      end
    end

    context 'with an unexpected keybase response' do
      before do
        json_response_body = '{"status":{"code":100,"desc":"missing non-optional field sig_hash","fields":{"sig_hash":"missing non-optional field sig_hash"},"name":"INPUT_ERROR"}}'
        stub_request(:get, "#{base_url}?#{query_params}").to_return(status: 200, body: json_response_body)
      end

      it 'raises a ProofProvider::Keybase::UnexpectedResponseError' do
        expect { keybase_proof.status }.to raise_error ProofProvider::Keybase::UnexpectedResponseError
      end
    end
  end
end

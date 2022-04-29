require 'rails_helper'

RSpec.describe ActivityPub::Dereferencer do
  describe '#object' do
    let(:object) { { '@context': 'https://www.w3.org/ns/activitystreams', id: 'https://example.com/foo', type: 'Note', content: 'Hoge' } }
    let(:permitted_origin) { 'https://example.com' }
    let(:signature_account) { nil }
    let(:uri) { nil }

    subject { described_class.new(uri, permitted_origin: permitted_origin, signature_account: signature_account).object }

    before do
      stub_request(:get, 'https://example.com/foo').to_return(body: Oj.dump(object), headers: { 'Content-Type' => 'application/activity+json' })
    end

    context 'with a URI' do
      let(:uri) { 'https://example.com/foo' }

      it 'returns object' do
        expect(subject.with_indifferent_access).to eq object.with_indifferent_access
      end

      context 'with signature account' do
        let(:signature_account) { Fabricate(:account) }

        it 'makes signed request' do
          subject
          expect(a_request(:get, 'https://example.com/foo').with { |req| req.headers['Signature'].present? }).to have_been_made
        end
      end

      context 'with different origin' do
        let(:uri) { 'https://other-example.com/foo' }

        it 'does not make request' do
          subject
          expect(a_request(:get, 'https://other-example.com/foo')).to_not have_been_made
        end
      end
    end

    context 'with a bearcap' do
      let(:uri) { 'bear:?t=hoge&u=https://example.com/foo' }

      it 'makes request with Authorization header' do
        subject
        expect(a_request(:get, 'https://example.com/foo').with(headers: { 'Authorization' => 'Bearer hoge' })).to have_been_made
      end

      it 'returns object' do
        expect(subject.with_indifferent_access).to eq object.with_indifferent_access
      end

      context 'with signature account' do
        let(:signature_account) { Fabricate(:account) }

        it 'makes signed request' do
          subject
          expect(a_request(:get, 'https://example.com/foo').with { |req| req.headers['Signature'].present? && req.headers['Authorization'] == 'Bearer hoge' }).to have_been_made
        end
      end

      context 'with different origin' do
        let(:uri) { 'bear:?t=hoge&u=https://other-example.com/foo' }

        it 'does not make request' do
          subject
          expect(a_request(:get, 'https://other-example.com/foo')).to_not have_been_made
        end
      end
    end
  end
end

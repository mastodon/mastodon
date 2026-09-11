# frozen_string_literal: true

RSpec.shared_examples 'forbidden for unconfirmed provider' do
  context 'when the requesting provider is unconfirmed' do
    let(:provider) { Fabricate(:fasp_provider) }

    it 'returns http unauthorized' do
      subject

      expect(response).to have_http_status(401)
    end
  end
end

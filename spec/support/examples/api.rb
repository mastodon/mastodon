# frozen_string_literal: true

shared_examples 'forbidden for wrong scope' do |wrong_scope|
  let(:scopes) { wrong_scope }

  it 'returns http forbidden' do
    # Some examples have a subject which needs to be called to make a request
    subject if request.nil?

    expect(response).to have_http_status(403)
  end
end

shared_examples 'forbidden for wrong role' do |wrong_role|
  let(:role) { UserRole.find_by(name: wrong_role) }

  it 'returns http forbidden' do
    # Some examples have a subject which needs to be called to make a request
    subject if request.nil?

    expect(response).to have_http_status(403)
  end
end

shared_examples 'unprocessable entity' do
  it 'returns http unprocessable entity' do
    # Some examples have a subject which needs to be called to make a request
    subject if request.nil?

    expect(response).to have_http_status(422)
  end
end

shared_examples 'unauthorized for invalid token' do
  context 'with empty Authorization header' do
    let(:headers) { { 'Authorization' => '' } }

    it 'returns http unauthorized' do
      # Some examples have a subject which needs to be called to make a request
      subject if request.nil?

      expect(response).to have_http_status(401)
    end
  end

  context 'without Authorization header' do
    let(:headers) { {} }

    it 'returns http unprocessable entity' do
      subject

      expect(response).to have_http_status(401)
    end
  end
end

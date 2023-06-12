# frozen_string_literal: true

shared_examples 'forbidden for wrong scope' do |wrong_scope|
  let(:scopes) { wrong_scope }

  it 'returns http forbidden' do
    # Some examples have a subject which needs to be called to make a request
    subject if request.nil?

    expect(response).to have_http_status(403)
  end
end

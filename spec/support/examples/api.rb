# frozen_string_literal: true

RSpec.shared_examples 'forbidden for wrong scope' do |wrong_scope|
  let(:scopes) { wrong_scope }

  it 'returns http forbidden' do
    # Some examples have a subject which needs to be called to make a request
    subject if request.nil?

    expect(response).to have_http_status(403)
  end
end

RSpec.shared_examples 'forbidden for wrong role' do |wrong_role|
  let(:role) { UserRole.find_by(name: wrong_role) }
  let(:user) { Fabricate(:user, role:) }

  it 'returns http forbidden' do
    # Some examples have a subject which needs to be called to make a request
    subject if request.nil?

    expect(response).to have_http_status(403)
  end
end

RSpec.shared_examples 'forbidden for disabled user' do
  let(:user) { Fabricate(:admin_user, disabled: true) }

  it 'returns http forbidden' do
    # Some examples have a subject which needs to be called to make a request
    subject if request.nil?

    expect(response).to have_http_status(403)
  end
end

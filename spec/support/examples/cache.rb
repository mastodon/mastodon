# frozen_string_literal: true

shared_examples 'cacheable response' do |expects_vary: false|
  it 'sets correct cache and vary headers and does not set cookies or session', :aggregate_failures do
    expect(response.cookies).to be_empty
    expect(response.headers['Set-Cookies']).to be_nil

    expect(session).to be_empty

    expect(response).to have_http_header('Vary', expects_vary) if expects_vary

    expect(response).to have_http_header('Cache-Control', 'public')
  end
end

# frozen_string_literal: true

shared_examples 'cacheable response' do |expects_vary: false|
  it 'does not set cookies' do
    expect(response.cookies).to be_empty
    expect(response.headers['Set-Cookies']).to be_nil
  end

  it 'does not set sessions' do
    expect(session).to be_empty
  end

  if expects_vary
    it 'returns Vary header' do
      expect(response.headers['Vary']).to include(expects_vary)
    end
  end

  it 'returns public Cache-Control header' do
    expect(response.headers['Cache-Control']).to include('public')
  end
end

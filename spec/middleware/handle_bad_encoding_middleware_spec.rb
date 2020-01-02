require 'rails_helper'

RSpec.describe HandleBadEncodingMiddleware do
  let(:app) { double() }
  let(:middleware) { HandleBadEncodingMiddleware.new(app) }

  it 'passes requests with normal query parameters' do
    env = env_for('/some/path?name=fred')
    expect(app).to receive(:call).with(env)
    middleware.call(env)
  end

  it 'passes requests with no query parameters' do
    env = env_for('/some/path')
    expect(app).to receive(:call).with(env)
    middleware.call(env)
  end

  it 'drops requests with invalid %-encoding in parameters' do
    env = env_for('/some/path')
    env['QUERY_STRING'] = 'q=%2Fsearch%2Fall%Forder%3Ddescending%26page%3D5%26sort%3Dcreated_at'
    response = middleware.call(env)
    expect(response).to eq [400, {}, ['Bad request']]
  end

  it 'drops requests with invalid encoding in parameters' do
    env = env_for('/some/path')
    env['QUERY_STRING'] = 'info_hash=f%e5u6%ac%5d%df%c8S%fc%9c7%b3%ff%26A%c3y%85%a3&peer_id=-TR2840-tgshmuspym9s&port=51413&uploaded=0&downloaded=0&left=11675&numwant=0&key=1a314ff6&compact=1&supportcrypto=1&event=stopped'
    response = middleware.call(env)
    expect(response).to eq [400, {}, ['Bad request']]
  end

  def env_for(url, opts = {})
    Rack::MockRequest.env_for(url, opts)
  end
end

ENV['RAILS_ENV'] = 'test'

require 'rspec/core'

RSpec.describe 'rails', type: :request do
  let(:stdout) { StringIO.new }

  around(:each) do |example|
    original_stdout = $stdout
    $stdout = stdout
    require_relative 'app'
    require 'rspec/rails'
    example.run
    $stdout = original_stdout
  end

  it 'does not log anything to STDOUT when initializing and sets the Hashie logger to the Rails logger' do
    expect(stdout.string).to eq('')
    expect(Hashie.logger).to eq(Rails.logger)
  end

  it 'works' do
    get '/'
    assert_select 'h1', 'Hello, world!'
  end
end

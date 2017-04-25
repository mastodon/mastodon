require 'simplecov'

SimpleCov.start 'rails' do
  add_group 'Services', 'app/services'
  add_group 'Presenters', 'app/presenters'
  add_group 'Validators', 'app/validators'
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true

    config.around(:example, :without_verify_partial_doubles) do |example|
      mocks.verify_partial_doubles = false
      example.call
      mocks.verify_partial_doubles = true
    end
  end

  config.after :suite do
    FileUtils.rm_rf(Dir["#{Rails.root}/spec/test_files/"])
  end
end

def body_as_json
  json_str_to_hash(response.body)
end

def json_str_to_hash(str)
  JSON.parse(str, symbolize_names: true)
end
